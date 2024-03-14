--[[
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
]]
surface.CreateFont("pp_font", {
    font = "Arial",
    size = 20,
    weight = 700,
    shadow = false
})

local blueColor = Color(17, 148, 240, 255)
local blackBlue = Color(17, 148, 240, 100)
local blackColor = Color(50, 50, 50, 200)
local blackGrey = Color(50, 50, 50, 255)

local function pp_open_menu()
    local ply = LocalPlayer()
    local Len = net.ReadFloat()
    local Data = net.ReadData(Len)
    local UnCompress = util.Decompress(Data)
    local Content = util.JSONToTable(UnCompress)
    local Main = vgui.Create("DFrame")
    Main:SetSize(600, 355)
    Main:Center()
    Main:SetTitle("")
    Main:SetVisible(true)
    Main:SetDraggable(true)
    Main:ShowCloseButton(true)
    Main:MakePopup()
    Main.Paint = function(self)
        draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(155, 155, 155, 220))
        surface.SetDrawColor(blueColor)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
        draw.RoundedBox(0, 0, 0, self:GetWide(), 25, Color(17, 148, 240, 200))
        surface.SetDrawColor(blueColor)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), 25)
        draw.DrawText("PermaProps Config", "pp_font", 10, 2.2, color_white, TEXT_ALIGN_LEFT)
    end

    local BSelect
    local PSelect
    local MainPanel = vgui.Create("DPanel", Main)
    MainPanel:SetPos(190, 51)
    MainPanel:SetSize(390, 275)
    MainPanel.Paint = function(self)
        surface.SetDrawColor(blackColor)
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
        surface.DrawOutlinedRect(0, 15, self:GetWide(), 40)
    end

    PSelect = MainPanel
    local MainLabel = vgui.Create("DLabel", MainPanel)
    MainLabel:SetFont("pp_font")
    MainLabel:SetPos(140, 25)
    MainLabel:SetColor(blackGrey)
    MainLabel:SetText("Hey " .. ply:Nick() .. " !")
    MainLabel:SizeToContents()
    local MainLabel2 = vgui.Create("DLabel", MainPanel)
    MainLabel2:SetFont("pp_font")
    MainLabel2:SetPos(80, 80)
    MainLabel2:SetColor(blackGrey)
    MainLabel2:SetText("There are " .. (Content.MProps or 0) .. " props on this map.\n\nThere are " .. (Content.TProps or 0) .. " props in the DB.")
    MainLabel2:SizeToContents()
    local RemoveMapProps = vgui.Create("DButton", MainPanel)
    RemoveMapProps:SetText(" Clear map props ")
    RemoveMapProps:SetFont("pp_font")
    RemoveMapProps:SetSize(370, 30)
    RemoveMapProps:SetPos(10, 160)
    RemoveMapProps:SetTextColor(blackGrey)
    RemoveMapProps.DoClick = function()
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "CLR_MAP"
        })

        net.SendToServer()
    end

    RemoveMapProps.Paint = function(self)
        surface.SetDrawColor(blackGrey)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
    end

    local ClearMapProps = vgui.Create("DButton", MainPanel)
    ClearMapProps:SetText(" Clear map props in the DB ")
    ClearMapProps:SetFont("pp_font")
    ClearMapProps:SetSize(370, 30)
    ClearMapProps:SetPos(10, 200)
    ClearMapProps:SetTextColor(blackGrey)
    ClearMapProps.DoClick = function()
        Derma_Query("Are you sure you want clear map props in the db ?\nYou can't undo this action !", "PermaProps 4.0", "Yes", function()
            net.Start("pp_info_send")
            net.WriteTable({
                CMD = "DEL_MAP"
            })

            net.SendToServer()
        end, "Cancel")
    end

    ClearMapProps.Paint = function(self)
        surface.SetDrawColor(blackGrey)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
    end

    local ClearAllProps = vgui.Create("DButton", MainPanel)
    ClearAllProps:SetText(" Clear all props in the DB ")
    ClearAllProps:SetFont("pp_font")
    ClearAllProps:SetSize(370, 30)
    ClearAllProps:SetPos(10, 240)
    ClearAllProps:SetTextColor(blackGrey)
    ClearAllProps.DoClick = function()
        Derma_Query("Are you sure you want clear all props in the db ?\nYou can't undo this action !", "PermaProps 4.0", "Yes", function()
            net.Start("pp_info_send")
            net.WriteTable({
                CMD = "DEL_ALL"
            })

            net.SendToServer()
        end, "Cancel")
    end

    ClearAllProps.Paint = function(self)
        surface.SetDrawColor(blackGrey)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
    end

    local BMain = vgui.Create("DButton", Main)
    BSelect = BMain
    BMain:SetText("Main")
    BMain:SetFont("pp_font")
    BMain:SetSize(160, 50)
    BMain:SetPos(15, 27 + 25)
    BMain:SetTextColor(color_white)
    BMain.PaintColor = blackBlue
    BMain.Paint = function(self)
        draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), self.PaintColor)
        surface.SetDrawColor(blueColor)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
    end

    BMain.DoClick = function(self)
        if BSelect then BSelect.PaintColor = color_black end
        BSelect = self
        self.PaintColor = blackBlue
        if PSelect then PSelect:Hide() end
        MainPanel:Show()
        PSelect = MainPanel
    end

    local ConfigPanel = vgui.Create("DPanel", Main)
    ConfigPanel:SetPos(190, 51)
    ConfigPanel:SetSize(390, 275)
    ConfigPanel.Paint = function(self)
        surface.SetDrawColor(blackColor)
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    end

    ConfigPanel:Hide()
    local CheckCustom = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckCustom:SetPos(5, 30)
    CheckCustom:SetText("Custom permissions")
    CheckCustom:SetValue(0)
    CheckCustom:SizeToContents()
    CheckCustom:SetTextColor(color_black)
    CheckCustom:SetDisabled(true)
    local GroupsList = vgui.Create("DComboBox", ConfigPanel)
    GroupsList:SetPos(5, 5)
    GroupsList:SetSize(125, 20)
    GroupsList:SetValue("Select a group...")
    local CheckBox1 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox1:SetPos(150, 10)
    CheckBox1:SetText("Menu")
    CheckBox1:SizeToContents()
    CheckBox1:SetTextColor(color_black)
    CheckBox1:SetDisabled(true)
    CheckBox1.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Menu",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local CheckBox2 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox2:SetPos(150, 30)
    CheckBox2:SetText("Edit permissions")
    CheckBox2:SizeToContents()
    CheckBox2:SetTextColor(color_black)
    CheckBox2:SetDisabled(true)
    CheckBox2.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Permissions",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local CheckBox3 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox3:SetPos(150, 50)
    CheckBox3:SetText("Physgun permaprops")
    CheckBox3:SizeToContents()
    CheckBox3:SetTextColor(color_black)
    CheckBox3:SetDisabled(true)
    CheckBox3.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Physgun",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local CheckBox4 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox4:SetPos(150, 70)
    CheckBox4:SetText("Tool permaprops")
    CheckBox4:SizeToContents()
    CheckBox4:SetTextColor(color_black)
    CheckBox4:SetDisabled(true)
    CheckBox4.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Tool",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local CheckBox5 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox5:SetPos(150, 90)
    CheckBox5:SetText("Property permaprops")
    CheckBox5:SizeToContents()
    CheckBox5:SetTextColor(color_black)
    CheckBox5:SetDisabled(true)
    CheckBox5.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Property",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local CheckBox6 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox6:SetPos(150, 110)
    CheckBox6:SetText("Save props")
    CheckBox6:SizeToContents()
    CheckBox6:SetTextColor(color_black)
    CheckBox6:SetDisabled(true)
    CheckBox6.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Save",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local CheckBox7 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox7:SetPos(150, 130)
    CheckBox7:SetText("Delete permaprops")
    CheckBox7:SizeToContents()
    CheckBox7:SetTextColor(color_black)
    CheckBox7:SetDisabled(true)
    CheckBox7.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Delete",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local CheckBox8 = vgui.Create("DCheckBoxLabel", ConfigPanel)
    CheckBox8:SetPos(150, 150)
    CheckBox8:SetText("Update permaprops")
    CheckBox8:SizeToContents()
    CheckBox8:SetTextColor(color_black)
    CheckBox8:SetDisabled(true)
    CheckBox8.OnChange = function(Self, Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Update",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    GroupsList.OnSelect = function(panel, index, value)
        CheckCustom:SetDisabled(false)
        CheckCustom:SetChecked(Content.Permissions[value].Custom)
        CheckBox1:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox1:SetChecked(Content.Permissions[value].Menu)
        CheckBox2:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox2:SetChecked(Content.Permissions[value].Permissions)
        CheckBox3:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox3:SetChecked(Content.Permissions[value].Physgun)
        CheckBox4:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox4:SetChecked(Content.Permissions[value].Tool)
        CheckBox5:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox5:SetChecked(Content.Permissions[value].Property)
        CheckBox6:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox6:SetChecked(Content.Permissions[value].Save)
        CheckBox7:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox7:SetChecked(Content.Permissions[value].Delete)
        CheckBox8:SetDisabled(not Content.Permissions[value].Custom)
        CheckBox8:SetChecked(Content.Permissions[value].Update)
    end

    for k, v in pairs(Content.Permissions) do
        GroupsList:AddChoice(k)
    end

    CheckCustom.OnChange = function(Self, Value)
        CheckBox1:SetDisabled(not Value)
        CheckBox2:SetDisabled(not Value)
        CheckBox3:SetDisabled(not Value)
        CheckBox4:SetDisabled(not Value)
        CheckBox5:SetDisabled(not Value)
        CheckBox6:SetDisabled(not Value)
        CheckBox7:SetDisabled(not Value)
        CheckBox8:SetDisabled(not Value)
        net.Start("pp_info_send")
        net.WriteTable({
            CMD = "VAR",
            Val = Value,
            Data = "Custom",
            Name = GroupsList:GetValue()
        })

        net.SendToServer()
    end

    local BConfig = vgui.Create("DButton", Main)
    BConfig:SetText("Configuration")
    BConfig:SetFont("pp_font")
    BConfig:SetSize(160, 50)
    BConfig:SetPos(15, 126)
    BConfig:SetTextColor(color_white)
    BConfig.PaintColor = color_black
    BConfig.Paint = function(self)
        draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), self.PaintColor)
        surface.SetDrawColor(blueColor)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
    end

    BConfig.DoClick = function(self)
        if BSelect then BSelect.PaintColor = color_black end
        BSelect = self
        self.PaintColor = blackBlue
        if PSelect then PSelect:Hide() end
        ConfigPanel:Show()
        PSelect = ConfigPanel
    end

    local PropsPanel = vgui.Create("DPanel", Main)
    PropsPanel:SetPos(190, 51)
    PropsPanel:SetSize(390, 275)
    PropsPanel.Paint = function(self)
        surface.SetDrawColor(blackColor)
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    end

    PropsPanel:Hide()
    local PropsList = vgui.Create("DListView", PropsPanel)
    PropsList:SetMultiSelect(false)
    PropsList:SetSize(390, 275)
    local ColID = PropsList:AddColumn("ID")
    -- local ColEnt = PropsList:AddColumn("Entity")
    -- local ColMdl = PropsList:AddColumn("Model")
    ColID:SetMinWidth(50)
    ColID:SetMaxWidth(50)
    PropsList.Paint = function(self) surface.SetDrawColor(blueColor) end
    PropsList.OnRowRightClick = function(panel, line)
        local MenuButtonOptions = DermaMenu()
        MenuButtonOptions:AddOption("Draw entity", function()
            if not ply.DrawPPEnt or not istable(ply.DrawPPEnt) then ply.DrawPPEnt = {} end
            if ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)] and ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)]:IsValid() then return end
            local ent = ents.CreateClientProp(Content.PropsList[PropsList:GetLine(line):GetValue(1)].Model)
            ent:SetPos(Content.PropsList[PropsList:GetLine(line):GetValue(1)].Pos)
            ent:SetAngles(Content.PropsList[PropsList:GetLine(line):GetValue(1)].Angle)
            ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)] = ent
        end)

        if ply.DrawPPEnt and ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)] then
            MenuButtonOptions:AddOption("Stop Drawing", function()
                ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)]:Remove()
                ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)] = nil
            end)
        end

        if ply.DrawPPEnt ~= nil and istable(ply.DrawPPEnt) and table.Count(ply.DrawPPEnt) > 0 then
            MenuButtonOptions:AddOption("Stop Drawing All", function()
                for k, v in pairs(ply.DrawPPEnt) do
                    ply.DrawPPEnt[k]:Remove()
                    ply.DrawPPEnt[k] = nil
                end
            end)
        end

        MenuButtonOptions:AddOption("Remove", function()
            net.Start("pp_info_send")
            net.WriteTable({
                CMD = "DEL",
                Val = PropsList:GetLine(line):GetValue(1)
            })

            net.SendToServer()
            if ply.DrawPPEnt and ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)] ~= nil then
                ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)]:Remove()
                ply.DrawPPEnt[PropsList:GetLine(line):GetValue(1)] = nil
            end

            PropsList:RemoveLine(line)
        end)

        MenuButtonOptions:Open()
    end

    for k, v in pairs(Content.PropsList) do
        PropsList:AddLine(k, v.Class, v.Model)
    end

    local BProps = vgui.Create("DButton", Main)
    BProps:SetText("Props List")
    BProps:SetFont("pp_font")
    BProps:SetSize(160, 50)
    BProps:SetPos(15, 115 + 85)
    BProps:SetTextColor(color_white)
    BProps.PaintColor = color_black
    BProps.Paint = function(self)
        draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), self.PaintColor)
        surface.SetDrawColor(blueColor)
        surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
    end

    BProps.DoClick = function(self)
        if BSelect then BSelect.PaintColor = color_black end
        BSelect = self
        self.PaintColor = blackBlue
        if PSelect then PSelect:Hide() end
        PropsPanel:Show()
        PSelect = PropsPanel
    end
end

net.Receive("pp_open_menu", pp_open_menu)
