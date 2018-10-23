--------------------
-- NAVIGATION
--------------------
local Array = require "libraries/Array"
local Vector = require "libraries/Vector"
local Table = require "libraries/Table"
local AABB = require "libraries/AABB"


local Navigation = {}


Navigation.findAreas =
    function ( obstacles, mapWidth, mapHeight )
        local vertices =
            Navigation.findVertices ( obstacles, mapWidth, mapHeight )

        local blocked = Array.map ( obstacles, AABB.fromEntity )
        local areas = {}

        for _, vertex in ipairs ( vertices ) do
            local boundary = AABB.addVertex ( {}, vertex )
            for _, newVertex in ipairs ( vertices ) do
                local newBoundary = AABB.addVertex ( boundary, newVertex )
                if not AABB.anyColliding ( newBoundary, blocked )
                    and not AABB.anyColliding ( newBoundary, areas )
                then
                    boundary = newBoundary
                end
            end
            table.insert ( areas, boundary )
        end

        return Array.map ( areas, AABB.toEntity )
    end


Navigation.findVertices =
    function ( obstacles, mapWidth, mapHeight )
        local map =
            { position = Vector.null ()
            , width = mapWidth
            , height = mapHeight }

        local vertices = {}
        vertices = Array.union ( vertices, Navigation.entityToVertices ( map ) )
        for _, obstacle in pairs ( obstacles ) do
            local newVertices = Navigation.entityToVertices ( obstacle )
            vertices = Array.union ( vertices, newVertices )
        end
        return vertices
    end


Navigation.drawVertices =
    function ( mesh )
        mesh = mesh or {}
        for _, vertex in ipairs ( mesh ) do
            love.graphics.circle ( "fill", vertex.x, vertex.y, 5 )
        end
        love.graphics.print ( #mesh, 10, 10 )
    end


Navigation.entityToVertices =
    function ( entity )
        local position = entity.position
        local width = entity.width
        local height = entity.height
        if position and width and height then
            return
                { position
                , { x = position.x + width, y = position.y }
                , { x = position.x, y = position.y + height }
                , { x = position.x + width, y = position.y + height }
                }
        end
        return {}
    end


return Navigation
