--------------------
-- 2D VECTOR
--------------------


local Vec2 = {}
local mt = { __index = Vec2 }


Vec2.epsilon = 0.001


function Vec2.new ( x, y )
    local v = { x = x, y = y }
    setmetatable( v, mt )
    return v
end


function Vec2.copy ( v )
    return Vec2.new( v.x, v.y )
end


function Vec2.length ( v )
    return math.sqrt( v.x * v.x + v.y * v.y )
end


function Vec2.normalize ( v )
    local length = Vec2.length ( v )
    if length < Vec2.epsilon then
        return Vec2.null ()
    else
        return Vec2.new( v.x / length, v.y / length )
    end
end


function Vec2.isNull ( v )
    return Vec2.length( v ) < Vec2.epsilon
end


function Vec2.null ()
    return Vec2.new( 0.0, 0.0 )
end


function Vec2.add ( u, v )
    return Vec2.new( u.x + v.x, u.y + v.y )
end


function Vec2.sub ( u, v )
    return Vec2.new( u.x - v.x, u.y - v.y )
end


function Vec2.scale ( v, a )
    return Vec2.new( a * v.x, a * v.y )
end


function Vec2.dot ( u, v )
    return u.x * v.x + u.y * v.y
end


function Vec2.equal ( u, v )
    return Vec2.isNull( Vec2.sub( u, v ) )
end


function Vec2.min ( ... )
    local min = { x = math.huge, y = math.huge }
    for _, v in pairs( { ... } ) do
        min.x = math.min( min.x, v.x )
        min.y = math.min( min.y, v.y )
    end
    return min
end


function Vec2.max ( ... )
    local max = { x = -math.huge, y = -math.huge }
    for _, v in pairs( { ... } ) do
        max.x = math.max( max.x, v.x )
        max.y = math.max( max.y, v.y )
    end
    return max
end


return Vec2
