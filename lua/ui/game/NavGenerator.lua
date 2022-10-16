
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local Window = import('/lua/maui/window.lua').Window
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Combo = import('/lua/ui/controls/combo.lua').Combo

local Shared = import('/lua/shared/NavGenerator.lua')

local Root = nil
local DebugInterface = false 

---@alias NavUIStates 'overview' | 'actions'

---@class NavUIOverview : Group
NavUIOverview = Class(Group) {
    __init = function(self, parent) 
        Group.__init(self, parent, 'NavUIOverview')
    end
}

---@class NavUICanPathTo : Group
NavUICanPathTo = Class(Group) {
    __init = function (self, parent)
        local name = 'NavUICanPathTo'
        Group.__init(self, parent, 'NavUICanPathTo')

        self.Background = LayoutHelpers.LayoutFor(Bitmap(self))
            :Fill(self)
            :Color('77000000')
            :DisableHitTest(true)
            :End()

        ---@type Text
        self.Title = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, 'Debug \'CanPathTo\'', 8, UIUtil.bodyFont))
            :AtLeftTopIn(self, 10, 10)
            :Over(self, 1)
            :End()


        self.ButtonOrigin = LayoutHelpers.LayoutFor(UIUtil.CreateButtonWithDropshadow(self, '/BUTTON/medium/', "Origin"))
            :AtLeftBottomIn(self.Background, -5, 5)
            :Over(self, 1)
            :End()

        self.ButtonOrigin.OnClick = function()

            -- make sure we have nothing selected
            local selection = GetSelectedUnits()
            SelectUnits(nil);

            -- enables command mode for spawning units
            import('/lua/ui/game/commandmode.lua').StartCommandMode(
                "build",
                {
                    -- default information required
                    name = 'ual0105',

                    --- 
                    ---@param mode CommandModeDataBuild
                    ---@param command any
                    callback = function(mode, command)
                        SimCallback({Func = 'NavDebugCanPathToOrigin', Args = { 
                            Location = command.Target.Position,
                            Layer = Shared.Layers[self.ComboLayer:GetItem()]
                        }})
                        SelectUnits(selection)
                    end,
                }
            )
        end

        self.ButtonDestination = LayoutHelpers.LayoutFor(UIUtil.CreateButtonWithDropshadow(self, '/BUTTON/medium/', "Destination"))
            :RightOf(self.ButtonOrigin, -20)
            :Over(self, 1)
            :End()

        self.ButtonDestination.OnClick = function()
            -- make sure we have nothing selected
            local selection = GetSelectedUnits()
            SelectUnits(nil);

            -- enables command mode for spawning units
            import('/lua/ui/game/commandmode.lua').StartCommandMode(
                "build",
                {
                    -- default information required
                    name = 'ual0105',

                    --- 
                    ---@param mode CommandModeDataBuild
                    ---@param command any
                    callback = function(mode, command)
                        SimCallback({Func = 'NavDebugCanPathToDestination', Args = { 
                            Location = command.Target.Position,
                            Layer = Shared.Layers[self.ComboLayer:GetItem()]
                        }})
                        SelectUnits(selection)
                    end,
                }
            )
        end

        self.LabelLayer = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, 'For layer:', 8, UIUtil.bodyFont))
            :RightOf(self.ButtonDestination)
            :Top(function() return self.ButtonDestination.Top() + LayoutHelpers.ScaleNumber(6) end)
            :Over(self, 1)
            :End()

        ---@type Combo
        self.ComboLayer = LayoutHelpers.LayoutFor(Combo(self, 14, 10, nil, nil, "UI_Tab_Click_01", "UI_Tab_Rollover_01"))
            :RightOf(self.ButtonDestination)
            :Top(function() return self.ButtonDestination.Top() + LayoutHelpers.ScaleNumber(18) end)
            :Width(100)
            :End()

        self.ComboLayer:AddItems(Shared.Layers)
        self.ComboLayer:SetItem(1)
        self.ComboLayer.OnClick = function(self, index, text)
            SimCallback({Func = 'NavDebugCanPathToRerun', Args = { Layer =  Shared.Layers[index] }})
        end

        self.ButtonRerun = LayoutHelpers.LayoutFor(UIUtil.CreateButtonWithDropshadow(self, '/BUTTON/medium/', "Rerun"))
            :RightOf(self.ComboLayer)
            :Top(self.ButtonDestination.Top)
            :Over(self, 1)
            :End()

        self.ButtonRerun.OnClick = function()
            SimCallback({Func = 'NavDebugCanPathToRerun', Args = { Layer = Shared.Layers[self.ComboLayer.GetItem()] }})
        end

        self.ButtonReset = LayoutHelpers.LayoutFor(UIUtil.CreateButtonWithDropshadow(self, '/BUTTON/medium/', "Reset"))
            :RightOf(self.ButtonRerun, -20)
            :Over(self, 1)
            :End()

        self.ButtonReset.OnClick = function()
            SimCallback({Func = 'NavDebugCanPathToReset', Args = { }})
        end

        AddOnSyncCallback(
            function(Sync)
                if Sync.NavCanPathToDebug then
                    local data = Sync.NavCanPathToDebug

                    if data.Ok then
                        self.Title:SetText(string.format('Debug \'CanPathTo\': %s', tostring(data.Ok)))
                    else 
                        self.Title:SetText(string.format('Debug \'CanPathTo\': %s (%s)', tostring(data.Ok), data.Msg))
                    end
                end
            end, name
        )
    end,
}

