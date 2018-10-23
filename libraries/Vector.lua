--------------------
-- VECTOR
--------------------


local Vector = {}


Vector.epsilon =
    0.01


Vector.new =
    function ( x, y )
        return { x = x, y = y }
    end


Vector.copy =
    function ( v )
        return { x = v.x, y = v.y }
    end


Vector.scale =
    function ( a, v )
        return { x = a * v.x, y = a * v.y }
    end


Vector.length =
    function ( v )
        return math.sqrt ( v.x * v.x + v.y * v.y )
    end


Vector.normalize =
    function ( v )
        local length = Vector.length ( v )
        if length < Vector.epsilon then
            return Vector.null ()
        else
            return { x = v.x / length, y = v.y / length }
        end
    end


Vector.isNull =
    function ( v )
        return Vector.length ( v ) < Vector.epsilon
    end


Vector.null =
    function ()
        return { x = 0.0, y = 0.0 }
    end


Vector.add =
    function ( v, u )
        return { x = v.x + u.x, y = v.y + u.y }
    end


Vector.sub =
    function ( v, u )
        return { x = v.x - u.x, y = v.y - u.y }
    end


Vector.equal =
    function ( v, u )
        return Vector.isNull ( Vector.sub ( v, u ) )
    end


Vector.min =
    function ( ... )
        local min = { x = math.huge, y = math.huge }
        for _, v in pairs ( { ... } ) do
            min.x = math.min ( min.x, v.x )
            min.y = math.min ( min.y, v.y )
        end
        return min
    end


Vector.max =
    function ( ... )
        local max = { x = - math.huge, y = - math.huge }
        for _, v in pairs ( { ... } ) do
            max.x = math.max ( max.x, v.x )
            max.y = math.max ( max.y, v.y )
        end
        return max
    end


return Vector
