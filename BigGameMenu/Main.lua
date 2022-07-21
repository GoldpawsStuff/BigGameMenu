--[[

	The MIT License (MIT)

	Copyright (c) 2022 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
-- Retrive addon folder name, and our local, private namespace.
local Addon, Private = ...

-- Lua API
local pairs = pairs
local select = select
local string_lower = string.lower
local string_gsub = string.gsub
local string_upper = string.upper
local table_insert = table.insert

-- WoW API
local CreateFrame = CreateFrame

-- Addon API
-----------------------------------------------------------
Private.GetButtonData = function(self)
	if (not self.buttonData) then
		if (self.IsClassic) then
			self.buttonData = {
				{ Ref = "GameMenuButtonHelp", Text = GAMEMENU_HELP },
				{ Ref = "GameMenuButtonStore", Text = BLIZZARD_STORE },
				{ },
				{ Ref = "GameMenuButtonOptions", Text = SYSTEMOPTIONS_MENU },
				{ Ref = "GameMenuButtonUIOptions", Text = UIOPTIONS_MENU },
				{ Ref = "GameMenuButtonKeybindings", Text = KEY_BINDINGS },
				{ Ref = "GameMenuButtonMacros", Text = MACROS },
				{ Ref = "GameMenuButtonAddons", Text = ADDONS },
				{ },
				{ Ref = "GameMenuButtonRatings", Text = RATINGS_MENU },
				{ Ref = "GameMenuButtonLogout", Text = LOGOUT },
				{ Ref = "GameMenuButtonQuit", Text = EXIT_GAME },
				{ },
				{ Ref = "GameMenuButtonContinue", Text = RETURN_TO_GAME }
			}

		elseif (self.IsBCC) then
			self.buttonData = {
				{ Ref = "GameMenuButtonHelp", Text = GAMEMENU_SUPPORT },
				{ Ref = "GameMenuButtonStore", Text = BLIZZARD_STORE },
				{ },
				{ Ref = "GameMenuButtonOptions", Text = SYSTEMOPTIONS_MENU },
				{ Ref = "GameMenuButtonUIOptions", Text = UIOPTIONS_MENU },
				{ Ref = "GameMenuButtonKeybindings", Text = KEY_BINDINGS },
				{ Ref = "GameMenuButtonMacros", Text = MACROS },
				{ Ref = "GameMenuButtonAddons", Text = ADDONS },
				{ },
				{ Ref = "GameMenuButtonRatings", Text = RATINGS_MENU },
				{ Ref = "GameMenuButtonLogout", Text = LOGOUT },
				{ Ref = "GameMenuButtonQuit", Text = EXIT_GAME },
				{ },
				{ Ref = "GameMenuButtonContinue", Text = RETURN_TO_GAME }
			}

		elseif (self.IsWotLK) then
			self.buttonData = {
				{ Ref = "GameMenuButtonHelp", Text = GAMEMENU_SUPPORT },
				{ Ref = "GameMenuButtonStore", Text = BLIZZARD_STORE },
				{ },
				{ Ref = "GameMenuButtonOptions", Text = SYSTEMOPTIONS_MENU },
				{ Ref = "GameMenuButtonUIOptions", Text = UIOPTIONS_MENU },
				{ Ref = "GameMenuButtonKeybindings", Text = KEY_BINDINGS },
				{ Ref = "GameMenuButtonMacros", Text = MACROS },
				{ Ref = "GameMenuButtonAddons", Text = ADDONS },
				{ },
				{ Ref = "GameMenuButtonRatings", Text = RATINGS_MENU },
				{ Ref = "GameMenuButtonLogout", Text = LOGOUT },
				{ Ref = "GameMenuButtonQuit", Text = EXIT_GAME },
				{ },
				{ Ref = "GameMenuButtonContinue", Text = RETURN_TO_GAME }
			}

		elseif (self.IsRetail) then
			if (self.IsDragonflight) then
				self.buttonData = {
					{ Ref = "GameMenuButtonHelp", Text = GAMEMENU_SUPPORT },
					{ Ref = "GameMenuButtonStore", Text = BLIZZARD_STORE },
					{ Ref = "GameMenuButtonWhatsNew", Text = GAMEMENU_NEW_BUTTON },
					{ },
					{ Ref = "GameMenuButtonSettings", Text = GAMEMENU_SETTINGS },
					{ Ref = "GameMenuButtonEditMode", Text = HUD_EDIT_MODE_MENU },
					{ Ref = "GameMenuButtonMacros", Text = MACROS },
					{ Ref = "GameMenuButtonAddons", Text = ADDONS },
					{ },
					{ Ref = "GameMenuButtonRatings", Text = RATINGS_MENU },
					{ Ref = "GameMenuButtonLogout", Text = LOG_OUT },
					{ Ref = "GameMenuButtonQuit", Text = EXIT_GAME },
					{ },
					{ Ref = "GameMenuButtonContinue", Text = RETURN_TO_GAME },
				}

			else
				self.buttonData = {
					{ Ref = "GameMenuButtonHelp", Text = GAMEMENU_SUPPORT },
					{ Ref = "GameMenuButtonStore", Text = BLIZZARD_STORE },
					{ Ref = "GameMenuButtonWhatsNew", Text = GAMEMENU_NEW_BUTTON },
					{ },
					{ Ref = "GameMenuButtonOptions", Text = SYSTEMOPTIONS_MENU },
					{ Ref = "GameMenuButtonUIOptions", Text = UIOPTIONS_MENU },
					{ Ref = "GameMenuButtonKeybindings", Text = KEY_BINDINGS },
					{ Ref = "GameMenuButtonMacros", Text = MACROS },
					{ Ref = "GameMenuButtonAddons", Text = ADDONS },
					{ },
					{ Ref = "GameMenuButtonRatings", Text = RATINGS_MENU },
					{ Ref = "GameMenuButtonLogout", Text = LOG_OUT },
					{ Ref = "GameMenuButtonQuit", Text = EXIT_GAME },
					{ },
					{ Ref = "GameMenuButtonContinue", Text = RETURN_TO_GAME }
				}
			end

		end
	end
	return ipairs(self.buttonData)
end

Private.UpdateButtons = function(self)
	if (not self.buttons) then
		return
	end

	-- These are secure buttons, don't edit in combat.
	if (InCombatLockdown()) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	-- Update button visibility and enabled state.
	-- Just copy whatever the blizzard originals do.
	for name,button in pairs(self.buttonsByName) do
		local orig = _G[name]
		if (orig) then
			button:SetShown(orig:IsShown())
			if (orig:IsEnabled()) then
				button.disabledTooltip = nil
				button:Enable()
			else
				button.disabledTooltip = orig.disabledTooltip
				button:Disable()
			end
		else
			button.disabledTooltip = nil
			button:Disable()
			button:Hide()
		end
	end

	-- Arrange the button layout.
	local first, previous
	local offset, height = 0, 0

	for i,button in ipairs(self.buttons) do

		if (button == true) or (not button:IsShown()) then
			if (previous) then
				offset = previous:GetHeight() / 2
				height = height + offset
			end
		else
			if (not first) then
				first = button
			end

			if (previous) then
				button:SetPoint("TOP", previous, "BOTTOM", 0, -offset)
			else
				button:SetPoint("CENTER")
			end
			previous = button

			offset = -2
			height = height + button:GetHeight() - 2
		end
	end

	if (first) then
		first:SetPoint("CENTER", 0, height/2)
	end

end


-- Addon Core
-----------------------------------------------------------
-- Your event handler.
-- Any events you add should be handled here.
-- @input event <string> The name of the event that fired.
-- @input ... <misc> Any payloads passed by the event handlers.
Private.OnEvent = function(self, event, ...)
	-- All our events are one-shot on-demand events.
	self:UnregisterEvent(event)
	self:UpdateButtons()
end

-- Initialization.
-- This fires when the addon and its settings are loaded.
Private.OnInit = function(self)

	self.buttons = {}
	self.buttonsByName = {}

	self.hider = CreateFrame("Frame")
	self.hider:SetAllPoints()
	self.hider:Hide()

	-- Kill off the Blizzard content
	local frame = GameMenuFrame
	frame:SetSize(0,0)
	frame:SetFrameStrata("LOW")
	frame:EnableMouse(false)
	frame:EnableKeyboard(false)
	frame:SetAlpha(0)
	frame:ClearAllPoints()

	-- Spawn our own buttons
	for i,info in self:GetButtonData() do
		local button
		if (info.Ref) then
			button = CreateFrame("Button", nil, BigGameMenu, "BigGameMenuButtonTemplate,SecureActionButtonTemplate")
			button:SetHighlightTexture(nil)
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext", "/click GameMenuButtonContinue\n/click "..info.Ref)
			button:SetText(info.Text)
			self.buttonsByName[info.Ref] = button
		end
		self.buttons[#self.buttons + 1] = button or true
	end

	-- Hook button update functions
	for _,global in ipairs({ "GameMenuFrame_UpdateVisibleButtons", "GameMenuFrame_UpdateStoreButtonState" }) do
		if (_G[global]) then
			-- Just proxy it to our own full update method.
			hooksecurefunc(global, function() self:UpdateButtons() end)
		end
	end

end

-- Enabling.
-- This fires when most of the user interface has been loaded
-- and most data is available to the user.
Private.OnEnable = function(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end


-- Setup the environment
-----------------------------------------------------------
(function(self)
	-- Private Default API
	-- This mostly contains methods we always want available
	-----------------------------------------------------------
	local currentClientPatch, currentClientBuild = GetBuildInfo()
	currentClientBuild = tonumber(currentClientBuild)

	-- Let's create some constants for faster lookups
	local MAJOR,MINOR,PATCH = string.split(".", currentClientPatch)
	MAJOR = tonumber(MAJOR)

	-- These are defined in FrameXML/BNet.lua
	-- *Using blizzard constants if they exist,
	-- using string parsing as a fallback.
	Private.IsRetail = (WOW_PROJECT_ID) and (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) or (MAJOR >= 9)
	Private.IsDragonflight = MAJOR >= 10
	Private.IsClassic = MAJOR == 1
	Private.IsBCC = MAJOR == 2
	Private.IsWotLK = MAJOR == 3
	Private.CurrentClientBuild = currentClientBuild -- Expose the build number too

	-- Set a relative subpath to look for media files in.
	local Path
	Private.SetMediaPath = function(self, path)
		Path = path
	end

	-- Simple API calls to retrieve a media file.
	-- Will honor the relativ subpath set above, if defined,
	-- and will default to the addon folder itself if not.
	-- Note that we cannot check for file or folder existence
	-- from within the WoW API, so you must make sure this is correct.
	Private.GetMedia = function(self, name, type)
		if (Path) then
			return ([[Interface\AddOns\%s\%s\%s.%s]]):format(Addon, Path, name, type or "tga")
		else
			return ([[Interface\AddOns\%s\%s.%s]]):format(Addon, name, type or "tga")
		end
	end

	-- Parse chat input arguments
	local parse = function(msg)
		msg = string.gsub(msg, "^%s+", "") -- Remove spaces at the start.
		msg = string.gsub(msg, "%s+$", "") -- Remove spaces at the end.
		msg = string.gsub(msg, "%s+", " ") -- Replace all space characters with single spaces.
		if (string.find(msg, "%s")) then
			return string.split(" ", msg) -- If multiple arguments exist, split them into separate return values.
		else
			return msg
		end
	end

	-- This methods lets you register a chat command, and a callback function or private method name.
	-- Your callback will be called as callback(Private, editBox, commandName, ...) where (...) are all the input parameters.
	Private.RegisterChatCommand = function(_, command, callback)
		command = string.gsub(command, "^\\", "") -- Remove any backslash at the start.
		command = string.lower(command) -- Make it lowercase, keep it case-insensitive.
		local name = string.upper(Addon.."_CHATCOMMAND_"..command) -- Create a unique uppercase name for the command.
		_G["SLASH_"..name.."1"] = "/"..command -- Register the chat command, keeping it lowercase.
		SlashCmdList[name] = function(msg, editBox)
			local func = Private[callback] or Private.OnChatCommand or callback
			if (func) then
				func(Private, editBox, command, parse(string.lower(msg)))
			end
		end
	end

	Private.GetAddOnInfo = function(self, index)
		local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(index)
		local enabled = not(GetAddOnEnableState(UnitName("player"), index) == 0)
		return name, title, notes, enabled, loadable, reason, security
	end

	-- Check if an addon exists in the addon listing and loadable on demand
	Private.IsAddOnLoadable = function(self, target, ignoreLoD)
		local target = string.lower(target)
		for i = 1,GetNumAddOns() do
			local name, title, notes, enabled, loadable, reason, security = self:GetAddOnInfo(i)
			if string.lower(name) == target then
				if loadable or ignoreLoD then
					return true
				end
			end
		end
	end

	-- This method lets you check if an addon WILL be loaded regardless of whether or not it currently is.
	-- This is useful if you want to check if an addon interacting with yours is enabled.
	-- My philosophy is that it's best to avoid addon dependencies in the toc file,
	-- unless your addon is a plugin to another addon, that is.
	Private.IsAddOnEnabled = function(self, target)
		local target = string.lower(target)
		for i = 1,GetNumAddOns() do
			local name, title, notes, enabled, loadable, reason, security = self:GetAddOnInfo(i)
			if string.lower(name) == target then
				if enabled and loadable then
					return true
				end
			end
		end
	end

	-- Event API
	-----------------------------------------------------------
	-- Proxy event registering to the addon namespace.
	-- The 'self' within these should refer to our proxy frame,
	-- which has been passed to this environment method as the 'self'.
	Private.RegisterEvent = function(_, ...) self:RegisterEvent(...) end
	Private.RegisterUnitEvent = function(_, ...) self:RegisterUnitEvent(...) end
	Private.UnregisterEvent = function(_, ...) self:UnregisterEvent(...) end
	Private.UnregisterAllEvents = function(_, ...) self:UnregisterAllEvents(...) end
	Private.IsEventRegistered = function(_, ...) self:IsEventRegistered(...) end

	-- Event Dispatcher and Initialization Handler
	-----------------------------------------------------------
	-- Assign our event script handler,
	-- which runs our initialization methods,
	-- and dispatches event to the addon namespace.
	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			-- Nothing happens before this has fired for your addon.
			-- When it fires, we remove the event listener
			-- and call our initialization method.
			if ((...) == Addon) then
				-- Delete our initial registration of this event.
				-- Note that you are free to re-register it in any of the
				-- addon namespace methods.
				self:UnregisterEvent("ADDON_LOADED")
				-- Call the initialization method.
				if (Private.OnInit) then
					Private:OnInit()
				end
				-- If this was a load-on-demand addon,
				-- then we might be logged in already.
				-- If that is the case, directly run
				-- the enabling method.
				if (IsLoggedIn()) then
					if (Private.OnEnable) then
						Private:OnEnable()
					end
				else
					-- If this is a regular always-load addon,
					-- we're not yet logged in, and must listen for this.
					self:RegisterEvent("PLAYER_LOGIN")
				end
				-- Return. We do not wish to forward the loading event
				-- for our own addon to the namespace event handler.
				-- That is what the initialization method exists for.
				return
			end
		elseif (event == "PLAYER_LOGIN") then
			-- This event only ever fires once on a reload,
			-- and anything you wish done at this event,
			-- should be put in the namespace enable method.
			self:UnregisterEvent("PLAYER_LOGIN")
			-- Call the enabling method.
			if (Private.OnEnable) then
				Private:OnEnable()
			end
			-- Return. We do not wish to forward this
			-- to the namespace event handler.
			return
		end
		-- Forward other events than our two initialization events
		-- to the addon namespace's event handler.
		-- Note that you can always register more ADDON_LOADED
		-- if you wish to listen for other addons loading.
		if (Private.OnEvent) then
			Private:OnEvent(event, ...)
		end
	end)
end)((function() return CreateFrame("Frame", nil, WorldFrame) end)())
