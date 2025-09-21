-- SOUND INITIALIZATION
local sounds = {
    -- Chat-related sounds
    keyAudio = love.audio.newSource("assets/audio/sfx/chat/keyboard.mp3", "static"),
    spacekeyAudio = love.audio.newSource("assets/audio/sfx/chat/space_keyboard.mp3", "static"),
    notif1 = love.audio.newSource("assets/audio/sfx/chat/notif-1.wav", "static"),
    ringtone = love.audio.newSource("assets/audio/sfx/chat/ringtone.mp3", "stream"),

    -- Background and ambient sounds
    forest = love.audio.newSource("assets/audio/tracks/forest.mp3", "stream"),
    oldsong = love.audio.newSource("assets/audio/tracks/Elton Britt - Ridin' With My Gal [1945].mp3", "stream"),

    -- Voice and effects
    scream1 = love.audio.newSource("assets/audio/sfx/voice/scream-1.mp3", "static"),
    axeslash = love.audio.newSource("assets/audio/sfx/tools/axe-slash.mp3", "static"),
    footsteps = love.audio.newSource("assets/audio/sfx/footsteps/wooden.mp3", "stream"),
    grassfootsteps = love.audio.newSource("assets/audio/sfx/footsteps/grass.mp3", "stream"),
    knock = love.audio.newSource("assets/audio/sfx/misc/knock.mp3", "stream"),
    heartbeat = love.audio.newSource("assets/audio/sfx/misc/heartbeat.mp3", "stream"),
    door_open = love.audio.newSource("assets/audio/sfx/misc/door-open.mp3", "stream"),
    door_close = love.audio.newSource("assets/audio/sfx/misc/door-close.mp3", "stream")

}

-- SOUND SETTINGS
-- Chat-related settings
local mV = settings.audio.MASTER
sounds.keyAudio:setVolume(mV *  0.1) -- Key press sound volume
sounds.spacekeyAudio:setVolume(mV *0.4) -- Space key sound volume
sounds.notif1:setVolume(mV *0.1) -- Notification sound volume
sounds.ringtone:setVolume(mV *0.4) -- Ringtone volume
sounds.ringtone:setLooping(true) -- Loop the ringtone

-- Background and ambient settings
sounds.forest:setVolume(mV) -- Background forest sound volume
sounds.forest:setLooping(true) -- Loop the forest sound

-- Voice and effect settings
sounds.scream1:setVolume(mV *0.4) -- Scream sound volume
sounds.axeslash:setRolloff(0)
sounds.axeslash:setRelative(true)
sounds.axeslash:setVolume(mV) -- Axe slash sound volume
sounds.footsteps:setVolume(mV) -- Footsteps sound volume
sounds.footsteps:setLooping(true) -- Loop footsteps sound
sounds.grassfootsteps:setLooping(true) -- Loop footsteps sound
sounds.heartbeat:setVolume(mV *.5)
sounds.door_open:setVolume(mV * .5)
sounds.door_close:setVolume(mV * .5)
love.audio.setPosition(0, 0, 0) -- Listener at the origin
love.audio.setOrientation(0, 0, -1, 0, 1, 0) -- Facing forward (negative z-axis)



function globalSoundStop()
    for i, v in pairs(sounds) do
        v:stop()
    end
    return
end
return sounds
