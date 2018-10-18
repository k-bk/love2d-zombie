--------------------
-- TWEEN
--------------------


local Tween = {}

Tween.linear =
    function ( time )
        return time
    end

Tween.sinus =
    function ( time )
        return sin ( math.pi * time )
    end


return Tween
