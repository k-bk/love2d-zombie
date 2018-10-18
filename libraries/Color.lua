--------------------
-- Color
--------------------


local Color = {}


Color.getActual =
    function ()
        local r, g, b, a
        r, g, b, a = love.graphics.getColor ()
        return { r, g, b, a }
    end


return Color
