-- Retrive addon folder name, and our local, private namespace.
local Addon, Private = ...

-- Based on blizzard's code.

local atlasName = "128-Redbutton"
local AtlasInfo = {
	-- [ name ] = { width, height, left, right, top, bottom }
	[atlasName.."-Highlight"] = 			{ 441, 128, 	0.00195312, 	0.863281, 		0.190918, 		0.253418 	},
	[atlasName.."-Left-Disabled"] = 		{ 114, 128, 	0.255859, 		0.478516, 		0.508301, 		0.570801 	},
	[atlasName.."-Left-Pressed"] = 			{ 114, 128, 	0.482422, 		0.705078, 		0.508301, 		0.570801 	},
	[atlasName.."-Left"] = 					{ 114, 128, 	0.763672, 		0.986328, 		0.444824, 		0.507324 	},
	[atlasName.."-Right-Disabled"] = 		{ 292, 128, 	0.00195312, 	0.572266, 		0.317871, 		0.380371 	},
	[atlasName.."-Right-Pressed"] = 		{ 292, 128, 	0.00195312, 	0.572266, 		0.381348, 		0.443848 	},
	[atlasName.."-Right"] = 				{ 292, 128, 	0.00195312, 	0.572266, 		0.254395, 		0.316895 	},
	[atlasName.."-Center-Disabled"] = 		{  64, 128, 	0, 				0.125, 			0.0639648, 		0.126465 	},
	[atlasName.."-Center-Pressed"] = 		{  64, 128, 	0, 				0.125, 			0.127441, 		0.189941 	},
	[atlasName.."-Center"] = 				{  64, 128, 	0, 				0.125, 			0.000488281, 	0.0629883 	},
	[atlasName.."-Refresh-Pressed"] = 		{ 128, 128, 	0.00195312, 	0.251953, 		0.508301, 		0.570801 	},
	[atlasName.."-Refresh"] = 				{ 128, 128, 	0.00195312, 	0.251953, 		0.444824, 		0.507324 	},
	[atlasName.."-Refresh-Highlight"] = 	{ 128, 128, 	0.509766, 		0.759766, 		0.444824, 		0.507324 	},
	[atlasName.."-Refresh-Disabled"] = 		{ 128, 128, 	0.255859, 		0.505859, 		0.444824, 		0.507324 	},
	[atlasName.."-Exit-Pressed"] = 			{ 128, 128, 	0.576172, 		0.826172, 		0.381348, 		0.443848 	},
	[atlasName.."-Exit-Disabled"] = 		{ 128, 128, 	0.576172, 		0.826172, 		0.317871, 		0.380371 	},
	[atlasName.."-Exit"] = 					{ 128, 128, 	0.576172, 		0.826172, 		0.254395, 		0.316895 	},
}

local GetAtlasInfo = function(name)
	return AtlasInfo[name][1], AtlasInfo[name][2], AtlasInfo[name][3], AtlasInfo[name][4], AtlasInfo[name][5], AtlasInfo[name][6]
end

local GetAtlasSize = function(name)
	return AtlasInfo[name][1], AtlasInfo[name][2]
end

local GetAtlasCoords = function(name)
	return AtlasInfo[name][3], AtlasInfo[name][4], AtlasInfo[name][5], AtlasInfo[name][6]
end

BigGameMenuButton = {}

BigGameMenuButton.OnLoad = function(self)
	self.leftAtlasInfo = {}
	self.leftAtlasInfo.width,
	self.leftAtlasInfo.height = GetAtlasSize(atlasName.."-Left")
	self.rightAtlasInfo = {}
	self.rightAtlasInfo.width,
	self.rightAtlasInfo.height = GetAtlasSize(atlasName.."-Right")
	self.Left:SetVertexColor(.85, .85, .85)
	self.Right:SetVertexColor(.85, .85, .85)
	self.Center:SetVertexColor(.85, .85, .85)
end

