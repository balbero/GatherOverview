---@class addonTableGatherOverview
local addonTable = select(2, ...)
addonTable.Config = {}

addonTable.Config.Options = {}
addonTable.Config.Defaults = {}

local settings = {
    -- Profession settings
    PROFESSIONS = { key = "Professions", default = {
        MINING = {
          current_profession = addonTable.Constants.MINING,
          enabled = true,
          display = true,
          low = 50,
          low_color = addonTable.Colors.red,
          medium_color = addonTable.Colors.orange,
          high = 100,
          high_color = addonTable.Colors.green,
          icon_width = 32,
          icon_height = 32,
          position = nil,
          width = 375,
          height = 150,
          showInInstance = false,
          showInRestingZone = false,
          showDuringCombat = false,
          locked = false,
        },
        HERBALISM = {
          current_profession = addonTable.Constants.HERBALISM,
          enabled = true,
          display = true,
          low = 50,
          low_color = addonTable.Colors.red,
          medium_color = addonTable.Colors.orange,
          high = 100,
          high_color = addonTable.Colors.green,
          icon_width = 32,
          icon_height = 32,
          position = nil,
          width = 375,
          height = 150,
          showInInstance = false,
          showInRestingZone = false,
          showDuringCombat = false,
          locked = false,
        },
        SKINNING = {
          current_profession = addonTable.Constants.SKINNING,
          enabled = true,
          display = true,
          low = 50,
          low_color = addonTable.Colors.red,
          medium_color = addonTable.Colors.orange,
          high = 100,
          high_color = addonTable.Colors.green,
          icon_width = 32,
          icon_height = 32,
          position = nil,
          width = 375,
          height = 150,
          showInInstance = false,
          showInRestingZone = false,
          showDuringCombat = false,
          locked = false,
        },
        FISHING = {
          current_profession = addonTable.Constants.FISHING,
          enabled = true,
          display = true,
          low = 50,
          low_color = addonTable.Colors.red,
          medium_color = addonTable.Colors.orange,
          high = 100,
          high_color = addonTable.Colors.green,
          icon_width = 32,
          icon_height = 32,
          position = nil,
          width = 375,
          height = 150,
          showInInstance = false,
          showInRestingZone = false,
          showDuringCombat = false,
          locked = false,
        },
        OTHER_STUFF = {
          current_profession = addonTable.Constants.OTHER_STUFF,
          enabled = true,
          display = true,
          low = 50,
          low_color = addonTable.Colors.red,
          medium_color = addonTable.Colors.orange,
          high = 100,
          high_color = addonTable.Colors.green,
          icon_width = 32,
          icon_height = 32,
          position = nil,
          width = 375,
          height = 150,
          showInInstance = false,
          showInRestingZone = false,
          showDuringCombat = false,
          locked = false,
        },
     }},
    -- Threshold management
    LOW_THRESHOLD = { key = "LowThreshold", default = 50 },
    LOW_THRESHOLD_COLOR = { key = "LowThresholdColor", default = addonTable.Colors.red },
    MEDIUM_THRESHOLD_COLOR = { key = "MediumThresholdColor", default = addonTable.Colors.orange },
    HIGH_THRESHOLD = { key = "HighThreshold", default = 100 },
    HIGH_THRESHOLD_COLOR = { key = "HighThresholdColor", default = addonTable.Colors.green },
    -- Icon related
    ICON_WITDH = {key="IconWidth", default = 32},
    ICON_HEIGHT = {key="IconHeight", default = 32},
    ROW_AMOUNT = {key="RowAmount", default = 3},
    -- Global options
    SHOW_TOTAL = { key = "ShowTotal", default = true },
    FONT = { key = "Font", default = {name = "Friz Quadrata", path ="Fonts\\FRIZQT__.TTF"}},
    FONT_SIZE = { key = "FontSize", default = 12 },
    BG_COLOR = { key = "BackgroundColor", default = {r = .2, b = .2, g = .2, a = 0.2} },
    BORDER = { key = "BorderColor", default = addonTable.Colors.black },
    HEADER_ICON_SIZE = { key = "headerIconSize", default = 22 },
    HEADER_FONT_SIZE = { key = "headerFontSize", default = 11 },
}

for key, details in pairs(settings) do
    addonTable.Config.Options[key] = details.key
    if type(details.default) == "table" then
      addonTable.Config.Defaults[details.key] = CopyTable(details.default)
    else
      addonTable.Config.Defaults[details.key] = details.default
    end
end


function addonTable.Config.GetProfessionNameFromIndex(professionIndex)
    for _, p in ipairs(addonTable.Profession) do
        if p.id == professionIndex then
            return p.name
        end
    end
    addonTable.Utilities.Message("No name for profession index "..professionIndex)
end

--------------------------------------------------
--- Profile management
--------------------------------------------------

local function DeepMergeDefaults(dest, src)
    -- Merge src into dest, only filling in keys that don't exist yet
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dest[k]) ~= "table" then
                dest[k] = {}
            end
            DeepMergeDefaults(dest[k], v)
        else
            if dest[k] == nil then
                dest[k] = v
            end
        end
    end
end

local function ImportDefaultsToProfile()
  DeepMergeDefaults(addonTable.Config.CurrentProfile, addonTable.Config.Defaults)
