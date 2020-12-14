if not ClassicQuestLog then return end
local cql = ClassicQuestLog

local function SkinForElvUI()
  local E, L, P, G = unpack(ElvUI)
  local S = E:GetModule("Skins")

  cql:StripTextures()
  cql:SetTemplate("Transparent")
	
	-- fixed "cql.detail" missing BackdropTemplate
	Mixin(cql.detail, BackdropTemplateMixin)

  S:HandleCloseButton(cql.CloseButton)

  for k,v in pairs({"abandonButton","pushButton","trackButton","closeButton","optionsButton","syncButton"}) do
    if cql.chrome[v] then
      S:HandleButton(cql.chrome[v])
    end
  end

  --ClassicQuestLogScrollFrame:StripTextures()
  S:HandleScrollBar(ClassicQuestLogScrollFrameScrollBar)

  --ClassicQuestLogDetailScrollFrame:StripTextures()
  S:HandleScrollBar(ClassicQuestLogDetailScrollFrameScrollBar)

  --cql.options:StripTextures()
  ClassicQuestLogOptionsScrollFrame:SetTemplate("Transparent")
  S:HandleScrollBar(ClassicQuestLogOptionsScrollFrameScrollBar)
	
	--cql.lore:StripTextures()
  ClassicQuestLogLoreScrollFrame:SetTemplate("Transparent")
  S:HandleScrollBar(ClassicQuestLogLoreScrollFrameScrollBar)
	
  for k,v in pairs({"LockWindow","ShowResizeGrip","ShowLevels","ShowTooltips","SolidBackground","ShowFromObjectiveTracker"}) do
    local cb = ClassicQuestLogOptionsScrollFrame.content[v].check
    if cb then S:HandleCheckBox(cb) end
  end

  cql.chrome.countFrame:StripTextures()
  cql.chrome.countFrame:SetTemplate(nil, true)
  cql.chrome.countFrame.isSkinned = true

  ClassicQuestLogScrollFrame.expandAll:StripTextures()
  ClassicQuestLogScrollFrame.expandAll:ClearAllPoints()
  ClassicQuestLogScrollFrame.expandAll:SetPoint('BOTTOMLEFT', cql, 'TOPLEFT', -1, -50)

  hooksecurefunc(ClassicQuestLogScrollFrame, "UpdateListButton", function(self, button, info)
    if ((not button) or (not info) or (type(info)~="table")) then return end

    if info.isHeader then
      local isCollapsed = ClassicQuestLogCollapsedHeaders[info.title]
      button:SetNormalTexture(isCollapsed and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton)
    end
  end)

  hooksecurefunc(ClassicQuestLogScrollFrame, "UpdateLog", function(self)
    local quests = cql.log.quests
    local numEntries = #quests

    if numEntries ~= 0 then
      cql.log.expandAll:SetNormalTexture(cql.log.somethingExpanded and E.Media.Textures.MinusButton or E.Media.Textures.PlusButton)
    end
  end)
	
	--[[
	-- force "Dark Background" for ElvUI and disable "SolidBackground" button and CheckButton
	ClassicQuestLog.options:Set("SolidBackground", true)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"].check:SetScript("OnEnter", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"].check:SetScript("OnLeave", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"].check:SetScript("OnClick", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"].check:SetScript("OnShow", function(self)
		self:SetChecked(true)
		self:SetEnabled(false)
	end)
	
		
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"]:SetScript("OnEnter", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"]:SetScript("OnLeave", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"]:SetScript("OnMouseDown", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"]:SetScript("OnMouseUp", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"]:SetScript("OnClick", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"]:SetScript("OnLoad", nil)
	ClassicQuestLogOptionsScrollFrame.content["SolidBackground"]:SetScript("OnShow", function(self)
		if not self.text.disabledbyskin then
			local text = self.text:GetText()
			self.text:SetText(text.." (disabled by Skin)")
			self.text.disabledbyskin = true
		end
		self.text:SetTextColor(1,0.82,0,0.25)
		self.description:SetTextColor(1,1,1,0.25)
	end)
	]]
end


cql:RegisterEvent("PLAYER_LOGIN")
cql:HookScript("OnEvent", function(self, event, addon, ...)
	if event == "PLAYER_LOGIN" then
		if IsAddOnLoaded("ElvUI") then SkinForElvUI() end
	end
end)