---@class NavUILayerStatistics : Group
NavUILayerStatistics = Class(Group) {
    __init = function(self, parent, layer)
        local name = 'NavUILayerStatistics - ' .. tostring(layer)
        Group.__init(self, parent, 'NavUILayerStatistics - ' .. tostring(layer))

        self.Background = LayoutHelpers.LayoutFor(Bitmap(self))
            :Fill(self)
            :Color('77' .. Shared.LayerColors[layer])
            :DisableHitTest(true)
            :End()

        ---@type Text
        self.Title = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, string.format('Layer: %s', layer), 8, UIUtil.bodyFont))
            :AtLeftTopIn(self, 10, 10)
            :Over(self, 1)
            :End()

        ---@type Text
        self.Subdivisions = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, 'Subdivisions: 0', 11, UIUtil.bodyFont))
            :Below(self.Title, 2)
            :Over(self, 1)
            :End()

        ---@type Text
        self.PathableLeafs = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, 'PathableLeafs: 0', 11, UIUtil.bodyFont))
            :Below(self.Subdivisions)
            :Over(self, 1)
            :End()

        ---@type Text
        self.UnpathableLeafs = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, 'UnpathableLeafs: 0', 11, UIUtil.bodyFont))
            :Below(self.PathableLeafs)
            :Over(self, 1)
            :End()

        ---@type Text
        self.Neighbors = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, 'Neighbors: 0', 11, UIUtil.bodyFont))
            :Below(self.UnpathableLeafs)
            :Over(self, 1)
            :End()

        ---@type Text
        self.Labels = LayoutHelpers.LayoutFor(UIUtil.CreateText(self, 'Labels: 0', 11, UIUtil.bodyFont))
            :Below(self.Neighbors)
            :Over(self, 1)
            :End()

        self.ToggleScanButton = LayoutHelpers.LayoutFor(UIUtil.CreateButtonStd(self, '/game/mfd_btn/control', nil, nil, nil, nil, 'UI_Tab_Click_01', 'UI_Tab_Rollover_01'))
            :AtRightTopIn(self)
            :Width(24)
            :Height(16)
            :Over(self, 1)
            :End()

        self.ToggleScanButton.OnClick = function()
            SimCallback({ Func = string.format("NavToggle%sScan", layer), Args = { }}, false)
        end

        AddOnSyncCallback(
            function(Sync)
                if Sync.NavLayerData then
                    ---@type NavLayerData
                    local data = Sync.NavLayerData

                    self.Subdivisions:SetText(string.format('Subdivisions: %d', data[layer].Subdivisions))
                    self.PathableLeafs:SetText(string.format('PathableLeafs: %d', data[layer].PathableLeafs))
                    self.UnpathableLeafs:SetText(string.format('UnpathableLeafs: %d', data[layer].UnpathableLeafs))
                    self.Neighbors:SetText(string.format('Neighbors: %d', data[layer].Neighbors))
                    self.Labels:SetText(string.format('Labels: %d', data[layer].Labels))
                end
            end, name
        )
    end,
}

