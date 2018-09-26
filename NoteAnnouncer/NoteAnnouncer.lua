-- NoteAnnouncer
-- Version 1.0.5
-- Created By: Mortur
-- Special thanks to: Elearin, Akea - for helping to test!

-- |Hplayer:name|h[Name]|h

SLASH_NOTEANNOUNCER1 = "/notea"

local NoteAnnouncer = {}

local frame = CreateFrame("Frame", nil, PlayerFrame)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    NoteAnnouncer:Initialize()
  end
  if event == "ADDON_LOADED" then
    local AddonName = ...;
    if AddonName == "NoteAnnouncer" then
      NoteAnnouncer:Loaded()
    end
  end
end)

NoteAnnouncer.frame = frame


function NoteAnnouncer:Initialize()
  NoteAnnouncer.frame:RegisterEvent("CHAT_MSG_SYSTEM")
  NoteAnnouncer.frame:SetScript("OnEvent", RelayMessagetest)
end


function GetSystemChatWindows()
  local returnArray = {}
  local k = 1
  
  for i=1, NUM_CHAT_WINDOWS do
    local ChatWindowMessage = { GetChatWindowMessages(i) };
    for j = 1, #ChatWindowMessage do
    
      local Message = ChatWindowMessage[j]
      
      if Message == "SYSTEM" then
        returnArray[k] = i
        k = k + 1
      end
    end
  end
  return returnArray
end


function PrintInSystemWindows(message)
  SystemChatWindows = GetSystemChatWindows()
  for i=1, #SystemChatWindows do
    this = getglobal("ChatFrame"..SystemChatWindows[i])
    this:AddMessage(message)
  end
end

function NoteAnnouncer:Loaded()

  
  if (NoteAnnounceConfig == nil) then
    NoteAnnounceConfig = {}
    NoteAnnounceConfig['ShowRank'] = 1;
    NoteAnnounceConfig['ShowGuildNote'] = 1;
    NoteAnnounceConfig['ShowOfficerNote'] = 1;
    NoteAnnounceConfig['ShowFriendNote'] = 1;
    print("|cFFFFFF00NoteAnnouncer: |rNo config found - Set to Defaults")
  end 
  
  
end

function SlashCmdList.NOTEANNOUNCER(msg, editbox)
  
  local command, arg = msg:match("^(%S*)%s*(.-)$");
  local onOff = ""
  local optionName = ""
  local cleanCommand = ""
  
  if string.lower(command) == string.lower("Show") then
    cleanCommand = "Show"
  elseif string.lower(command) == string.lower("Rank") then
    cleanCommand = "Rank"
  elseif string.lower(command) == string.lower("GuildNote") then
    cleanCommand = "GuildNote"
  elseif string.lower(command) == string.lower("OfficerNote") then
    cleanCommand = "OfficerNote"
  elseif string.lower(command) == string.lower("FriendNote") then
    cleanCommand = "FriendNote"
  elseif string.lower(command) == string.lower("Help") then
    cleanCommand = "Help"
  end
  
  if cleanCommand ~= "" then
  
    if cleanCommand == "Show" and arg == "" then
      print("|cFFFFFF00NoteAnnouncer: Current Settings");
      for key,value in pairs(NoteAnnounceConfig) do
        if value == 1 then
          onOff = "On"
        else
          onOff = "Off"
        end
        optionName = string.sub(key, 5)
        print("|cFFFFFF00"..optionName..": |cFFAAAAFF"..onOff);
      end
    elseif cleanCommand == "Help" and arg == "" then
      print ("|cFFFFFF00NoteAnnouncer Help File")
      print ("|cFFFFFF00 /notea Help |r- This help documentation")
      print ("|cFFFFFF00 /notea Show |r- Displays all the current config settings")
      print ("|cFFFFFF00 /notea Rank |cFFAAAAFFOn/Off |r- Turns On or Off the Guild Rank display")
      print ("|cFFFFFF00 /notea GuildNote |cFFAAAAFFOn/Off |r- Turns On or Off the Guild Note display")
      print ("|cFFFFFF00 /notea OfficerNote |cFFAAAAFFOn/Off |r- Turns On or Off the Guild Officer Note display")
      print ("|cFFFFFF00 /notea FriendNote |cFFAAAAFFOn/Off |r- Turns On or Off the Friend Note display")
    elseif NoteAnnounceConfig["Show"..cleanCommand] ~= nil and arg ~= "" then
      if string.lower(arg) == string.lower("On") then
        NoteAnnounceConfig["Show"..cleanCommand] = 1;
        print("|cFFFFFF00"..cleanCommand .. " is now set to |cFFAAAAFFON")
      elseif string.lower(arg) == string.lower("off") then
        NoteAnnounceConfig["Show"..cleanCommand] = 0;
        print("|cFFFFFF00"..cleanCommand .. " is now set to |cFFAAAAFFOFF")
      else
        print("Option Not Recognized")
      end
    else
      print("Command Not Recognized: "..NoteAnnounceConfig["Show"..cleanCommand])
    end
  else
    print("Command Not Recognized. Use '/notea help' for instructions")
  end
  
