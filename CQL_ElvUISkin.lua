local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

local DEFAULT_TEXT_COLOR = CreateColor(1,1,1,1)
local COMPLETED_TEXT_COLOR = CreateColor(0.2,1,0.2,1)
local RED_TEXT_COLOR = CreateColor(0.5,0,0,1)

local FUBA_HEADER_COLOR = CreateColor(1,0.8,0.1,1)
local FUBA_QUEST_ACCOUNT_COMPLETED_NOTICE_FONT_COLOR = CreateColor(0.4,0.4,0.4,1)

local function InvertColor(r, g, b)
    return 1 - r, 1 - g, 1 - b
end

local function SkinForElvUI()

	if (not IsAddOnLoaded("ElvUI")) then return end
	if (not IsAddOnLoaded("Classic Quest Log")) then return end

	local E, L, V, P, G = unpack(ElvUI)
	local S = E:GetModule('Skins')

	local cql = ClassicQuestLog

	cql:StripTextures()
	cql:SetTemplate("Transparent")

	-----------
	--- Log ---
	-----------

	hooksecurefunc(cql.Log, "Update", function(self)
		local content = self.ScrollFrame.Content

		self:StripTextures()
		self:SetTemplate("Transparent")

		S:HandleTrimScrollBar(self.ScrollFrame.ScrollBar)

		local somethingExpanded = self:IsSomethingExpanded()
		local AllButton = self.ScrollFrame.AllButton
		AllButton:StripTextures()
		AllButton:SetNormalTexture(somethingExpanded and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton)
		AllButton:SetPushedTexture(somethingExpanded and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton)
		AllButton:ClearAllPoints()
		AllButton:SetPoint('BOTTOMLEFT', cql, 'TOPLEFT', 6, -55)

		local buttons = content.Buttons

		for index, button in ipairs(buttons) do
			local expandButton = button.ExpandButton
			local info = button.info
			if expandButton and info then
				button.expandAtlas = cql.settings.CollapsedHeaders[info.title] and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton
				expandButton:SetTexture(cql.settings.CollapsedHeaders[info.title] and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton)
			end
		end
	end)

	---------------
	--- Options ---
	---------------

	hooksecurefunc(cql.Options, "Update", function(self)
		self:StripTextures()
		self:SetTemplate("Transparent")

		S:HandleTrimScrollBar(self.ScrollFrame.ScrollBar)
	end)

	---------------
	--- Details ---
	---------------

	hooksecurefunc(cql.Detail, "Update", function(self)
		self:StripTextures()
		self:SetTemplate("Transparent")

		S:HandleTrimScrollBar(self.ScrollFrame.ScrollBar)
	end)

	hooksecurefunc(cql.Detail, "ShowTitle", function(self)
		local content = self.ScrollFrame.Content
		if not content then return end
		content.TitleHeader:SetTextColor(FUBA_HEADER_COLOR:GetRGB())
	end)

	hooksecurefunc(cql.Detail, "ShowStatusTitle", function(self)
		local content = self.ScrollFrame.Content
		local questID = cql.Log:GetSelectedQuest()
		if not (content and questID) then return end

		if questID>0 and C_QuestLog.IsQuestDisabledForSession(questID) then
			content.StatusTitle:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
		end
	end)

	hooksecurefunc(cql.Detail, "ShowStatusText", function(self)
		local content = self.ScrollFrame.Content
		local questID = cql.Log:GetSelectedQuest()
		if not (content and questID) then return end

		if questID>0 and C_QuestLog.IsQuestDisabledForSession(questID) then
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
				objective:SetTextColor(DEFAULT_TEXT_COLOR:GetRGB())
			end

			for i=1,numObjectives do
				text,type,finished = GetQuestLogLeaderBoard(i)
				if (type~="spell" and type~="log" and numVisibleObjectives<MAX_OBJECTIVES) then
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


	--------------
	--- Chrome ---
	--------------

	S:HandleCloseButton(ClassicQuestLogCloseButton)

	for k,v in pairs({"CloseButton","AbandonButton","ShareButton","TrackButton"}) do
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


	-- maybe skin but not needed really
	--[[
		MapButton
		OptionsButton
		SyncFrame.Button
	]]

end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", SkinForElvUI)
--EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", SkinForElvUI)