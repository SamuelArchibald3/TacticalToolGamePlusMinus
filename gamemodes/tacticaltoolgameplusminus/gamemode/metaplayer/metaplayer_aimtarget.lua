/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")


function TTGPlayer:SetAimTarget(ply)
	self:SetNW2Entity("AimTarget", ply)
end

function TTGPlayer:GetAimTarget()
	return self:GetNW2Entity("AimTarget")
end




function TTGPlayer:SetIfAimTarget(x)
	self:SetNW2Bool("IsAimTarget", x)
end

function TTGPlayer:GetIfAimTarget()
	return self:GetNW2Bool("IsAimTarget", false)
end




function TTGPlayer:SetAimTargetMaxDist(dist)
	self:SetNW2Int("AimTargetDist", dist)
end

function TTGPlayer:GetAimTargetMaxDist()
	return self:GetNW2Int("AimTargetDist", 0)
end