end



function RelayMessagetest(this, event, ...)
  
  if event == "CHAT_MSG_SYSTEM" then
  
    local Name = nil
    
    local systemMessage = ...

    whostart, whoend, whoName, trash1, trash2 = string.find(systemMessage, "|Hplayer:(.+)|h%[(.+)Level(.+)");
    loginstart, loginEnd, loginName, trash1 = string.find(systemMessage, "|Hplayer:(.+)|h%[(.+)has come online.");
    
    if (whostart ~= nil or loginstart ~= nil or logoutstart ~= nil) then
      if (whostart ~= nil) then
        Name = whoName;
      end
      if (loginstart ~= nil) then
        Name = loginName;
      end
    
    end
    
    if(Name ~= nil) then
    
      local saveRosterSetting = GetGuildRosterShowOffline()
      
      SetGuildRosterShowOffline(1)

      local playername = Name
      local GuildName, GuildRankName, GuildRankIndex = GetGuildInfo(playername)
      local numMembers = GetNumGuildMembers()
      
      local i = 1
      while (i <= numMembers) do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName  = GetGuildRosterInfo(i)
	
	local name2, server, name3, server2 = string.find(name, "(.+)-(.+)");

        if (name3 == playername) then
          local outputMessage = " "
          
          if (rank ~= "") and (NoteAnnounceConfig["ShowRank"] == 1) then
            outputMessage = outputMessage .. "|cFFFFFF00Rank: |r" .. rank
          end
          
          if (note ~= "") and (NoteAnnounceConfig["ShowGuildNote"] == 1) then
            outputMessage = outputMessage .. "  |cFFFFFF00Guild Note: |r" .. note
          end
          
          if (officernote ~= "") and (NoteAnnounceConfig["ShowOfficerNote"] == 1) then
            outputMessage = outputMessage .. "  |cFFFFFF00Officer Note: |r" .. officernote
          end
          
          if outputMessage ~= " " then
            PrintInSystemWindows(outputMessage);
          end
          
          i = numMembers
        end
        
        i = i + 1
      end
      
      
      local numFriends = GetNumFriends()
      
      local k = 1
      while (k <= numFriends) do
        local name, level , class, loc, connected, status, note = GetFriendInfo(k);
        
        if (name == playername) and (NoteAnnounceConfig["ShowFriendNote"] == 1) then
          
          if (note == nil) then
            note = " "
          end          
          
          ChatFrame1:AddMessage(" |cFFFFFF00Friend Note: |r" .. note)
          
          k = numFriends
        end
        
        k = k + 1
      end
            
      SetGuildRosterShowOffline(saveRosterSetting)
    
    end
    
  end
end