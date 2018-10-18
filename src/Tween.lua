--------------------
-- TWEEN
--------------------
local Tween = {}


Tween.linear =
-- No easing, no acceleration
    function ( alarm )
        return Alarm.progress ( alarm )
    end


Tween.quadratic =
-- Doing a quadratic function
    function ( alarm )
        local progress = Alarm.progress ( alarm )
        return 4 * progress * ( progress - 1 )
    end


return Tween
