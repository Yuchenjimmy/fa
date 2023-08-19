--******************************************************************************************************
--** Copyright (c) 2022  Willem 'Jip' Wijnia
--**
--** Permission is hereby granted, free of charge, to any person obtaining a copy
--** of this software and associated documentation files (the "Software"), to deal
--** in the Software without restriction, including without limitation the rights
--** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--** copies of the Software, and to permit persons to whom the Software is
--** furnished to do so, subject to the following conditions:
--**
--** The above copyright notice and this permission notice shall be included in all
--** copies or substantial portions of the Software.
--**
--** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--** SOFTWARE.
--******************************************************************************************************

-- upvalue scope for performance
local TableGetn = table.getn
local TableInsert = table.insert
local TableSort = table.sort

local MathMod = math.mod
local MathMin = math.min

local UnitQueueDataToCommand = import("/lua/sim/commands/orders-shared.lua").UnitQueueDataToCommand
local ComputeBatchCounts = import("/lua/sim/commands/orders-shared.lua").ComputeBatchCounts
local PopulateBatch = import("/lua/sim/commands/orders-shared.lua").PopulateBatch
local PopulateLocation = import("/lua/sim/commands/orders-shared.lua").PopulateLocation
local SortUnitsByDistanceToPoint = import("/lua/sim/commands/orders-shared.lua").SortUnitsByDistanceToPoint


