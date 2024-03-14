local util_AddNetworkString = util.AddNetworkString
local pairs = pairs
local file_Exists = file.Exists
local file_Delete = file.Delete
local file_Read = file.Read
local util_JSONToTable = util.JSONToTable
local table_Merge = table.Merge
local hook_Add = hook.Add
local file_Write = file.Write
local util_TableToJSON = util.TableToJSON
local game_GetMap = game.GetMap
local tonumber = tonumber
local util_Compress = util.Compress
local net_Start = net.Start
local net_WriteFloat = net.WriteFloat
local net_WriteData = net.WriteData
local net_Send = net.Send
local concommand_Add = concommand.Add
local net_ReadTable = net.ReadTable
local ents_Iterator = ents.Iterator
local isbool = isbool
local net_Receive = net.Receive

--[[
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
]]
util_AddNetworkString("pp_open_menu")
util_AddNetworkString("pp_info_send")
local function PermissionLoad()
    if not PermaProps then PermaProps = {} end
    if not PermaProps.Permissions then PermaProps.Permissions = {} end
    PermaProps.Permissions["superadmin"] = {
        Physgun = true,
        Tool = true,
        Property = true,
        Save = true,
        Delete = true,
        Update = true,
        Menu = true,
        Permissions = true,
        Inherits = "admin",
        Custom = true
    }

    PermaProps.Permissions["admin"] = {
        Physgun = false,
        Tool = false,
        Property = false,
        Save = true,
        Delete = true,
        Update = true,
        Menu = true,
        Permissions = false,
        Inherits = "user",
        Custom = true
    }

    PermaProps.Permissions["user"] = {
        Physgun = false,
        Tool = false,
        Property = false,
        Save = false,
        Delete = false,
        Update = false,
        Menu = false,
        Permissions = false,
        Inherits = "user",
        Custom = true
    }

    if CAMI then
        for k, v in pairs(CAMI.GetUsergroups()) do
            if k == "superadmin" or k == "admin" or k == "user" then continue end
            PermaProps.Permissions[k] = {
                Physgun = false,
                Tool = false,
                Property = false,
                Save = false,
                Delete = false,
                Update = false,
                Menu = false,
                Permissions = false,
                Inherits = v.Inherits,
                Custom = false
            }
        end
    end

    if file_Exists("permaprops_config.txt", "DATA") then file_Delete("permaprops_config.txt") end
    if file_Exists("permaprops_permissions.txt", "DATA") then
        local content = file_Read("permaprops_permissions.txt", "DATA")
        local tablecontent = util_JSONToTable(content)
        for k, v in pairs(tablecontent) do
            if PermaProps.Permissions[k] == nil then tablecontent[k] = nil end
        end

        table_Merge(PermaProps.Permissions, tablecontent or {})
    end
end

hook_Add("Initialize", "PermaPropPermLoad", PermissionLoad)
hook_Add("CAMI.OnUsergroupRegistered", "PermaPropPermLoadCAMI", PermissionLoad) -- In case something changes
local function PermissionSave()
    file_Write("permaprops_permissions.txt", util_TableToJSON(PermaProps.Permissions))
end

local function pp_open_menu(ply)
    if not PermaProps.HasPermission(ply, "Menu") then
        ply:ChatPrint("Access denied !")
        return
    end

    local SendTable = {}
    local Data_PropsList = sql.Query("SELECT * FROM permaprops WHERE map = " .. sql.SQLStr(game_GetMap()) .. ";")
    if Data_PropsList and #Data_PropsList < 200 then
        for k, v in pairs(Data_PropsList) do
            local data = util_JSONToTable(v.content)
            SendTable[v.id] = {
                Model = data.Model,
                Class = data.Class,
                Pos = data.Pos,
                Angle = data.Angle
            }
        end
    elseif Data_PropsList and #Data_PropsList > 200 then
        -- Too much props dude :'(
        for i = 1, 199 do
            local data = util_JSONToTable(Data_PropsList[i].content)
            SendTable[Data_PropsList[i].id] = {
                Model = data.Model,
                Class = data.Class,
                Pos = data.Pos,
                Angle = data.Angle
            }
        end
    end

    local Content = {}
    Content.MProps = tonumber(sql.QueryValue("SELECT COUNT(*) FROM permaprops WHERE map = " .. sql.SQLStr(game_GetMap()) .. ";"))
    Content.TProps = tonumber(sql.QueryValue("SELECT COUNT(*) FROM permaprops;"))
    Content.PropsList = SendTable
    Content.Permissions = PermaProps.Permissions
    local Data = util_TableToJSON(Content)
    local Compressed = util_Compress(Data)
    net_Start("pp_open_menu")
    net_WriteFloat(Compressed:len())
    net_WriteData(Compressed, Compressed:len())
    net_Send(ply)
end

concommand_Add("pp_cfg_open", pp_open_menu)
local function pp_info_send(um, ply)
    if not PermaProps.HasPermission(ply, "Menu") then
        ply:ChatPrint("Access denied !")
        return
    end

    local Content = net_ReadTable()
    if Content["CMD"] == "DEL" then
        Content["Val"] = tonumber(Content["Val"])
        if Content["Val"] ~= nil and Content["Val"] <= 0 then return end
        sql.Query("DELETE FROM permaprops WHERE id = " .. sql.SQLStr(Content["Val"]) .. ";")
        for _, ent in ents_Iterator() do
            if ent.PermaProps_ID == Content["Val"] then
                local erasedModel = ("You erased %s with a model of %s from the database."):format(ent:GetClass(), ent:GetModel())
                ply:ChatPrint(erasedModel)
                ent:Remove()
                break
            end
        end
    elseif Content["CMD"] == "VAR" then
        if PermaProps.Permissions[Content["Name"]] == nil or PermaProps.Permissions[Content["Name"]][Content["Data"]] == nil then return end
        if not isbool(Content["Val"]) then return end
        if Content["Name"] == "superadmin" and (Content["Data"] == "Custom" or Content["Data"] == "Permissions" or Content["Data"] == "Menu") then return end
        if not PermaProps.HasPermission(ply, "Permissions") then
            ply:ChatPrint("Access denied !")
            return
        end

        PermaProps.Permissions[Content["Name"]][Content["Data"]] = Content["Val"]
        PermissionSave()
    elseif Content["CMD"] == "DEL_MAP" then
        local query = ("DELETE FROM permaprops WHERE map = %s;"):format(sql.SQLStr(game_GetMap()))
        sql.Query(query)
        PermaProps.ReloadPermaProps()
        ply:ChatPrint("You erased all props from the map !")
    elseif Content["CMD"] == "DEL_ALL" then
        sql.Query("DELETE FROM permaprops;")
        PermaProps.ReloadPermaProps()
        ply:ChatPrint("You erased all props !")
    elseif Content["CMD"] == "CLR_MAP" then
        for _, ent in ents_Iterator() do
            if ent.PermaProps == true then ent:Remove() end
        end

        ply:ChatPrint("You have removed all props !")
    end
end

net_Receive("pp_info_send", pp_info_send)
