local language_Add = CLIENT and language.Add
local surface_CreateFont = CLIENT and surface.CreateFont
local hook_Run = hook.Run
local tonumber = tonumber
local sql_QueryValue = sql.QueryValue
local sql_SQLStr = sql.SQLStr
local game_GetMap = game.GetMap
local util_TableToJSON = util.TableToJSON
local surface_SetDrawColor = CLIENT and surface.SetDrawColor
local surface_DrawRect = CLIENT and surface.DrawRect
local surface_SetFont = CLIENT and surface.SetFont
local surface_GetTextSize = CLIENT and surface.GetTextSize
local draw_SimpleText = CLIENT and draw.SimpleText
local Color = Color
--[[
	PermaProps
	Created by Entoros, June 2010
	Facepunch: http://www.facepunch.com/member.php?u=180808
	Modified By Malboro 28 / 12 / 2012
	
	Ideas:
		Make permaprops cleanup-able
		
	Errors:
		Errors on die

	Remake:
		By Malboro the 28/12/2012
]]
TOOL.Category = "Props Tool"
TOOL.Name = "PermaProps"
TOOL.Command = nil
TOOL.ConfigName = ""
if CLIENT then
    language_Add("Tool.permaprops.name", "PermaProps")
    language_Add("Tool.permaprops.desc", "Save a props permanently")
    language_Add("Tool.permaprops.0", "LeftClick: Add RightClick: Remove Reload: Update")
    surface_CreateFont("PermaPropsToolScreenFont", {
        font = "Arial",
        size = 40,
        weight = 1000,
        antialias = true,
        additive = false
    })

    surface_CreateFont("PermaPropsToolScreenSubFont", {
        font = "Arial",
        size = 30,
        weight = 1000,
        antialias = true,
        additive = false
    })
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    local ent = trace.Entity
    local ply = self:GetOwner()
    if not PermaProps then
        ply:ChatPrint("ERROR: Lib not found")
        return
    end

    if not PermaProps.HasPermission(ply, "Save") then return end
    if not ent:IsValid() then
        ply:ChatPrint("That is not a valid entity !")
        return
    end

    if ent:IsPlayer() then
        ply:ChatPrint("That is a player !")
        return
    end

    if ent.PermaProps then
        ply:ChatPrint("That entity is already permanent !")
        return
    end

    local canPermaProp = hook_Run("PermaProps.CanPermaProp", ply, ent, self)
    if canPermaProp ~= nil and canPermaProp == false then return end
    local content = PermaProps.PPGetEntTable(ent)
    if not content then return end
    local max = tonumber(sql_QueryValue("SELECT MAX(id) FROM permaprops;"))
    if not max then
        max = 1
    else
        max = max + 1
    end

    local new_ent = PermaProps.PPEntityFromTable(content, max)
    if not new_ent or not new_ent:IsValid() then return end
    PermaProps.SparksEffect(ent)
    local query = ("INSERT INTO permaprops (id, map, content) VALUES(NULL, %s, %s);"):format(sql_SQLStr(game_GetMap()), sql_SQLStr(util_TableToJSON(content)))
    PermaProps.SQL.Query(query)
    local chatMsg = ("You saved %s with model %s to the database."):format(ent:GetClass(), ent:GetModel())
    ply:ChatPrint(chatMsg)
    ent:Remove()
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    local ent = trace.Entity
    local ply = self:GetOwner()
    if not PermaProps then
        ply:ChatPrint("ERROR: Lib not found")
        return
    end

    if not PermaProps.HasPermission(ply, "Delete") then return end
    if not ent:IsValid() then
        ply:ChatPrint("That is not a valid entity !")
        return
    end

    if ent:IsPlayer() then
        ply:ChatPrint("That is a player !")
        return
    end

    if not ent.PermaProps then
        ply:ChatPrint("That is not a PermaProp !")
        return
    end

    if not ent.PermaProps_ID then
        ply:ChatPrint("ERROR: ID not found")
        return
    end

    local queryEraseModelDatabase = ("DELETE FROM permaprops WHERE id = %s;"):format(ent.PermaProps_ID)
    PermaProps.SQL.Query(queryEraseModelDatabase)
    ply:ChatPrint("You erased " .. ent:GetClass() .. " with a model of " .. ent:GetModel() .. " from the database.")
    ent:Remove()
    return true
end

function TOOL:Reload(trace)
    if CLIENT then return true end
    if not PermaProps then
        self:GetOwner():ChatPrint("ERROR: Lib not found")
        return
    end

    if not trace.Entity:IsValid() and PermaProps.HasPermission(self:GetOwner(), "Update") then
        self:GetOwner():ChatPrint("You have reload all PermaProps !")
        PermaProps.ReloadPermaProps()
        return false
    end

    if trace.Entity.PermaProps then
        local ent = trace.Entity
        local ply = self:GetOwner()
        if not PermaProps.HasPermission(ply, "Update") then return end
        if ent:IsPlayer() then
            ply:ChatPrint("That is a player !")
            return
        end

        local content = PermaProps.PPGetEntTable(ent)
        if not content then return end
        local updateContentQuery = ("UPDATE permaprops set content = %s WHERE id = %s AND map = %s;"):format(sql_SQLStr(util_TableToJSON(content)), ent.PermaProps_ID, sql_SQLStr(game_GetMap()))
        PermaProps.SQL.Query(updateContentQuery)
        local new_ent = PermaProps.PPEntityFromTable(content, ent.PermaProps_ID)
        if not new_ent or not new_ent:IsValid() then return end
        PermaProps.SparksEffect(ent)
        ply:ChatPrint("You updated the " .. ent:GetClass() .. " in the database.")
        ent:Remove()
    else
        return false
    end
    return true
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {
        Text = "PermaProps",
        Description = "PermaProps\n\nSaves entities across map changes\n"
    })

    panel:AddControl("Button", {
        Label = "Open Configuration Menu",
        Command = "pp_cfg_open"
    })
end

function TOOL:DrawToolScreen(width, height)
    if SERVER then return end
    local whiteColor = Color(224, 224, 224, 255)
    local blueColor = Color(17, 148, 240, 255)
    surface_SetDrawColor(blueColor)
    surface_DrawRect(0, 0, 256, 256)
    surface_SetFont("PermaPropsToolScreenFont")
    local w, h = surface_GetTextSize(" ")
    surface_SetFont("PermaPropsToolScreenSubFont")
    local w2, h2 = surface_GetTextSize(" ")
    draw_SimpleText("PermaProps", "PermaPropsToolScreenFont", 128, 100, whiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, blueColor, 4)
    draw_SimpleText("By Malboro", "PermaPropsToolScreenSubFont", 128, 128 + (h + h2) / 2 - 4, whiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, blueColor, 4)
end
