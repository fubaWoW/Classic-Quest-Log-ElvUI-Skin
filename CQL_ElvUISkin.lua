if not ClassicQuestLog then return end
local cql = ClassicQuestLog

local function SkinForElvUI()
  local E, L, P, G = unpack(ElvUI)
  local S = E:GetModule("Skins")

  cql:StripTextures()
  cql:SetTemplate("Transparent")

	-- fix if BackdropTemplate is missing
	Mixin(ClassicQuestLogDetailScrollFrame, BackdropTemplateMixin)
	Mixin(cql.detail, BackdropTemplateMixin)

  S:HandleCloseButton(cql.CloseButton)

  for k,v in pairs({"abandonButton","pushButton","trackButton","closeButton","optionsButton","syncButton"}) do
    if cql.chrome[v] then
      S:HandleButton(cql.chrome[v])
    end
  end

  S:HandleScrollBar(ClassicQuestLogScrollFrameScrollBar)
	
  S:HandleScrollBar(ClassicQuestLogDetailScrollFrameScrollBar)
	
  ClassicQuestLogOptionsScrollFrame:SetTemplate("Transparent")
  S:HandleScrollBar(ClassicQuestLogOptionsScrollFrameScrollBar)
	
  ClassicQuestLogLoreScrollFrame:SetTemplate("Transparent")
  S:HandleScrollBar(ClassicQuestLogLoreScrollFrameScrollBar)

  for k,v in pairs({"LockWindow","ShowResizeGrip","ShowLevels","ShowTooltips","ShowFromObjectiveTracker","DontOverrideBind","ShowMinimapButton","UseCustomScale"}) do
		if ClassicQuestLogOptionsScrollFrame then
			local cb = ClassicQuestLogOptionsScrollFrame.content[v].check
			if cb then S:HandleCheckBox(cb) end
		end
  end

	-- skin the Quest Counter
  cql.chrome.countFrame:StripTextures()
  cql.chrome.countFrame:SetTemplate(nil, true)
  cql.chrome.countFrame.isSkinned = true
	
	-- fix Quest Count for Retail, becasue it is not 35 and Blizzard forgot to Update EVERYTHING at Client side...
	hooksecurefunc(cql.chrome, "Update", function(self)
		local maxquests = select(4,GetBuildInfo()) > 99999 and 35 or 25
		cql.chrome.countFrame.text:SetText(format("%s \124cffffffff%d/%d",QUESTS_COLON,cql.log.numQuests or 0,maxquests))
	end)

	-- skin the "campaignTooltip"
	cql.campaignTooltip:StripTextures()
	cql.campaignTooltip:SetTemplate(nil, true)
	cql.campaignTooltip.isSkinned = true

	-- hook "UpdateListButton" to Skin the "expand" Buttton from Quest Headers
	hooksecurefunc(cql.log, "UpdateListButton", function(self, button, info)
		if ((not button) or (not info) or (type(info)~="table")) then return end

		if info.isHeader then
			local collapsedHeaders = ClassicQuestLogCollapsedHeaders
			if button and button.expand then
				local isCollapsed = collapsedHeaders[info.title]
				button:StripTextures()
				button.expand:StripTextures()
				button.expand:SetTexture(isCollapsed and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton)
			end
		else
		end

  end)

	-- Skin and repositioning the "expandAll" Button
	cql.log.expandAll:StripTextures()
  cql.log.expandAll:ClearAllPoints()
  cql.log.expandAll:SetPoint('BOTTOMLEFT', cql, 'TOPLEFT', -1, -50)
	
	hooksecurefunc(cql.log, "HybridScrollFrameUpdate", function(self)
    local quests = cql.log.quests
    local numEntries = #quests

    if numEntries ~= 0 then
      cql.log.expandAll:SetNormalTexture(cql.log.somethingExpanded and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton)
    end
  end)
end


cql:RegisterEvent("PLAYER_LOGIN")
cql:HookScript("OnEvent", function(self, event, addon, ...)
	if event == "PLAYER_LOGIN" then
		if IsAddOnLoaded("ElvUI") then SkinForElvUI() end
	end
end)