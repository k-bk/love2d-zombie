--------------------
-- Axis Aligned Bounding Box
--------------------
local Array = require "libraries/Array"
local Vector = require "libraries/Vec2"


local AABB = {}


AABB.anyColliding =
    function ( this, rest )
        for _, other in ipairs ( rest ) do
            if AABB.areColliding ( this, other ) then
                return true
            end
        end
        return false
    end


AABB.areColliding =
    function ( A, B )
        if A.max.x > B.min.x
            and A.min.x < B.max.x
            and A.max.y > B.min.y
            and A.min.x < B.max.y
        then
            return true
        end
        return false
    end


AABB.addVertex =
    function ( box, vertex )
        return
            { min = Vector.min ( vertex, box.min )
            , max = Vector.max ( vertex, box.max )
            }
    end


AABB.toVertices =
    function ( box )
        return
            { Vector.copy ( box.min )
            , { x = box.min.x, y = box.max.y }
            , { x = box.max.x, y = box.min.y }
            , Vector.copy ( box.max )
            }
    end


AABB.fromEntity =
    function ( entity )
        return
            { min = Vector.copy ( entity.position )
            , max = { x = entity.position.x + entity.width
                    , y = entity.position.y + entity.height
                    }
            }
    end


AABB.toEntity =
    function ( box )
        local diff = Vector.sub ( box.max, box.min )
        return
            { position = Vector.copy ( box.min )
            , drawPosition = Vector.copy ( box.min )
            , width = diff.x
            , height = diff.y
            }
    end


return AABB
