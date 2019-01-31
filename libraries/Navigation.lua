--------------------
-- NAVIGATION
--------------------
local Array = require "libraries/Array"
local Vector = require "libraries/Vec2"
local Table = require "libraries/Table"
local AABB = require "libraries/AABB"


local Navigation = {}


Navigation.findAreas =
    function ( obstacles, mapWidth, mapHeight )
        local isArea =
            function ( boundary )
                local diff = Vector.sub ( boundary.max, boundary.min )
                return diff.x > Vector.epsilon and diff.y > Vector.epsilon
            end

        local vertices =
            Navigation.findVertices ( obstacles, mapWidth, mapHeight )

        local blocked = Array.map ( obstacles, AABB.fromEntity )
        local areas = {}

        Table.print ( vertices, "\n" )

        local vertex = vertices
        while vertex ~= nil do
            local boundary = AABB.addVertex ( {}, vertex )
            for _, newVertex in ipairs ( vertices ) do
                local newBoundary = AABB.addVertex ( boundary, newVertex )
                if not AABB.anyColliding ( newBoundary, blocked )
                    and not AABB.anyColliding ( newBoundary, areas )
                then
                    boundary = newBoundary
                end
            end

            if isArea ( boundary ) then
                table.insert ( areas, boundary )
                local newVertices = AABB.toVertices ( boundary )
                for _, v in ipairs ( newVertices ) do
                    Navigation.addIfUnique ( vertices, v )
                end
            end

            vertex = next ( vertex )
        end

        Table.print ( vertices, "\n" )

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
            for _, v in pairs ( newVertices ) do
                vertices = Navigation.addIfUnique ( vertices, v )
            end
        end
        return vertices
    end


Navigation.addIfUnique =
    function ( array, this )
        for _, other in ipairs ( array ) do
            if Vector.equal ( this, other ) then
                return array
            end
        end
        table.insert ( array, this )
        return array
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
