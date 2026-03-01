local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

local DEFAULT_TEXT_COLOR = CreateColor(1, 1, 1, 1)
local COMPLETED_TEXT_COLOR = CreateColor(0.2, 1, 0.2, 1)
local RED_TEXT_COLOR = CreateColor(0.5, 0, 0, 1)

local FUBA_HEADER_COLOR = CreateColor(1, 0.8, 0.1, 1)
local FUBA_QUEST_ACCOUNT_COMPLETED_NOTICE_FONT_COLOR = CreateColor(0.4, 0.4, 0.4, 1)
local FUBA_QUEST_OPTIONAL_FONT_COLOR = CreateColor(.4, 1, 1, 1)

local function InvertColor(r, g, b)
    return 1 - r, 1 - g, 1 - b
end

local function HandleReward(frame)
	if not frame then return end

	local E, L, V, P, G = unpack(ElvUI)
	local S = ElvUI[1]:GetModule('Skins')

	for _, Region in next, { frame:GetRegions() } do
		if Region:IsObjectType('Texture') and Region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
			Region:SetTexture(E.ClearTexture)
		end
	end

	if frame.Icon then
		frame.Icon:SetDrawLayer('ARTWORK')
		S:HandleIcon(frame.Icon, true)

		if frame.IconBorder then
			S:HandleIconBorder(frame.IconBorder, frame.Icon.backdrop)
		end

		if frame.Rarity then
			if (not frame.SetBackdrop) then Mixin(frame, BackdropTemplateMixin) end
			S:HandleIconBorder(frame.Rarity, frame.Icon.backdrop)
		end
	end

	if frame.Count then
		frame.Count:SetDrawLayer('OVERLAY')
		frame.Count:ClearAllPoints()
		frame.Count:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 0, 0)
	end

	-- Classic Quest Log uses .Amount; handle both names
	if frame.Amount then
		frame.Amount:SetDrawLayer('OVERLAY')
		frame.Amount:ClearAllPoints()
		frame.Amount:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 0, 0)
	end

	if frame.NameFrame then
		frame.NameFrame:SetAlpha(0)
		frame.NameFrame:Hide()
	end

	-- Kerzo uses .Back for the text background area
	if frame.Back then
		frame.Back:SetAlpha(0)
	end

	if frame.IconOverlay then
		frame.IconOverlay:SetAlpha(0)
	end

	if frame.Name then
		frame.Name:FontTemplate()
	end

	-- Both addons use .Text for the reward name
	if frame.Text then
		frame.Text:FontTemplate()
	end

	if frame.CircleBackground then
		frame.CircleBackground:SetAlpha(0)
		frame.CircleBackgroundGlow:SetAlpha(0)
	end
end


