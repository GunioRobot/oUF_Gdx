oUF.TagEvents["[DiffColor]"] = "UNIT_LEVEL"
if not oUF.Tags["[DiffColor]"] then
	oUF.Tags["[DiffColor]"]  = function(unit)
		local r, g, b
		local level = UnitLevel(unit)
		if level < 1 then
			r, g, b = 0.69, 0.31, 0.31
		else
			local DiffColor = UnitLevel("target") - UnitLevel("player")
			if DiffColor >= 5 then
				r, g, b = 0.69, 0.31, 0.31
			elseif DiffColor >= 3 then
				r, g, b = 0.71, 0.43, 0.27
			elseif DiffColor >= -2 then
				r, g, b = 0.84, 0.75, 0.65
			elseif -DiffColor <= GetQuestGreenRange() then
				r, g, b = 0.33, 0.59, 0.33
			else
				r, g, b = 0.55, 0.57, 0.61
			end
		end
		return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end

local colors = setmetatable({
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {
		__index = oUF.colors.happiness
	}),
}, {
	__index = oUF.colors
})

oUF.TagEvents["[GetNameColor]"] = "UNIT_HAPPINESS"
if not oUF.Tags["[GetNameColor]"] then
	oUF.Tags["[GetNameColor]"] = function(unit)
		local reaction = UnitReaction(unit, "player")
		if unit == "pet" and GetPetHappiness() then
			local c = colors.happiness[GetPetHappiness()]
			return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
		elseif UnitIsPlayer(unit) then
			return oUF.Tags["[raidcolor]"](unit)
		elseif reaction then
			local c =  colors.reaction[reaction]
			return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
		else
			r, g, b = .84,.75,.65
			return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
		end
	end
end

