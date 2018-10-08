--------------------
-- UTILS
--------------------


local Utils = {}


Utils.clamp =
    function ( value, min, max )
        math.min ( max, math.max ( min, value ) )
    end


Utils.sign =
    function ( value )
        if value > 0 then
            return 1
        elseif value < 0 then
            return -1
        else
            return 0
        end
    end


Utils.getColor =
    function ()
        local r, g, b, a
        r, g, b, a = love.graphics.getColor ()
        return { r, g, b, a }
    end


return Utils