-- Shared detail content coloring: applies all font/text color overrides to
-- the detail panel's content children. Works for both addons since the
-- content child names (TitleHeader, ObjectivesText, etc.) are the same.
local function ColorDetailContent(content, getSelectedQuestFunc)
	if not content then return end

	local questID = getSelectedQuestFunc()
	if not questID then return end

	-- Title header
	if content.TitleHeader and content.TitleHeader:IsShown() then
		content.TitleHeader:SetTextColor(FUBA_HEADER_COLOR:GetRGB())
	end

	-- Status title (party sync hold)
	if content.StatusTitle and content.StatusTitle:IsShown() then
		if questID > 0 and C_QuestLog.IsQuestDisabledForSession(questID) then
			content.StatusTitle:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end
	end

	-- Status text (party sync hold)
	if content.StatusText and content.StatusText:IsShown() then
		if questID > 0 and C_QuestLog.IsQuestDisabledForSession(questID) then
			content.StatusText:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end
	end

	-- Objectives text
	if content.ObjectivesText and content.ObjectivesText:IsShown() then
		if questID > 0 then
			content.ObjectivesText:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end
	end

	-- Individual objectives in ObjectivesFrame
	if content.ObjectivesFrame and content.ObjectivesFrame.Objectives then
		local objectivesTable = content.ObjectivesFrame.Objectives
		local numObjectives = GetNumQuestLeaderBoards()

		-- First check for waypoint text (it's always first if present)
		local waypointText = questID > 0 and C_QuestLog.GetNextWaypointText(questID) or nil
		local startIndex = 1

		if waypointText then
			if objectivesTable[1] and objectivesTable[1]:IsShown() then
				objectivesTable[1]:SetTextColor(FUBA_QUEST_OPTIONAL_FONT_COLOR:GetRGB())
			end
			startIndex = 2
		end

		-- Color remaining visible objectives based on completion
		local objIndex = startIndex
		for i = 1, numObjectives do
			local text, objType, finished = GetQuestLogLeaderBoard(i)
			if objType ~= "spell" and objType ~= "log" then
				local objective = objectivesTable[objIndex]
				if objective and objective:IsShown() then
					if finished then
						objective:SetTextColor(COMPLETED_TEXT_COLOR:GetRGB())
					else
						objective:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
					end
				end
				objIndex = objIndex + 1
			end
		end
	end

	-- Special objectives (spell learn label)
	if content.SpecialObjectivesFrame and content.SpecialObjectivesFrame:IsShown() then
		local spellObjectiveLearnLabel = content.SpecialObjectivesFrame.SpellObjectiveLearnLabel
		if spellObjectiveLearnLabel and spellObjectiveLearnLabel:IsShown() then
			local spellID, spellName, spellTexture, finished = GetQuestLogCriteriaSpell()
			if finished then
				spellObjectiveLearnLabel:SetTextColor(COMPLETED_TEXT_COLOR:GetRGB())
			else
				spellObjectiveLearnLabel:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end
		end
	end

	-- Required money text
	if content.RequiredMoneyFrame and content.RequiredMoneyFrame:IsShown() then
		local requiredMoney = C_QuestLog.GetRequiredMoney()
		if content.RequiredMoneyFrame.RequiredMoneyText then
			if requiredMoney > GetMoney() then
				content.RequiredMoneyFrame.RequiredMoneyText:SetTextColor(RED_TEXT_COLOR:GetRGB())
			else
				content.RequiredMoneyFrame.RequiredMoneyText:SetTextColor(COMPLETED_TEXT_COLOR:GetRGB())
			end
		end
	end

	-- Group size
	if content.GroupSize and content.GroupSize:IsShown() then
		if questID > 0 then
			content.GroupSize:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end
	end

	-- Description header
	if content.DescriptionHeader and content.DescriptionHeader:IsShown() then
		content.DescriptionHeader:SetTextColor(FUBA_HEADER_COLOR:GetRGB())
	end

	-- Description text
	if content.DescriptionText and content.DescriptionText:IsShown() then
		if questID > 0 then
			content.DescriptionText:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end
	end

	-- Account completed notice (warband)
	if content.AccountCompletedNotice and content.AccountCompletedNotice:IsShown() then
		content.AccountCompletedNotice:SetTextColor(FUBA_QUEST_ACCOUNT_COMPLETED_NOTICE_FONT_COLOR:GetRGB())
	end

	-- Seal frame text
	if content.SealFrame and content.SealFrame:IsShown() and content.SealFrame.Text then
		content.SealFrame.Text:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
	end

	-- Rewards header
	if content.RewardsFrame and content.RewardsFrame:IsShown() and content.RewardsFrame.Header then
		content.RewardsFrame.Header:SetTextColor(FUBA_HEADER_COLOR:GetRGB())
	end
end


local function SkinForElvUI()

	if (not IsAddOnLoaded("ElvUI")) then return end

	local cql, isKerzo
	if (IsAddOnLoaded("Classic Quest Log")) then
		cql = ClassicQuestLog
		isKerzo = false
	elseif (IsAddOnLoaded("Kerzo Classic Quest Log")) then
		cql = KerzosQuestLog
		isKerzo = true
	else
		return
	end
	if not cql then return end

	local E, L, V, P, G = unpack(ElvUI)
	local S = ElvUI[1]:GetModule('Skins')

	-- Resolve panel references based on which addon is loaded
	local logPanel = isKerzo and cql.RegistroMisiones or cql.Log
	local detailPanel = isKerzo and cql.VisorDetalle or cql.Detail
	local optionsPanel = isKerzo and cql.PanelAjustes or cql.Options
	local chromePanel = isKerzo and cql.Barra or cql.Chrome

	-- Resolve method/property names
	local expandButtonKey = isKerzo and "BotonExpandir" or "ExpandButton"
	local allButtonKey = isKerzo and "BotonExpandirTodo" or "AllButton"

	-- Function to get the selected quest, works for both addons
	local function getSelectedQuest()
		if isKerzo then
			return cql.RegistroMisiones:QuestSeleccionada()
		else
			return cql.Log:GetSelectedQuest()
		end
	end

	-- Function to get collapsed headers table
	local function getCollapsedHeaders()
		if isKerzo then
			return cql.cfg and cql.cfg.SeccionesColapsadas or {}
		else
			return cql.settings and cql.settings.CollapsedHeaders or {}
		end
	end

	-- Function to check if something is expanded
	local function isSomethingExpanded()
		if isKerzo then
			return cql.RegistroMisiones:HayExpandidas()
		else
			return cql.Log:IsSomethingExpanded()
		end
	end

	cql:StripTextures()
	cql:SetTemplate("Transparent")

	-----------
	--- Log ---
	-----------

	local logUpdateMethod = isKerzo and "Refrescar" or "Update"

	-- One-time structural skinning for the Kerzo log panel.
	--
	-- ROOT CAUSE of the dimming bug:
	-- The old code called SetTemplate("Transparent") on the RegistroMisiones
	-- frame every refresh.  SetTemplate applies BackdropTemplateMixin directly
	-- to the frame itself, creating nine-slice texture regions (Center at
	-- BACKGROUND layer, edges at BORDER layer) on the frame.  When ElvUI is
	-- NOT in PixelMode, SetTemplate ALSO creates iborder/oborder child frames
	-- at the frame's own level that cover its entire interior.  These child
	-- frames -- even though they only render edges -- sit in the rendering
	-- order ABOVE parent-owned regions (FontStrings, Textures).  Combined
	-- with the repeated StripTextures/SetTemplate cycle, the search widgets
	-- appeared dimmed behind the ElvUI border overlay.
	--
	-- Additionally, the previous fix tried to check self.backdrop, but
	-- SetTemplate does NOT create self.backdrop (only CreateBackdrop does).
	-- So the fix was dead code that never executed.
	--
	-- FIX: Use CreateBackdrop("Transparent") once to create a dedicated
	-- backdrop child frame.  CreateBackdrop positions it at frameLevel - 1
	-- (below the parent).  Then explicitly raise all interactive widgets
	-- above the backdrop.  For SearchLabel (a FontString / region), reparent
	-- it into a thin overlay frame.  The per-refresh hook only needs to
	-- suppress Kerzo's Back/Bg texture re-application.

	-- Helper: apply the one-time Kerzo log panel skin.
	-- Called once; may be invoked again from the first Refrescar hook if
	-- SearchLabel was not yet created when we first ran (PLAYER_LOGIN
	-- timing race with Kerzo's own Inicializar).
	local kerzoLogSkinApplied = false

	local function ApplyKerzoLogSkin(panel)
		if kerzoLogSkinApplied then
			-- Already fully applied.  Only thing to check: SearchLabel
			-- overlay may not have been created on the first pass if
			-- Inicializar hadn't run yet.
			if panel.SearchLabel and not panel._searchLabelOverlay then
				local aboveLevel = (panel.backdrop and panel.backdrop:GetFrameLevel() or panel:GetFrameLevel()) + 2
				local overlay = CreateFrame("Frame", nil, panel)
				overlay:SetAllPoints(panel)
				overlay:SetFrameLevel(aboveLevel)
				panel.SearchLabel:SetParent(overlay)
				panel._searchLabelOverlay = overlay
			end
			return
		end
		kerzoLogSkinApplied = true

		-- Strip Blizzard art (InsetFrameTemplate textures, NineSlice, etc.)
		panel:StripTextures()

		-- Create a backdrop *child frame* rather than applying the backdrop
		-- directly to the panel.  This gives us panel.backdrop at a
		-- controlled frame level below everything else.
		panel:CreateBackdrop("Transparent")

		-- All real child widgets need to be above the backdrop.
		local aboveLevel = (panel.backdrop and panel.backdrop:GetFrameLevel() or panel:GetFrameLevel()) + 2

		-- Raise child-frame widgets above the backdrop
		if panel.InputBusqueda then
			panel.InputBusqueda:SetFrameLevel(aboveLevel)
		end
		if panel.BotonLimpiar then
			panel.BotonLimpiar:SetFrameLevel(aboveLevel)
		end
		if panel.BotonOcultas then
			panel.BotonOcultas:SetFrameLevel(aboveLevel)
		end
		if panel.ScrollFrame then
			panel.ScrollFrame:SetFrameLevel(aboveLevel)
		end

		-- SearchLabel is a FontString (a region, not a frame).  Regions
		-- render as part of their parent frame and cannot have their own
		-- frame level.  A backdrop child frame would draw on top of them.
		-- Reparent the FontString into a thin overlay frame that sits
		-- above the backdrop.
		if panel.SearchLabel then
			local overlay = CreateFrame("Frame", nil, panel)
			overlay:SetAllPoints(panel)
			overlay:SetFrameLevel(aboveLevel)
			panel.SearchLabel:SetParent(overlay)
			panel._searchLabelOverlay = overlay
		end

		-- Skin the search widgets with ElvUI handlers for visual consistency
		if panel.InputBusqueda then
			S:HandleEditBox(panel.InputBusqueda)
		end
		if panel.BotonLimpiar then
			S:HandleButton(panel.BotonLimpiar)
		end
		if panel.BotonOcultas then
			S:HandleButton(panel.BotonOcultas)
		end

		S:HandleTrimScrollBar(panel.ScrollFrame.ScrollBar)
	end

	if isKerzo then
		ApplyKerzoLogSkin(logPanel)
	end

	hooksecurefunc(logPanel, logUpdateMethod, function(self)
		local content = self.ScrollFrame.Content

		if isKerzo then
			-- Ensure one-time skin is applied (handles the case where
			-- our PLAYER_LOGIN fires before Kerzo's Inicializar).
			ApplyKerzoLogSkin(self)

			-- Kerzo's Refrescar re-applies the Back atlas every call.
			-- Hide it so the ElvUI backdrop shows through cleanly.
			if self.Back then
				self.Back:SetTexture(E.ClearTexture)
				self.Back:SetAtlas("")
			end
			-- Also keep the InsetFrameTemplate marble background hidden
			if self.Bg then
				self.Bg:SetTexture(E.ClearTexture)
			end
		else
			-- For non-Kerzo (Classic Quest Log), apply structural skinning
			-- every refresh as before (CQL has no search widgets to worry about).
			self:StripTextures()
			self:SetTemplate("Transparent")
			S:HandleTrimScrollBar(self.ScrollFrame.ScrollBar)
		end

		local somethingExpanded = isSomethingExpanded()
		local AllButton = self.ScrollFrame[allButtonKey]
		AllButton:StripTextures()
		AllButton:SetNormalTexture(somethingExpanded and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton)
		AllButton:SetPushedTexture(somethingExpanded and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton)
		AllButton:ClearAllPoints()
		AllButton:SetPoint('BOTTOMLEFT', cql, 'TOPLEFT', 6, -55)

		local buttons = content.Buttons
		local collapsedHeaders = getCollapsedHeaders()

		for index, button in ipairs(buttons) do
			local expandButton = button[expandButtonKey]
			local info = button.info
			if expandButton and info and info.isHeader then
				local isCollapsed = collapsedHeaders[info.title]
				button.expandAtlas = isCollapsed and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton
				expandButton:SetTexture(isCollapsed and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton)
			end
		end
	end)

	---------------
	--- Options ---
	---------------

	local optionsUpdateMethod = isKerzo and "Refrescar" or "Update"

	hooksecurefunc(optionsPanel, optionsUpdateMethod, function(self)
		self:StripTextures()
		self:SetTemplate("Transparent")

		S:HandleTrimScrollBar(self.ScrollFrame.ScrollBar)
	end)

	---------------
	--- Details ---
	---------------

	if isKerzo then
		-- Kerzo: hook the single Refrescar method for both structural skinning
		-- AND color overrides. By the time this hook fires, all content frames
		-- (title, objectives, description, rewards, etc.) have been populated
		-- by the internal Renderizar* methods.
		hooksecurefunc(detailPanel, "Refrescar", function(self)
			self:StripTextures()
			self:SetTemplate("Transparent")
			S:HandleTrimScrollBar(self.ScrollFrame.ScrollBar)

			local content = self.ScrollFrame.Content
			if not content then return end
			ColorDetailContent(content, getSelectedQuest)
		end)

		-- Hook RellenarPremio (equivalent of FillReward) for reward button skinning
		hooksecurefunc(detailPanel, "RellenarPremio", function(self, rewardButton, ...)
			if not rewardButton then return end
			HandleReward(rewardButton)
		end)

		-- Hook InsertarTextoPremio (equivalent of AddTextToRewards) for reward text color
		hooksecurefunc(detailPanel, "InsertarTextoPremio", function(self, fontstring, text)
			if not fontstring then return end
			fontstring:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end)

	else
		-- Classic Quest Log: structural skinning via Update hook
		hooksecurefunc(cql.Detail, "Update", function(self)
			self:StripTextures()
			self:SetTemplate("Transparent")
			S:HandleTrimScrollBar(self.ScrollFrame.ScrollBar)
		end)

		-- Classic Quest Log: hook each individual Show* method as before.
		-- This preserves the original behavior exactly.

		hooksecurefunc(cql.Detail, "ShowTitle", function(self)
			local content = self.ScrollFrame.Content
			if not content then return end
			content.TitleHeader:SetTextColor(FUBA_HEADER_COLOR:GetRGB())
		end)

		hooksecurefunc(cql.Detail, "ShowStatusTitle", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			if not (content and questID) then return end

			if questID > 0 and C_QuestLog.IsQuestDisabledForSession(questID) then
				content.StatusTitle:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end
		end)

		hooksecurefunc(cql.Detail, "ShowStatusText", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			if not (content and questID) then return end

			if questID > 0 and C_QuestLog.IsQuestDisabledForSession(questID) then
				content.StatusText:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end
		end)

		hooksecurefunc(cql.Detail, "ShowObjectivesText", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			if not (content and questID) then return end

			if questID > 0 then
				content.ObjectivesText:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end
		end)

		hooksecurefunc(cql.Detail, "ShowObjectives", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			local numObjectives = GetNumQuestLeaderBoards()
			local objective
			local text, type, finished
			local objectivesTable = content.ObjectivesFrame.Objectives
			local numVisibleObjectives = 0
			if not (content and questID) then return end

			if questID > 0 then
				local waypointText = C_QuestLog.GetNextWaypointText(questID)
				if waypointText then
					numVisibleObjectives = numVisibleObjectives + 1
					objective = self:AcquireObjective(numVisibleObjectives)
					objective:SetTextColor(FUBA_QUEST_OPTIONAL_FONT_COLOR:GetRGB())
				end

				for i = 1, numObjectives do
					text, type, finished = GetQuestLogLeaderBoard(i)
					if (type ~= "spell" and type ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
						numVisibleObjectives = numVisibleObjectives + 1
						objective = self:AcquireObjective(numVisibleObjectives)

						if finished then
							objective:SetTextColor(COMPLETED_TEXT_COLOR:GetRGB())
						else
							objective:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
						end
					end
				end
			end
		end)

		hooksecurefunc(cql.Detail, "ShowSpecialObjectives", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			if not (content and questID) then return end

			local spellID, spellName, spellTexture, finished = GetQuestLogCriteriaSpell()
			local spellObjectiveLearnLabel = content.SpecialObjectivesFrame.SpellObjectiveLearnLabel

			if finished then
				spellObjectiveLearnLabel:SetTextColor(COMPLETED_TEXT_COLOR:GetRGB())
			else
				spellObjectiveLearnLabel:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end
		end)

		hooksecurefunc(cql.Detail, "ShowRequiredMoney", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			if not (content and questID) then return end

			local requiredMoney = C_QuestLog.GetRequiredMoney()

			if requiredMoney > GetMoney() then
				content.RequiredMoneyFrame.RequiredMoneyText:SetTextColor(RED_TEXT_COLOR:GetRGB())
			else
				content.RequiredMoneyFrame.RequiredMoneyText:SetTextColor(COMPLETED_TEXT_COLOR:GetRGB())
			end
		end)

		hooksecurefunc(cql.Detail, "ShowGroupSize", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			local groupNum = C_QuestLog.GetSuggestedGroupSize(questID)
			if not (content and questID and groupNum) then return end

			if (questID > 0) and (groupNum > 0) then
				content.GroupSize:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end
		end)

		hooksecurefunc(cql.Detail, "ShowDescriptionHeader", function(self)
			local content = self.ScrollFrame.Content
			if not (content and content.DescriptionHeader) then return end

			content.DescriptionHeader:SetTextColor(FUBA_HEADER_COLOR:GetRGB())
		end)

		hooksecurefunc(cql.Detail, "ShowDescriptionText", function(self)
			local content = self.ScrollFrame.Content
			local questID = cql.Log:GetSelectedQuest()
			if not (content and questID) then return end

			if (questID > 0) then
				content.DescriptionText:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end
		end)

		hooksecurefunc(cql.Detail, "ShowAccountCompletedNotice", function(self)
			local content = self.ScrollFrame.Content
			if not content then return end
			content.AccountCompletedNotice:SetTextColor(FUBA_QUEST_ACCOUNT_COMPLETED_NOTICE_FONT_COLOR:GetRGB())
		end)

		hooksecurefunc(cql.Detail, "ShowSeal", function(self)
			local content = self.ScrollFrame.Content
			if not content then return end
			local frame = content.SealFrame
			frame.Text:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end)

		hooksecurefunc(cql.Detail, "AcquireRewardButton", function(self)
			local header = self.ScrollFrame.Content.RewardsFrame.Header
			if not header then return end
			header:SetTextColor(FUBA_HEADER_COLOR:GetRGB())
		end)

		hooksecurefunc(cql.Detail, "AddTextToRewards", function(self, fontstring)
			if not fontstring then return end
			fontstring:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end)

		hooksecurefunc(cql.Detail, "FillReward", function(self, rewardButton, questID, rewardType, rewardIndex, objectType, id, name, icon, quality, amount)
			if not rewardButton then return end
			HandleReward(rewardButton)
		end)
	end

	--------------
	--- Chrome ---
	--------------

	-- Both addons inherit ButtonFrameBaseTemplate, which creates $parentCloseButton
	-- Classic Quest Log: ClassicQuestLogCloseButton
	-- Kerzo: KerzosQuestLogCloseButton
	local closeButtonGlobal = isKerzo and KerzosQuestLogCloseButton or ClassicQuestLogCloseButton
	if closeButtonGlobal then
		S:HandleCloseButton(closeButtonGlobal)
	end

	if isKerzo then
		-- Kerzo toolbar buttons
		for _, buttonKey in pairs({"BotonDescartar", "BotonEnviar", "BotonSeguir", "BotonSalir"}) do
			if chromePanel[buttonKey] then
				S:HandleButton(chromePanel[buttonKey])
			end
		end

		hooksecurefunc(chromePanel, "Refrescar", function(self)
			self:StripTextures()
			self:SetTemplate("Transparent")

			if not self.IndicadorMisiones.isSkinned then
				self.IndicadorMisiones:StripTextures()
				self.IndicadorMisiones:SetTemplate(nil, true)
				self.IndicadorMisiones.isSkinned = true
			end
		end)
	else
		-- Classic Quest Log toolbar buttons
		for k, v in pairs({"CloseButton", "AbandonButton", "ShareButton", "TrackButton"}) do
			if cql.Chrome[v] then
				S:HandleButton(cql.Chrome[v])
			end
		end

		hooksecurefunc(cql.Chrome, "Update", function(self)
			self:StripTextures()
			self:SetTemplate("Transparent")

			if not self.CountFrame.isSkinned then
				self.CountFrame:StripTextures()
				self.CountFrame:SetTemplate(nil, true)
				self.CountFrame.isSkinned = true
			end
		end)
	end

	-- maybe skin but not needed really
	--[[
		MapButton / BotonMapaMundi
		OptionsButton / BotonConfig
		SyncFrame.Button / PanelParty.Button
	]]

end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", SkinForElvUI)
