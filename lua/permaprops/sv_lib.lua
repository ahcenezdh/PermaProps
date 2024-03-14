--[[
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
]]
local isfunction = isfunction
local istable = istable
local table_Merge = table.Merge
local hook_Run = hook.Run
local pairs = pairs
local isnumber = isnumber
local ents_Create = ents.Create
local Vector = Vector
local Angle = Angle
local type = type
local IsValid = IsValid
local ents_Iterator = ents.Iterator
local game_GetMap = game.GetMap
local util_JSONToTable = util.JSONToTable
local tonumber = tonumber
local hook_Add = hook.Add
local timer_Simple = timer.Simple
local EffectData = EffectData
local util_Effect = util.Effect
local isentity = isentity
if not PermaProps then PermaProps = {} end
function PermaProps.PPGetEntTable(ent)
    if not ent or not ent:IsValid() then return false end
    local content = {}
    content.Class = ent:GetClass()
    content.Pos = ent:GetPos()
    content.Angle = ent:GetAngles()
    content.Model = ent:GetModel()
    content.Skin = ent:GetSkin()
    --content.Mins, content.Maxs = ent:GetCollisionBounds()
    content.ColGroup = ent:GetCollisionGroup()
    content.Name = ent:GetName()
    content.ModelScale = ent:GetModelScale()
    content.Color = ent:GetColor()
    content.Material = ent:GetMaterial()
    content.Solid = ent:GetSolid()
    content.RenderMode = ent:GetRenderMode()
    if PermaProps.SpecialENTSSave[ent:GetClass()] ~= nil and isfunction(PermaProps.SpecialENTSSave[ent:GetClass()]) then
        local othercontent = PermaProps.SpecialENTSSave[ent:GetClass()](ent)
        if not othercontent then return false end
        if othercontent ~= nil and istable(othercontent) then table_Merge(content, othercontent) end
    end

    do
        local othercontent = hook_Run("PermaProps.OnEntitySaved", ent)
        if othercontent and istable(othercontent) then table_Merge(content, othercontent) end
    end

    if ent.GetNetworkVars then content.DT = ent:GetNetworkVars() end
    local sm = ent:GetMaterials()
    if sm and istable(sm) then
        for k, v in pairs(sm) do
            if ent:GetSubMaterial(k) then
                content.SubMat = content.SubMat or {}
                content.SubMat[k] = ent:GetSubMaterial(k - 1)
            end
        end
    end

    local bg = ent:GetBodyGroups()
    if bg then
        for k, v in pairs(bg) do
            if ent:GetBodygroup(v.id) > 0 then
                content.BodyG = content.BodyG or {}
                content.BodyG[v.id] = ent:GetBodygroup(v.id)
            end
        end
    end

    if ent:GetPhysicsObject() and ent:GetPhysicsObject():IsValid() then content.Frozen = not ent:GetPhysicsObject():IsMoveable() end
    if content.Class == "prop_dynamic" then content.Class = "prop_physics" end
    if ent.PreEntityCopy then ent:PreEntityCopy() end
    --content.Table = PermaProps.UselessContent( ent:GetTable() )
    if ent.PostEntityCopy then ent:PostEntityCopy() end
    if ent.OnEntityCopyTableFinish then ent:OnEntityCopyTableFinish(content) end
    return content
end