BigGameMenuButton.OnEnter = function(self)
	self.Left:SetVertexColor(1, 1, 1)
	self.Right:SetVertexColor(1, 1, 1)
	self.Center:SetVertexColor(1, 1, 1)
	if (GameTooltip:IsProtected()) then
		return
	end
	if (self.tooltipText) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tooltipText)
	end
end

BigGameMenuButton.OnLeave = function(self)
	self.Left:SetVertexColor(.85, .85, .85)
	self.Right:SetVertexColor(.85, .85, .85)
	self.Center:SetVertexColor(.85, .85, .85)
	if (GameTooltip:IsProtected()) then
		return
	end
	GameTooltip:Hide()
end

BigGameMenuButton.UpdateScale = function(self)
	local buttonHeight = self:GetHeight();
	local buttonWidth = self:GetWidth();
	local scale = buttonHeight / self.leftAtlasInfo.height;
	self.Left:SetScale(scale);
	self.Right:SetScale(scale);

	local leftWidth = self.leftAtlasInfo.width * scale;
	local rightWidth = self.rightAtlasInfo.width * scale;
	local leftAndRightWidth = leftWidth + rightWidth;

	if leftAndRightWidth > buttonWidth then
		-- At the current buttonHeight, the left and right textures are too big to fit within the button width
		-- So slice some width off of the textures and adjust texture coords accordingly
		local extraWidth = leftAndRightWidth - buttonWidth;
		local newLeftWidth = leftWidth;
		local newRightWidth = rightWidth;

		-- If one of the textures is sufficiently larger than the other one, we can remove all of the width from there
		if (leftWidth - extraWidth) > rightWidth then
			-- left is big enough to take the whole thing...deduct it all from there
			newLeftWidth = leftWidth - extraWidth;
		elseif (rightWidth - extraWidth) > leftWidth then
			-- right is big enough to take the whole thing...deduct it all from there
			newRightWidth = rightWidth - extraWidth;
		else
			-- neither side is sufficiently larger than the other to take the whole extra width
			if leftWidth ~= rightWidth then
				-- so set both widths equal to the smaller size and subtract the difference from extraWidth
				local unevenAmount = math.abs(leftWidth - rightWidth);
				extraWidth = extraWidth - unevenAmount;
				newLeftWidth = math.min(leftWidth, rightWidth);
				newRightWidth = newLeftWidth;
			end
			-- newLeftWidth and newRightWidth are now equal and we just need to remove half of extraWidth from each
			local equallyDividedExtraWidth = extraWidth / 2;
			newLeftWidth = newLeftWidth - equallyDividedExtraWidth;
			newRightWidth = newRightWidth - equallyDividedExtraWidth;
		end

		-- Now set the tex coords and widths of both textures
		local leftPercentage = newLeftWidth / leftWidth;
		self.Left:SetWidth(newLeftWidth / scale);

		local rightPercentage = newRightWidth / rightWidth;
		self.Right:SetWidth(newRightWidth / scale);
	else
		self.Left:SetWidth(self.leftAtlasInfo.width);
		self.Right:SetWidth(self.rightAtlasInfo.width);
	end
end

BigGameMenuButton.UpdateButton = function(self, buttonState)
	buttonState = buttonState or self:GetButtonState()

	if (not self:IsEnabled()) then
		buttonState = "DISABLED"
	end

	local post = ""
	if (buttonState == "DISABLED") then
		post = "-Disabled"
	elseif (buttonState == "PUSHED") and (not Private.IsRetail or not GetCVarBool("ActionButtonUseKeyDown")) then
		post = "-Pressed"
	end

	self.Left:SetTexCoord(GetAtlasCoords(atlasName.."-Left"..post))
	self.Center:SetTexCoord(GetAtlasCoords(atlasName.."-Center"..post))
	self.Right:SetTexCoord(GetAtlasCoords(atlasName.."-Right"..post))

	self:UpdateScale()
end

BigGameMenuButton.OnMouseDown = function(self)
	self:UpdateButton("PUSHED")
end

BigGameMenuButton.OnMouseUp = function(self)
	self:UpdateButton("NORMAL")
end