---@class NavUIActions : Group
NavUIActions = Class(Group) {
    __init = function(self, parent) 
        Group.__init(self, parent, 'NavUIActions')

        self.Debug = LayoutHelpers.LayoutFor(Group(GetFrame(0)))
            :Fill(self)
            :End()

        self.BodyGenerate = LayoutHelpers.LayoutFor(Group(self))
            :Left(function() return self.Left() + LayoutHelpers.ScaleNumber(10) end)
            :Right(function() return self.Left() + LayoutHelpers.ScaleNumber(180) end)
            :Top(function() return self.Top() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.Bottom() - LayoutHelpers.ScaleNumber(10) end)
            :Over(self, 1)
            :End()

        UIUtil.SurroundWithBorder(self.BodyGenerate, '/scx_menu/lan-game-lobby/frame/')

        LayoutHelpers.LayoutFor(Bitmap(self.Debug))
            :Fill(self.BodyGenerate)
            :Color('99999999')
            :End()

        self.StatisticsLand = LayoutHelpers.LayoutFor(NavUILayerStatistics(self, 'Land'))
            :Left(function() return self.BodyGenerate.Left() + LayoutHelpers.ScaleNumber(10) end)
            :Right(function() return self.BodyGenerate.Right() - LayoutHelpers.ScaleNumber(10) end)
            :Top(function() return self.BodyGenerate.Top() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.BodyGenerate.Top() + LayoutHelpers.ScaleNumber(100) end)
            :Over(self, 1)
            :End()

        self.StatisticsAmph = LayoutHelpers.LayoutFor(NavUILayerStatistics(self, 'Amphibious'))
            :Left(function() return self.BodyGenerate.Left() + LayoutHelpers.ScaleNumber(10) end)
            :Right(function() return self.BodyGenerate.Right() - LayoutHelpers.ScaleNumber(10) end)
            :Top(function() return self.StatisticsLand.Bottom() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.StatisticsLand.Bottom() + LayoutHelpers.ScaleNumber(100) end)
            :Over(self, 1)
            :End()

        self.StatisticsHover = LayoutHelpers.LayoutFor(NavUILayerStatistics(self, 'Hover'))
            :Left(function() return self.BodyGenerate.Left() + LayoutHelpers.ScaleNumber(10) end)
            :Right(function() return self.BodyGenerate.Right() - LayoutHelpers.ScaleNumber(10) end)
            :Top(function() return self.StatisticsAmph.Bottom() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.StatisticsAmph.Bottom() + LayoutHelpers.ScaleNumber(100) end)
            :Over(self, 1)
            :End()

        self.StatisticsNaval = LayoutHelpers.LayoutFor(NavUILayerStatistics(self, 'Water'))
            :Left(function() return self.BodyGenerate.Left() + LayoutHelpers.ScaleNumber(10) end)
            :Right(function() return self.BodyGenerate.Right() - LayoutHelpers.ScaleNumber(10) end)
            :Top(function() return self.StatisticsHover.Bottom() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.StatisticsHover.Bottom() + LayoutHelpers.ScaleNumber(100) end)
            :Over(self, 1)
            :End()

        self.StatisticsAir = LayoutHelpers.LayoutFor(NavUILayerStatistics(self, 'Air'))
            :Left(function() return self.BodyGenerate.Left() + LayoutHelpers.ScaleNumber(10) end)
            :Right(function() return self.BodyGenerate.Right() - LayoutHelpers.ScaleNumber(10) end)
            :Top(function() return self.StatisticsNaval.Bottom() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.StatisticsNaval.Bottom() + LayoutHelpers.ScaleNumber(100) end)
            :Over(self, 1)
            :End()

        self.ButtonGenerate = LayoutHelpers.LayoutFor(UIUtil.CreateButtonWithDropshadow(self.BodyGenerate, '/BUTTON/medium/', "Generate"))
            :CenteredBelow(self.StatisticsAir, 10)
            :Over(self.BodyGenerate, 1)
            :End()

        self.ButtonGenerate.OnClick = function()
            SimCallback({ Func = 'NavGenerate', Args = { }}, false)
        end

        self.BodyDebug = LayoutHelpers.LayoutFor(Group(self))
            :Left(function() return self.BodyGenerate.Right() + LayoutHelpers.ScaleNumber(20) end)
            :Right(function() return self.Right() - LayoutHelpers.ScaleNumber(10) end)
            :Top(function() return self.Top() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.Bottom() - LayoutHelpers.ScaleNumber(10) end)
            :Over(self, 1)
            :End()

        UIUtil.SurroundWithBorder(self.BodyDebug, '/scx_menu/lan-game-lobby/frame/')

        self.NavUICanPathTo = LayoutHelpers.LayoutFor(NavUICanPathTo(self))
            :Left(function() return self.BodyDebug.Left() + LayoutHelpers.ScaleNumber(10) end)
            :Right(function() return self.BodyDebug.Right() - LayoutHelpers.ScaleNumber(10) end)
            :Top(function() return self.BodyDebug.Top() + LayoutHelpers.ScaleNumber(10) end)
            :Bottom(function() return self.BodyDebug.Top() + LayoutHelpers.ScaleNumber(85) end)
            :End()

        self.Debug:DisableHitTest(true)
        if not DebugInterface then
            self.Debug:Hide()
        end
    end,    
}