--- Processes the orders and re-distributes them over the units. Assumes that all units in the
--- selection to have the same command queue. If that is not the case then orders are lost
---@param units Unit[]
---@param target Unit
DistributeOrders = function(units, target, clearCommands)

    local start = GetSystemTimeSecondsOnlyForProfileUse()

    -----------------------------------------------------------------------
    -- bundle the orders

    ---@type table<EntityId, boolean>
    local seen = {}

    ---@type number | nil
    local px = nil

    ---@type number | nil
    local pz = nil

    ---@type UnitCommand[][]
    local groups = { {} }

    ---@type UnitCommand[]
    local orders = target:GetCommandQueue()

    for k, order in orders do

        -- find the first order that represents a position

        local ox = order.x
        local oz = order.z
        if (not px) and (ox > 0) and (oz > 0) then
            px = ox
            pz = oz
        end

        -- find the last group
        local group = groups[TableGetn(groups)]

        -- try and remove duplicated orders
        local targetId = order.targetId
        if targetId then
            if seen[targetId] then
                continue
            end
            seen[targetId] = true
        end

        -- edge case: group has no orders, so we add this order and
        -- call it a day
        if not group[1] then
            TableInsert(group, order)
            -- usual case: check if the current group is of the same
            -- type of order, if so add to the group otherwise create
            -- a new group
        else
            if group[1].commandType == order.commandType then
                TableInsert(group, order)
            else
                TableInsert(groups, { order })

                -- the 'seen' table is per group of orders
                seen = {}
                if targetId then
                    seen[targetId] = true
                end
            end
        end
    end

    -----------------------------------------------------------------------
    -- sorting units

    -- we sort the selection to make the order more intuitive. By default
    -- the order is defined by the entityId, which is essentially random in
    -- the average case

    if px and pz then
        SortUnitsByDistanceToPoint(units, px, pz)
    end

    -----------------------------------------------------------------------
    -- clear existing orders

    if clearCommands then
        IssueClearCommands(units)
    end

    -----------------------------------------------------------------------
    -- assign orders

    ---@type number[]
    local dummyBatches = {}

    ---@type Unit[]
    local dummyBatchTable = {}

    ---@type table
    local dummyEmptyTable = {}

    ---@type { [1]: Unit }
    local dummyUnitTable = {}

    ---@type { [1]: number, [2]: number, [3]: number }
    local dummyVectorTable = {}

    local distributedOrders = 0
    local unitCount = TableGetn(units)
    for k, group in groups do
        local orderCount = TableGetn(group)

        -- extract info on how to apply these orders
        local commandInfo = UnitQueueDataToCommand[group[1].commandType]
        local commandType = commandInfo.Type
        local issueOrder = commandInfo.Callback
        local redundantOrders = commandInfo.Redundancy or 1
        local batchOrders = commandInfo.BatchOrders
        local fullRedundancy = commandInfo.FullRedundancy

        if issueOrder then

            -- special snowflake implementation for the mobile build order. There's
            -- many ways to break the game when distributing this order therefore
            -- we limit the functionality to make it as least game breaking as possible

            -- assuming that the user didn't do something odd, the order of the order
            -- table and the unit table match up: the 1st unit is close to the 1st
            -- order, the 2nd unit is close to the 2nd order, etc

            if commandType == 'BuildMobile' then
                if orderCount == unitCount then

                    -- this case is simple: assing each unit an order

                    for k, _ in units do
                        local unit = units[k]
                        local order = group[k]
                        dummyUnitTable[1] = unit
                        dummyVectorTable[1] = order.x
                        dummyVectorTable[2] = order.y
                        dummyVectorTable[3] = order.z
                        issueOrder(dummyUnitTable, dummyVectorTable, order.blueprintId, dummyEmptyTable)
                        distributedOrders = distributedOrders + 1
                    end
                elseif orderCount > unitCount then

                    -- this is the usual case, we look over the units and assign each unit
                    -- to multiple orders

                    local start = 1
                    local batches = ComputeBatchCounts(orderCount, unitCount, dummyBatches)
                    for k, batch in batches do
                        dummyUnitTable[1] = units[k]
                        local orderBatch = PopulateBatch(start, batch - 1, group, dummyBatchTable)
                        start = start + batch
                        for _, order in orderBatch do
                            dummyVectorTable[1] = order.x
                            dummyVectorTable[2] = order.y
                            dummyVectorTable[3] = order.z
                            issueOrder(dummyUnitTable, dummyVectorTable, order.blueprintId, dummyEmptyTable)
                            distributedOrders = distributedOrders + 1
                        end
                    end
                else

                    -- this is an odd case, we look over the orders and assign multiple
                    -- units the same order

                    local start = 1
                    local batches = ComputeBatchCounts(unitCount, orderCount, dummyBatches)
                    for k, batch in batches do
                        local order = group[k]
                        dummyVectorTable[1] = order.x
                        dummyVectorTable[2] = order.y
                        dummyVectorTable[3] = order.z

                        local unitBatch = PopulateBatch(start, batch - 1, units, dummyBatchTable)
                        start = start + batch
                        for _, unit in unitBatch do
                            dummyUnitTable[1] = unit
                            issueOrder(dummyUnitTable, dummyVectorTable, order.blueprintId, dummyEmptyTable)
                            distributedOrders = distributedOrders + 1
                        end
                    end
                end
            elseif batchOrders then
                if fullRedundancy then

                    -- in this case we want to introduce as much redundancy as possible

                    local start = 1
                    local batches = ComputeBatchCounts(unitCount, orderCount, dummyBatches)

                    reprsl(batches)

                    -- limit the redundancy to something sane
                    local redundancy = orderCount
                    if redundancy > 10 then
                        redundancy = 10
                    end

                    for k, batch in batches do
                        local direction = 1
                        if MathMod(k, 2) == 0 then
                            direction = -1
                        end

                        for o = 1, redundancy do
                            local index = MathMod((direction * (o - 1) + k) + orderCount, orderCount) + 1
                            local order = group[index]
                            local unitBatch = PopulateBatch(start, batch - 1, units, dummyBatchTable)
                            local targetOrEntity = order.target or PopulateLocation(order, dummyVectorTable)
                            issueOrder(unitBatch, targetOrEntity)
                            distributedOrders = distributedOrders + 1
                        end

                        start = start + batch
                    end
                else
                    if orderCount >= unitCount then

                        -- strange situation where we have more orders than units

                        local start = 1
                        local batches = ComputeBatchCounts(orderCount, unitCount, dummyBatches)
                        for k, batch in batches do
                            dummyUnitTable[1] = units[k]
                            local orderBatch = PopulateBatch(start, batch - 1, group, dummyBatchTable)
                            start = start + batch
                            for _, order in orderBatch do
                                issueOrder(dummyUnitTable, order.target or PopulateLocation(order, dummyVectorTable))
                                distributedOrders = distributedOrders + 1
                            end
                        end
                    else

                        -- usual situation where we have equal or more orders than units

                        local start = 1
                        local batches = ComputeBatchCounts(unitCount, orderCount, dummyBatches)
                        for k, batch in batches do
                            local order = group[k]
                            local unitBatch = PopulateBatch(start, batch - 1, units, dummyBatchTable)
                            start = start + batch
                            issueOrder(unitBatch, order.target or PopulateLocation(order, dummyVectorTable))
                            distributedOrders = distributedOrders + 1
                        end
                    end
                end
            else
                local offset = 0
                -- apply individual orders
                for _, unit in units do
                    -- apply orders
                    for redundancy = 1, MathMin(orderCount, redundantOrders) do
                        local order = group[MathMod(offset, orderCount) + 1]
                        offset = offset + 1
                        dummyUnitTable[1] = unit
                        issueOrder(dummyUnitTable, order.target or PopulateLocation(order, dummyVectorTable))
                        distributedOrders = distributedOrders + 1
                    end
                end
            end
        end
    end

    LOG("Distributed " .. tostring(distributedOrders) .. " orders")
    LOG(string.format("Processing time: %f", GetSystemTimeSecondsOnlyForProfileUse() - start))
end
