--[[
    Horizon Suite - Echo - Sound
    The sound Echo plays for a whisper it hides from Blizzard's chat (EchoFilter's Alert).
    A whisper Blizzard still shows keeps Blizzard's own sound: Echo never touches Blizzard's
    chat frames to silence it. Three settings drive it: echoWhisperSound (which sound, or
    "off"), echoSoundInCombat and echoSoundBnet. The options page's preview button calls
    Echo.Sound.Whisper(false, true) to bypass the combat/Battle.net/throttle checks.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

Echo.Sound = Echo.Sound or {}
local Sound = Echo.Sound

-- Maps an echoWhisperSound choice to its SOUNDKIT key. A value with no entry, or whose
-- SOUNDKIT key is missing this build, falls back to TELL_MESSAGE.
local KIT_KEY = {
    blizzard = "TELL_MESSAGE",
    toast    = "UI_BNET_TOAST",
    ping     = "MAP_PING",
}

local THROTTLE_SECONDS = 1.5

local lastPlayAt

local function ResolveId(choice)
    local kit = _G.SOUNDKIT
    if not kit then return nil end
    local key = KIT_KEY[choice]
    local id = key and kit[key]
    if not id then id = kit.TELL_MESSAGE end
    return id
end

--- Play the sound configured for a whisper Echo just hid from Blizzard's chat.
-- @param isBnet boolean  whether the whisper arrived over Battle.net
-- @param preview boolean  bypass the combat, Battle.net and throttle checks (options preview)
function Sound.Whisper(isBnet, preview)
    local choice = Echo.Setting("echoWhisperSound")
    if choice == "off" then return end

    if not preview then
        if InCombatLockdown and InCombatLockdown() and Echo.Setting("echoSoundInCombat") == false then
            return
        end
        if isBnet and Echo.Setting("echoSoundBnet") == false then
            return
        end
        local now = GetTime and GetTime() or 0
        if lastPlayAt and (now - lastPlayAt) < THROTTLE_SECONDS then
            return
        end
        lastPlayAt = now
    end

    local id = ResolveId(choice)
    if id then
        pcall(PlaySound, id, "Master")
    end
end