local numberize = function(val)
	if val >= 1e6 then
        return ("%.1fm"):format(val / 1e6)
	elseif val >= 1e3 then
		return ("%.1fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end

local utf8sub = function(string, i, dots)
	local bytes = string:len()
	if bytes <= i then
		return string
	else
		local len, pos = 0, 1
		while pos <= bytes do
			len = len + 1
			local c = string:byte(pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if len == i then
				break
			end
		end

		if len == i and pos <= bytes then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

oUF.TagEvents["[NameShort]"] = "UNIT_NAME_UPDATE"
if not oUF.Tags["[NameShort]"] then
	oUF.Tags["[NameShort]"] = function(unit)
		local name = UnitName(unit)
		return utf8sub(name, 6, false)
	end
end

oUF.TagEvents["[NameMedium]"] = "UNIT_NAME_UPDATE"
if not oUF.Tags["[NameMedium]"] then
	oUF.Tags["[NameMedium]"] = function(unit)
		local name = UnitName(unit)
		if unit == "pet" and name == "Unknown" then
			return "Pet"
		else
			return utf8sub(name, 18, true)
		end
	end
end

oUF.TagEvents["[NameLong]"] = "UNIT_NAME_UPDATE"
if not oUF.Tags["[NameLong]"] then
	oUF.Tags["[NameLong]"] = function(unit)
		local name = UnitName(unit)
		return utf8sub(name, 36, true)
	end
end

oUF.TagEvents["[RaidHP]"] = "UNIT_NAME_UPDATE UNIT_HEALTH UNIT_MAXHEALTH"
if not oUF.Tags["[RaidHP]"] then
	oUF.Tags["[RaidHP]"] = function(unit)
		if not unit then
			return
		end
		
		local def = oUF.Tags["[missinghp]"](unit)		
		local per = oUF.Tags["[perhp]"](unit)
		local result
		if UnitIsDead(unit) then
			result = "Dead"
		elseif UnitIsGhost(unit) then
			result = "Ghost"
		elseif not UnitIsConnected(unit) then
			result = "D/C"
		elseif per < 90 and def then
			result = "-"..numberize(def)
		else
			result = utf8sub(UnitName(unit), 4) or "N/A"
		end
		
		return result
	end
end


local L = {
	["Prayer of Mending"] = GetSpellInfo(33076),
	["Gift of the Naaru"] = GetSpellInfo(59542),
	["Renew"] = GetSpellInfo(139),
	["Power Word: Shield"] = GetSpellInfo(17),
	["Weakened Soul"] = GetSpellInfo(6788),
	["Prayer of Shadow Protection"] = GetSpellInfo(27683),
	["Shadow Protection"] = GetSpellInfo(976),
	["Prayer of Fortitude"] = GetSpellInfo(21562),
	["Power Word: Fortitude"] = GetSpellInfo(1243),
	["Divine Spirit"] = GetSpellInfo(48073),
	["Prayer of Spirit"] = GetSpellInfo(48074),
	["Fear Ward"] = GetSpellInfo(6346),
	["Lifebloom"] = GetSpellInfo(33763),
	["Rejuvenation"] = GetSpellInfo(774),
	["Regrowth"] = GetSpellInfo(8936),
	["Wild Growth"] = GetSpellInfo(48438),
	["Tree of Life"] = GetSpellInfo(33891),
	["Gift of the Wild"] = GetSpellInfo(48470),
	["Mark of the Wild"] = GetSpellInfo(48469),
	["Horn of Winter"] = GetSpellInfo(57623),
	["Battle Shout"] = GetSpellInfo(47436),
	["Commanding Shout"] = GetSpellInfo(47440),
	["Vigilance"] = GetSpellInfo(50720),
	["Magic Concentration"] = GetSpellInfo(54646),
	["Beacon of Light"] = GetSpellInfo(53563),
	["Sacred Shield"] = GetSpellInfo(53601),
	["Earth Shield"] = GetSpellInfo(49284),
	["Riptide"] = GetSpellInfo(61301),
	["Flash of Light"] = GetSpellInfo(66922)
}
local x = "M"

local getTime = function(expirationTime)
	if expirationTime > 0 then
		local timeleft = format("%.0f",-1*(GetTime()-expirationTime))
		local spellTimer = "|cffffff00"..timeleft.."|r"
		return spellTimer
	end
	
	return 0
end

-- Priest
oUF.pomCount = {"i","h","g","f","Z","Y"}
oUF.Tags["[pom]"] = function(u) local c = select(4, UnitAura(u, L["Prayer of Mending"])) if c then return "|cffFFCF7F"..oUF.pomCount[c].."|r" end end
oUF.TagEvents["[pom]"] = "UNIT_AURA"
oUF.Tags["[gotn]"] = function(u) if UnitAura(u, L["Gift of the Naaru"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents["[gotn]"] = "UNIT_AURA"
oUF.Tags["[rnw]"] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Renew"])
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Renew"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents["[rnw]"] = "UNIT_AURA"

oUF.Tags["[ad]"] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, "Abolish Disease")
  if not (fromwho == "player") then return end
  if UnitAura(u, "Abolish Disease") then return "|cffFFFF33"..x.."|r" end end
oUF.TagEvents["[ad]"] = "UNIT_AURA"

-- rnwtime
oUF.Tags["[rnwTime]"] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Renew"])
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents["[rnwTime]"] = "UNIT_AURA"
oUF.Tags["[pws]"] = function(u) if UnitAura(u, L["Power Word: Shield"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents["[pws]"] = "UNIT_AURA"
oUF.Tags["[ws]"] = function(u) if UnitDebuff(u, L["Weakened Soul"]) then return "|cffFF9900"..x.."|r" end end
oUF.TagEvents["[ws]"] = "UNIT_AURA"
oUF.Tags["[fw]"] = function(u) if UnitAura(u, L["Fear Ward"]) then return "|cff8B4513"..x.."|r" end end
oUF.TagEvents["[fw]"] = "UNIT_AURA"
oUF.Tags["[sp]"] = function(u) local c = UnitAura(u, L["Prayer of Shadow Protection"]) or UnitAura(u, "Shadow Protection") if not c then return "|cff9900FF"..x.."|r" end end
oUF.TagEvents["[sp]"] = "UNIT_AURA"
oUF.Tags["[fort]"] = function(u) local c = UnitAura(u, L["Prayer of Fortitude"]) or UnitAura(u, L["Power Word: Fortitude"]) if not c then return "|cff00A1DE"..x.."|r" end end
oUF.TagEvents["[fort]"] = "UNIT_AURA"
oUF.Tags["[ds]"] = function(u) local c = UnitAura(u, L["Prayer of Spirit"]) or UnitAura(u, L["Divine Spirit"]) if not c then return "|cffffff00"..x.."|r" end end
oUF.TagEvents["[ds]"] = "UNIT_AURA"

--druid
oUF.lbCount = { 4, 2, 3 }
oUF.Tags["[lb]"] = function(u) 
	local name, _,_, c,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Lifebloom"])
	if not (fromwho == "player") then return end
	local spellTimer = GetTime()-expirationTime
	if spellTimer > -2 then
		return "|cffFF0000"..oUF.lbCount[c].."|r"
	else
		return "|cffA7FD0A"..oUF.lbCount[c].."|r"
	end
end
oUF.TagEvents["[lb]"] = "UNIT_AURA"
oUF.Tags["[rejuv]"] = function(u) 
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Rejuvenation"])
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Rejuvenation"]) then return "|cff00FEBF"..x.."|r" end end
oUF.TagEvents["[rejuv]"] = "UNIT_AURA"
-- rejuvtime
oUF.Tags["[rejuvTime]"] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Rejuvenation"])
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents["[rejuvTime]"] = "UNIT_AURA"
oUF.Tags["[regrow]"] = function(u) if UnitAura(u, L["Regrowth"]) then return "|cff00FF10"..x.."|r" end end
oUF.TagEvents["[regrow]"] = "UNIT_AURA"
oUF.Tags["[wg]"] = function(u) if UnitAura(u, L["Wild Growth"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents["[wg]"] = "UNIT_AURA"
oUF.Tags["[tree]"] = function(u) if UnitAura(u, L["Tree of Life"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents["[tree]"] = "UNIT_AURA"
oUF.Tags["[gotw]"] = function(u) local c = UnitAura(u, L["Gift of the Wild"]) or UnitAura(u, L["Mark of the Wild"]) if not c then return "|cffFF00FF"..x.."|r" end end
oUF.TagEvents["[gotw]"] = "UNIT_AURA"

--warrior
oUF.Tags["[Bsh]"] = function(u) if UnitAura(u, L["Battle Shout"]) then return "|cffff0000"..x.."|r" end end
oUF.TagEvents["[Bsh]"] = "UNIT_AURA"
oUF.Tags["[Csh]"] = function(u) if UnitAura(u, L["Commanding Shout"]) then return "|cffffff00"..x.."|r" end end
oUF.TagEvents["[Csh]"] = "UNIT_AURA"
oUF.Tags["[vigil]"] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Vigilance"])
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Vigilance"]) then return "|cffDEB887"..x.."|r" end end
oUF.TagEvents["[vigil]"] = "UNIT_AURA"

--deathknight
oUF.Tags["[how]"] = function(u) if UnitAura(u, L["Horn of Winter"]) then return "|cffffff10"..x.."|r" end end
oUF.TagEvents["[how]"] = "UNIT_AURA"

--mage
oUF.Tags["[mc]"] = function(u) if UnitAura(u, L["Magic Concentration"]) then return "|cffffff00"..x.."|r" end end
oUF.TagEvents["[mc]"] = "UNIT_AURA"

--paladin
oUF.Tags["[sacred]"] = function(u) if UnitAura(u, L["Sacred Shield"]) then return "|cffffff10"..x.."|r" end end
oUF.TagEvents["[sacred]"] = "UNIT_AURA"
oUF.Tags["[beacon]"] = function(u) if UnitAura(u, L["Beacon of Light"]) then return "|cffffff10"..x.."|r" end end
oUF.TagEvents["[beacon]"] = "UNIT_AURA"
oUF.Tags["[selfsacred]"] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Sacred Shield"])
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Sacred Shield"]) then return "|cffff33ff"..x.."|r" end end
oUF.TagEvents["[selfsacred]"] = "UNIT_AURA"
oUF.Tags["[selfbeacon]"] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Beacon of Light"])
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Beacon of Light"]) then return "|cffff33ff"..x.."|r" end end
oUF.TagEvents["[selfbeacon]"] = "UNIT_AURA"
oUF.Tags["[beaconTime]"] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Beacon of Light"])
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents["[beaconTime]"] = "UNIT_AURA"
oUF.Tags["[FoLTime]"] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Flash of Light"])
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents["[FoLTime]"] = "UNIT_AURA"

--shaman
oUF.Tags["[rip]"] = function(u) 
	local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Riptide"])
	if not (fromwho == "player") then return end
	if UnitAura(u, L["Riptide"]) then return "|cff00FEBF"..x.."|r" end end
oUF.TagEvents["[rip]"] = "UNIT_AURA"

oUF.Tags["[ripTime]"] = function(u)
	local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Riptide"])
	if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents["[ripTime]"] = "UNIT_AURA"

oUF.earthCount = {
	"i",
	"h",
	"g",
	"f",
	"p",
	"q",
	"Z",
	"Y"
}
oUF.Tags["[earth]"] = function(u)
	local c = select(4, UnitAura(u, L["Earth Shield"]))
	if c then
		return "|cffFFCF7F"..oUF.earthCount[c].."|r"
	end
end
oUF.TagEvents["[earth]"] = "UNIT_AURA"


oUF.classIndicators = {
	["DRUID"] = {
		["TL"] = "[tree]",
		["TR"] = "[gotw]",
		["BL"] = "[regrow][wg]",
		["BR"] = "[lb]",
	},
	["PRIEST"] = {
		["TL"] = "[pws][ws]",
		["TR"] = "[ds][sp][fort][fw]",
		["BL"] = "[rnw] [ad]",
		["BR"] = "[pom]",
	},
	["PALADIN"] = {
		["TL"] = "[selfsacred][sacred]",
		["TR"] = "[selfbeacon][beacon]",
		["BL"] = "",
		["BR"] = "",
	},
	["WARLOCK"] = {
		["TL"] = "",
		["TR"] = "",
		["BL"] = "",
		["BR"] = "",
	},
	["WARRIOR"] = {
		["TL"] = "[vigil]",
		["TR"] = "",
		["BL"] = "",
		["BR"] = "",
	},
	["DEATHKNIGHT"] = {
		["TL"] = "",
		["TR"] = "[how]",
		["BL"] = "",
		["BR"] = "",
	},
	["SHAMAN"] = {
		["TL"] = "[rip]",
		["TR"] = "",
		["BL"] = "",
		["BR"] = "[earth]",
	},
	["HUNTER"] = {
		["TL"] = "",
		["TR"] = "",
		["BL"] = "",
		["BR"] = "",
	},
	["ROGUE"] = {
		["TL"] = "",
		["TR"] = "",
		["BL"] = "",
		["BR"] = "",
	},
	["MAGE"] = {
		["TL"] = "",
		["TR"] = "[mc]",
		["BL"] = "",
		["BR"] = "",
	}
}