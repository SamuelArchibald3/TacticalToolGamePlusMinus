/*---------------------------------------------------------
	Player Meta Tables
---------------------------------------------------------*/
local TTGPlayer = FindMetaTable("Player")




//money is unused currently( later i will make it used by an upgrading system ) , tokens are used to buy tools

function TTGPlayer:SetMoney(amount)
	self:SetNetworkedInt( "Money", amount )
end

function TTGPlayer:GetMoney()
	local money = self:GetNetworkedInt( "Money", 0 )
	return money
end


//gives the player a certain amount of money
function TTGPlayer:AddMoney(amount)
	local money = self:GetNetworkedInt( "Money", 0 )
	local newmoney = money + amount
	self:SetNetworkedInt( "Money", newmoney )
end


//subtracts a specified amount of money from the player, returns true if successful
//if the requested subtraction is larger than the total current money of the player:
//do nothing and return false
function TTGPlayer:SubtractMoney(amount)
	local money = self:GetNetworkedInt( "Money", 0 )
	
	if amount > money then
		return false
	else
		local newmoney = money - amount
		self:SetNetworkedInt( "Money", newmoney )
		return true
	end
end






function TTGPlayer:SetToolTokens(amount)
	self:SetNetworkedInt( "ToolTokens", amount )
end

function TTGPlayer:GetToolTokens()
	local tokens = self:GetNetworkedInt( "ToolTokens", 0 )
	return tokens
end

//subtracts a specified amount of tokens from the player, returns true if successful
//if the requested subtraction is larger than the total current tokens of the player:
//do nothing and return false
function TTGPlayer:SubtractToolTokens(amount)
	local money = self:GetNetworkedInt( "ToolTokens", 0 )
	
	if amount > money then
		return false
	else
		local newmoney = money - amount
		self:SetNetworkedInt( "ToolTokens", newmoney )
		return true
	end
end