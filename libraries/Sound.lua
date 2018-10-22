--------------------
-- SOUND
--------------------


local Sound = {}


local path = "resources/audio/"


Sound.shotgun =
    { loading = love.audio.newSource ( path .. "gun-loading2.ogg", "static" )
    , loaded = love.audio.newSource ( path .. "gun-loaded2.ogg", "static" )
    , shoot = love.audio.newSource ( path .. "gun-shoot.ogg", "static" )
    }


Sound.load =
    function ( screenWidth, screenHeight )
        Sound.screenWidth = screenWidth
        Sound.screenHeight = screenHeight
    end


Sound.play =
    function ( source, position, volume, pitch )
        local sound = source:clone ()
        sound:setVolume ( volume )
        sound:setPitch ( pitch )
        sound:setPosition (
            ( position.x / Sound.screenWidth ) ^ 2 * 0.4 - 0.2
            , ( position.y / Sound.screenHeight ) ^ 2 * 0.4 - 0.2
            )
        love.audio.play ( sound )
    end


Sound.playRandomized =
    function ( source, position, volume )
        Sound.play (
            source
            , position
            , volume * ( 1 + 0.2 * ( love.math.random () - 0.5 ) )
            , source:getPitch () * ( 1 + 0.3 * ( love.math.random () - 0.5 ) )
            )
    end


return Sound
