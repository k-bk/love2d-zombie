--------------------
-- Math
--------------------


local Math = {}


Math.clamp =
    function ( value, min, max )
        math.min ( max, math.max ( min, value ) )
    end


Math.sign =
    function ( value )
        if value > 0 then
            return 1
        elseif value < 0 then
            return -1
        else
            return 0
        end
    end


return Math
