local LocalPlayer = LocalPlayer
local pairs = pairs
local render_ClearStencil = render.ClearStencil
local render_SetStencilEnable = render.SetStencilEnable
local render_SetStencilWriteMask = render.SetStencilWriteMask
local render_SetStencilTestMask = render.SetStencilTestMask
local render_SetStencilReferenceValue = render.SetStencilReferenceValue
local render_SetStencilFailOperation = render.SetStencilFailOperation
local render_SetStencilZFailOperation = render.SetStencilZFailOperation
local render_SetStencilPassOperation = render.SetStencilPassOperation
local render_SetStencilCompareFunction = render.SetStencilCompareFunction
local render_SetBlend = render.SetBlend
local cam_Start3D2D = cam.Start3D2D
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local ScrW = ScrW
local ScrH = ScrH
local cam_End3D2D = cam.End3D2D
local hook_Add = hook.Add

--[[
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
]]
local function PermaPropsViewer()
	local ply = LocalPlayer()
    if not ply.DrawPPEnt or not istable(ply.DrawPPEnt) then return end
    local pos = ply:EyePos() + ply:EyeAngles():Forward() * 10
    local ang = ply:EyeAngles()
    ang = Angle(ang.p + 90, ang.y, 0)
    for k, v in pairs(ply.DrawPPEnt) do
        if not v or not v:IsValid() then
            ply.DrawPPEnt[k] = nil
            continue
        end

        render_ClearStencil()
        render_SetStencilEnable(true)
        render_SetStencilWriteMask(255)
        render_SetStencilTestMask(255)
        render_SetStencilReferenceValue(15)
        render_SetStencilFailOperation(STENCILOPERATION_REPLACE)
        render_SetStencilZFailOperation(STENCILOPERATION_REPLACE)
        render_SetStencilPassOperation(STENCILOPERATION_KEEP)
        render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
        render_SetBlend(0)
        v:DrawModel()
        render_SetBlend(1)
        render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        cam_Start3D2D(pos, ang, 1)
        surface_SetDrawColor(255, 0, 0, 255)
        surface_DrawRect(-ScrW(), -ScrH(), ScrW() * 2, ScrH() * 2)
        cam_End3D2D()
        v:DrawModel()
        render_SetStencilEnable(false)
    end
end

hook_Add("PostDrawOpaqueRenderables", "PermaPropsViewer", PermaPropsViewer)