end

function addonTable.Config.InitializeData()
      if GATHEROVERVIEW_CONFIG == nil then
        addonTable.Config.ResetProfile()
        return
    end

    if GATHEROVERVIEW_CONFIG.Profiles == nil then
        GATHEROVERVIEW_CONFIG = {
            Profiles = {
            DEFAULT = GATHEROVERVIEW_CONFIG,
            },
            Version = addonTable.Constants.DB_VERSION,
        }
    end

    if GATHEROVERVIEW_CONFIG.Profiles.DEFAULT == nil then
        GATHEROVERVIEW_CONFIG.Profiles.DEFAULT = {}
    end
    if GATHEROVERVIEW_CONFIG.Profiles[GATHEROVERVIEW_CURRENT_PROFILE] == nil then
        GATHEROVERVIEW_CURRENT_PROFILE = "DEFAULT"
    end

    addonTable.Config.CurrentProfile = GATHEROVERVIEW_CONFIG.Profiles[GATHEROVERVIEW_CURRENT_PROFILE]
    ImportDefaultsToProfile()
end

function addonTable.Config.ResetProfile()
    GATHEROVERVIEW_CONFIG = {
        Profiles = {
            DEFAULT = {},
        },
        CharacterSpecific = {},
        Version = addonTable.Constants.DB_VERSION,
    }
    addonTable.Config.InitializeData()
end

function addonTable.Config.GetProfileNames(exceptCurrent)
  local tbl = GetKeysArray(GATHEROVERVIEW_CONFIG.Profiles)
  if exceptCurrent then
    local currentProfileName = GATHEROVERVIEW_CURRENT_PROFILE
    for i = #tbl, 1, -1 do
      if tbl[i] == currentProfileName or tbl[i] == "DEFAULT" then
        table.remove(tbl, i)
      end
    end
  end
  return tbl
end

local installedNested = {}
function addonTable.Config.ChangeProfile(newProfileName, comparisonData)
  assert(tIndexOf(addonTable.Config.GetProfileNames(), newProfileName) ~= nil, "Invalid Profile")

  local changedOptions = {}
  local newProfile = GATHEROVERVIEW_CONFIG.Profiles[newProfileName]
  local oldProfile = comparisonData or addonTable.Config.CurrentProfile

  for name, value in pairs(oldProfile) do
    if value ~= newProfile[name] then
      table.insert(changedOptions, name)
    end
  end

  tAppendAll(changedOptions, installedNested)

  addonTable.Config.CurrentProfile = newProfile
  GATHEROVERVIEW_CURRENT_PROFILE = newProfileName

  ImportDefaultsToProfile()
end

function addonTable.Config.MakeProfile(newProfileName, clone)
  assert(tIndexOf(addonTable.Config.GetProfileNames(), newProfileName) == nil, "Existing Profile")
  if clone then
    GATHEROVERVIEW_CONFIG.Profiles[newProfileName] = CopyTable(addonTable.Config.CurrentProfile)
  else
    GATHEROVERVIEW_CONFIG.Profiles[newProfileName] = {}
  end
  addonTable.Config.ChangeProfile(newProfileName)
end

function addonTable.Config.DeleteProfile(profileName)
  assert(profileName ~= "DEFAULT" and profileName ~= GATHEROVERVIEW_CURRENT_PROFILE)

  GATHEROVERVIEW_CONFIG.Profiles[profileName] = nil
end

--------------------------------------------------
--- Getter/Setter for Profile value
--------------------------------------------------

local function IsValidOption(name)
    for _, option in pairs(addonTable.Config.Options) do
        if option == name then
            return true
        end
    end
    return false
end

local function RawSet(name, value)
  local tree = {string.split(".", name)}
  if addonTable.Config.CurrentProfile == nil then
    error("GATHEROVERVIEW_CONFIG not initialized")
  elseif not IsValidOption(tree[1]) then
    error("Invalid option '" .. name .. "'")
  elseif #tree == 1 then
    local oldValue = addonTable.Config.CurrentProfile[name]
    addonTable.Config.CurrentProfile[name] = value
    if value ~= oldValue then
      return true
    end
  else
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree - 1 do
      root = root[tree[i]]
      if type(root) ~= "table" then
        error("Invalid option '" .. name .. "', broke at [" .. i .. "]")
      end
    end
    local tail = tree[#tree]
    if root[tail] == nil then
      error("Invalid option '" .. name .. "', broke at [tail]")
    end
    local oldValue = root[tail]
    root[tail] = value
    if value ~= oldValue then
      return true
    end
  end
  return false
end

function addonTable.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if addonTable.Config.CurrentProfile == nil then
    return addonTable.Config.Defaults[name]
  elseif name:find("%.") == nil then
    return addonTable.Config.CurrentProfile[name]
  else
    local tree = {string.split(".", name)}
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree do
      root = root[tree[i]]
      if root == nil then
        break
      end
    end
    return root
  end
end

function addonTable.Config.Set(name, value)
  if RawSet(name, value) then

    if type(value) ~= "table" then
      addonTable.Utilities.Message("Setting changed: " .. name .. " -> " .. tostring(value))
    else
      addonTable.Utilities.Message("Setting changed: " .. name)
    end
  end
end