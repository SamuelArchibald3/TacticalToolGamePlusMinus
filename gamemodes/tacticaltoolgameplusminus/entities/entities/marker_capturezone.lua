AddCSLuaFile("marker_capturezone.lua")

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= ""

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
end

if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


function ENT:Initialize()
	SetGlobalVector( "MarkerPos", self:GetPos() )

	self:SetModel("models/tacticaltoolgame_models/boulder01_medium.mdl")
	self:SetSkin( 3 )
	self:SetNotSolid(true)

	--hidden until its zone is the live one; ChooseAttackSite shows it
	self:SetNoDraw(true)
end


function ENT:PhysicsCollide(data, phys)

end