---@class NavUI : Window
NavUI = Class(Window) {

    __init = function(self, parent)

        -- prepare base class

        Window.__init(self, parent, "NavUI", false, false, false, true, false, "NavUI5", {
            Left = 10,
            Top = 300,
            Right = 830,
            Bottom = 910
        })

        LayoutHelpers.DepthOverParent(self, parent, 1)
        self._border = UIUtil.SurroundWithBorder(self, '/scx_menu/lan-game-lobby/frame/')

        -- prepare this class

        self.Background = LayoutHelpers.LayoutFor(Bitmap(self))
            :Fill(self)
            :Color('22ffffff')
            :End()

        self.Debug = LayoutHelpers.LayoutFor(Group(GetFrame(0)))
            :Fill(self)
            :End()

        self.Header = LayoutHelpers.LayoutFor(Group(self))
            :Left(self.Left)
            :Right(self.Right)
            :Top(self.Top)
            :Bottom(function() return self.Top() + LayoutHelpers.ScaleNumber(25) end)
            :End()

        self.Body = LayoutHelpers.LayoutFor(Group(self))
            :Left(self.Left)
            :Right(self.Right)
            :Top(function() return self.Header.Bottom() + LayoutHelpers.ScaleNumber(4) end)
            :Bottom(self.Bottom)
            :End()

        LayoutHelpers.LayoutFor(Bitmap(self.Debug))
            :Fill(self.Body)
            :Color('9999ff99')
            :End() 

        -- prepare header



        -- prepare body

        -- self.NavUIOverview = LayoutHelpers.LayoutFor(NavUIOverview(self.Body))
        --     :Fill(self.Body)
        --     :End()

        self.NavUIActions = LayoutHelpers.LayoutFor(NavUIActions(self.Body))
            :Fill(self.Body)
            :End()

        self.Debug:DisableHitTest(true)
        if not DebugInterface then
            self.Debug:Hide()
        end

        LOG(math.mod(10, 4))
    end,

    ---comment
    ---@param self any
    ---@param identifier any
    SwitchState = function(self, identifier)

    end,

    OnClose = function(self)
        self:Hide()
    end,
}

function OpenWindow()
    if Root then
        Root:Show()
    else
        Root = NavUI(GetFrame(0))
        Root:Show()
    end
end

function CloseWindow()
    if Root then
        Root:Hide()
    end
end

--- Called by the module manager when this module is dirty due to a disk change
function __OnDirtyModule()
    if Root then
        Root:Destroy()
    end
end