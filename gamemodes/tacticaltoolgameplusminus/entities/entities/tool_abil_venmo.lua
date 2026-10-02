ENT.Type 	= "point"
ENT.Base 	= "base_ttgabil"


if !SERVER then return end
------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------


--A joke - see premium.lua. Nothing is paid; it is written down.
function ENT:DoAbility()
	if self.Cooldown == true then
		self:CooldownSound()
	return
	end

	TTG_RecordVenmoOwed( self.Owner, self.Ref.amount )

	ChatPrintToAll( self.Owner:Nick() .. " has been sent $" .. self.Ref.amount .. " on Venmo!" )
	self.Owner:EmitSound( self.Ref.sound_send )

	self:InitiateCooldown()
end
