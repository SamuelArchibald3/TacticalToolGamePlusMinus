/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")


function TTGPlayer:SetAimTarget(ply)
	self:SetNetworkedEntity("AimTarget", ply)
end

function TTGPlayer:GetAimTarget()
	return self:GetNetworkedEntity("AimTarget")
end




function TTGPlayer:SetIfAimTarget(x)
	self:SetNetworkedBool("IsAimTarget", x)
end

function TTGPlayer:GetIfAimTarget()
	return self:GetNetworkedBool("IsAimTarget", false)
end




function TTGPlayer:SetAimTargetMaxDist(dist)
	self:SetNetworkedInt("AimTargetDist", dist)
end

function TTGPlayer:GetAimTargetMaxDist()
	return self:GetNetworkedInt("AimTargetDist", 0)
end