--------------------
-- NAVIGATION
--------------------
local Array = require "libraries/Array"
local Vector = require "libraries/Vector"
local Table = require "libraries/Table"


local Navigation = {}


Navigation.createMesh =
    function ( obstacles, mapWidth, mapHeight )
        local map =
            { position = Vector.null ()
            , width = mapWidth
            , height = mapHeight }
        local vertices = Navigation.toVertices ( map )

        for _, obstacle in pairs ( obstacles ) do
            local newVertices = Navigation.toVertices ( obstacle )
            for _, vertex in ipairs ( newVertices ) do
                table.insert ( vertices, vertex )
            end
        end


        return Navigation.filterTheDuplicates ( vertices )
        -- local mesh = {}
    end


Navigation.filterTheDuplicates =
    function ( vertices )
        local newVertices = {}
        for _, vertex in ipairs ( vertices ) do
            local shouldAdd = true
            for _, compareWith in ipairs ( newVertices ) do
                shouldAdd = Vector.equal ( vertex, compareWith ) or shouldAdd
            end
            if shouldAdd then
                table.insert ( newVertices, vertex )
            end
        end
        return newVertices
    end


Navigation.findBoundingBox =
    function ( vertices )
        local xmin, xmax = math.huge, 0
        local ymin, ymax = math.huge, 0
        for _, vertex in ipairs ( vertices ) do
            xmin = math.min ( xmin, vertex.x )
            xmax = math.max ( xmax, vertex.x )
            ymin = math.min ( ymin, vertex.y )
            ymax = math.max ( ymax, vertex.y )
        end
        return
            { { x = xmin, y = ymin }
            , { x = xmin, y = ymax }
            , { x = xmax, y = ymin }
            , { x = xmax, y = ymax } }
    end


Navigation.toVertices =
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


Navigation.drawVertices =
    function ( mesh )
        mesh = mesh or {}
        for _, vertex in ipairs ( mesh ) do
            love.graphics.circle ( "fill", vertex.x, vertex.y, 5 )
        end
    end


return Navigation