function PermaProps.PPEntityFromTable(data, id)
    if not id or not isnumber(id) then return false end
    if not data or not istable(data) then return false end
    if data.Class == "prop_physics" and data.Frozen then
        data.Class = "prop_dynamic" -- Can reduce lags
    end

    local ent = ents_Create(data.Class)
    if not ent then return false end
    if not ent:IsVehicle() and not ent:IsValid() then return false end
    ent:SetPos(data.Pos or Vector(0, 0, 0))
    ent:SetAngles(data.Angle or Angle(0, 0, 0))
    ent:SetModel(data.Model or "models/error.mdl")
    ent:SetSkin(data.Skin or 0)
    --ent:SetCollisionBounds( ( data.Mins or 0 ), ( data.Maxs or 0 ) )
    ent:SetCollisionGroup(data.ColGroup or 0)
    ent:SetName(data.Name or "")
    ent:SetModelScale(data.ModelScale or 1)
    ent:SetMaterial(data.Material or "")
    ent:SetSolid(data.Solid or 6)
    if PermaProps.SpecialENTSSpawn[data.Class] ~= nil and isfunction(PermaProps.SpecialENTSSpawn[data.Class]) then
        PermaProps.SpecialENTSSpawn[data.Class](ent, data.Other)
    else
        ent:Spawn()
    end

    hook_Run("PermaProps.OnEntityCreated", ent, data)
    ent:SetRenderMode(data.RenderMode or RENDERMODE_NORMAL)
    ent:SetColor(data.Color or color_white)
    if data.EntityMods ~= nil and istable(data.EntityMods) then -- OLD DATA
        if data.EntityMods.material then ent:SetMaterial(data.EntityMods.material["MaterialOverride"] or "") end
        if data.EntityMods.colour then ent:SetColor(data.EntityMods.colour.Color or color_white) end
    end

    if data.DT then
        for k, v in pairs(data.DT) do
            if data.DT[k] == nil then continue end
            if not isfunction(ent["Set" .. k]) then continue end
            ent["Set" .. k](ent, data.DT[k])
        end
    end

    if data.BodyG then
        for k, v in pairs(data.BodyG) do
            ent:SetBodygroup(k, v)
        end
    end

    if data.SubMat then
        for k, v in pairs(data.SubMat) do
            if type(k) ~= "number" or type(v) ~= "string" then continue end
            ent:SetSubMaterial(k - 1, v)
        end
    end

    if data.Frozen ~= nil then
        local phys = ent:GetPhysicsObject()
        if phys and phys:IsValid() then phys:EnableMotion(not data.Frozen) end
    end

    --[[if data.Table then

		table.Merge(ent:GetTable(), data.Table)

	end]]
    ent.PermaProps_ID = id
    ent.PermaProps = true
    if ent.OnDuplicated then ent:OnDuplicated(data) end
    if ent.PostEntityPaste then ent:PostEntityPaste(nil, ent, {ent}) end
    -- For all idiots who don't know how to config FPP, FUCK YOU
    function ent:CanTool(ply, trace, tool)
        if trace and IsValid(trace.Entity) and trace.Entity.PermaProps then
            if tool == "permaprops" then return true end
            return PermaProps.HasPermission(ply, "Tool")
        end
    end
    return ent
end

function PermaProps.ReloadPermaProps()
    for _, ent in ents_Iterator() do
        if ent.PermaProps == true then ent:Remove() end
    end

    local content = PermaProps.SQL.Query("SELECT * FROM permaprops WHERE map = " .. sql.SQLStr(game_GetMap()) .. ";")
    if not content or content == nil then return end
    for k, v in pairs(content) do
        local data = util_JSONToTable(v.content)
        local e = PermaProps.PPEntityFromTable(data, tonumber(v.id))
        if not e or not e:IsValid() then continue end
    end
end

hook_Add("InitPostEntity", "InitializePermaProps", PermaProps.ReloadPermaProps)
hook_Add("PostCleanupMap", "WhenCleanUpPermaProps", PermaProps.ReloadPermaProps) -- #MOMO
timer_Simple(5, function()
    PermaProps.ReloadPermaProps() -- When the hook isn't call ...
end)

function PermaProps.SparksEffect(ent)
    local effectdata = EffectData()
    effectdata:SetOrigin(ent:GetPos())
    effectdata:SetMagnitude(2.5)
    effectdata:SetScale(2)
    effectdata:SetRadius(3)
    util_Effect("Sparks", effectdata, true, true)
end

function PermaProps.IsUserGroup(ply, name)
    if not ply:IsValid() then return false end
    return ply:GetNWString("UserGroup") == name
end

function PermaProps.IsAdmin(ply)
    if PermaProps.IsUserGroup(ply, "superadmin") or false then return true end
    if PermaProps.IsUserGroup(ply, "admin") or false then return true end
    return false
end

function PermaProps.IsSuperAdmin(ply)
    return PermaProps.IsUserGroup(ply, "superadmin") or false
end

function PermaProps.UselessContent(tbl)
    local function CleanTable(t)
        for k, v in pairs(t) do
            if isfunction(v) or isentity(v) then
                t[k] = nil
            elseif istable(v) then
                CleanTable(v)
            end
        end
    end

    CleanTable(tbl)
    return tbl
end
