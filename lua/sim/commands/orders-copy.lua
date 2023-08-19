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

local UnitQueueDataToCommand = import("/lua/sim/commands/orders-shared.lua").UnitQueueDataToCommand
local PopulateLocation = import("/lua/sim/commands/orders-shared.lua").PopulateLocation

---@type table
local dummyEmptyTable = {}

---@type { [1]: number, [2]: number, [3]: number }
local dummyVectorTable = {}

---@type { [1]: Unit }
local dummyUnitTable = {}

--- Copies the command queue of the target. Has a special snowflake implementation for build orders to prevent too many previews
---@param units Unit[]
---@param target Unit
CopyOrders = function(units, target, clearCommands)

    -- retrieve queue of target
    local unitCount = table.getn(units)
    local queue = target:GetCommandQueue()

    if clearCommands then
        IssueClearCommands(units)
    end

    -- copy the orders of the target
    for _, order in queue do
        local commandInfo = UnitQueueDataToCommand[order.commandType]
        local commandName = commandInfo.Type
        local issueOrder = commandInfo.Callback
        if issueOrder then
            if commandName == 'BuildMobile' then
                dummyUnitTable[1] = units[1]
                issueOrder(dummyUnitTable, PopulateLocation(order, dummyVectorTable), order.blueprintId, dummyEmptyTable)
                if unitCount > 1 then
                    IssueGuard(units, units[1])
                end
            else
                issueOrder(units, order.target or PopulateLocation(order, dummyVectorTable))
            end
        end
    end
end
