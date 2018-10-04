Vector = require "src/Vector"
Table = require "src/Table"


--------------------
-- LOAD
--------------------


TILE =
    64


love.load =
    function ()
        local player =
            Entity.Create.player { x = 1, y = 1 }

        local entities =
            { player
            , Entity.Create.obstacle { x = 5, y = 5 }
            , Entity.Create.obstacle { x = 5, y = 6 }
            , Entity.Create.obstacle { x = 6, y = 7 }
            , Entity.Create.obstacle { x = 4, y = 7 }
            , Entity.Create.obstacle { x = 4, y = 8 }
            , Entity.Create.obstacle { x = 6, y = 8 }
            }

        local input =
            { up = false
            , down = false
            , left = false
            , right = false
            , mouseLeft = false
            , mouseLeftPressed = false
            , mouseRight = false
            , mouseRightPressed = false
            , mouse = Vector.null ()
            }

        model =
            { entities = entities
            , player = player
            , screenWidth = 800
            , screenHeight = 600
            , canvas = love.graphics.newCanvas ( 800, 600 )
            , input = input
            }
    end


--------------------
-- UPDATE
--------------------


love.update =
    function ( timeDelta )
        local inputVector = Input.toVector ( model.input )
        Update.shooting ( model.entities, model.input )
        Update.controllable ( model.entities, inputVector )
        Update.forces ( model.entities, timeDelta )
        Update.moveAll ( model.entities, timeDelta )
        Input.resetPressed ( model.input )
    end


Update = {}


Update.controllable =
    function ( entities, inputVector )
        for _, entity in ipairs ( entities ) do
            if entity.controllable
                and entity.direction
            then
                entity.direction = Vector.copy ( inputVector )
            end
        end
    end


Update.shooting =
    function ( entities, input )
        if input.mouseLeftPressed then
            local bullets = {}
            for _, entity in ipairs ( entities ) do
                if entity.position
                    and entity.shooting
                then
                    local dir
                    dir = Vector.copy ( input.mouse )
                    dir = Vector.sub ( dir, entity.position )
                    dir = Vector.normalize ( dir )
                    local bullet
                    bullet = Entity.Create.bullet ( entity.position, dir )
                    bullet.mask = { entity }
                    table.insert ( bullets, bullet )
                end
            end
            for _, bullet in ipairs ( bullets ) do
                table.insert ( entities, bullet )
            end
        end
    end


Update.forces =
    function ( entities, timeDelta )
        for _, entity in ipairs ( entities ) do
            if entity.position
                and entity.speed
                and entity.direction
                and entity.force
            then
                local force =
                    Vector.scale ( entity.speed * timeDelta, entity.direction )
                Entity.applyForce ( entity, force )
            end
        end
    end


Update.moveAll =
    function ( entities )
        local shouldIterateAgain = true
        for _, entity in ipairs ( entities ) do
            Entity.move ( "x", entity, entities )
            Entity.move ( "y", entity, entities )
        end
    end


Update.processCollisions =
    function ( entity, collisions )
        for _, colliding in pairs ( collisions ) do
        end
    end


--------------------
-- INPUT
--------------------


Input = {}


Input.resetPressed =
    function ( input )
        input.mouseLeftPressed = false
        input.mouseRightPressed = false
    end


Input.toVector =
    function ( input )
        local vector = Vector.null ()

        if input.up then
            vector.y = vector.y - 1
        end
        if input.down then
            vector.y = vector.y + 1
        end
        if input.left then
            vector.x = vector.x - 1
        end
        if input.right then
            vector.x = vector.x + 1
        end

        return Vector.normalize ( vector )
    end


--------------------
-- SUBSCRIPTIONS
--------------------


love.keypressed =
    function ( _, scanCode, isRepeat )
        if scanCode == "w" or scanCode == "up" then
            model.input.up = true
        elseif scanCode == "s" or scanCode == "down" then
            model.input.down = true
        elseif scanCode == "a" or scanCode == "left" then
            model.input.left = true
        elseif scanCode == "d" or scanCode == "right" then
            model.input.right = true
        end
    end


love.keyreleased =
    function ( _, scanCode )
        if scanCode == "w" or scanCode == "up" then
            model.input.up = false
        elseif scanCode == "s" or scanCode == "down" then
            model.input.down = false
        elseif scanCode == "a" or scanCode == "left" then
            model.input.left = false
        elseif scanCode == "d" or scanCode == "right" then
            model.input.right = false
        end
    end


love.mousepressed =
    function ( x, y, button, isTouch )
        model.input.mouse.x = x
        model.input.mouse.y = y
        if button == 1 then
            model.input.mouseLeftPressed = true
            model.input.mouseLeft = true
        elseif button == 2 then
            model.input.mouseRightPressed = true
            model.input.mouseRight = true
        end
    end


love.mousereleased =
    function ( x, y, button, isTouch )
        model.input.mouseX = x
        model.input.mouseY = y
        if button == 1 then
            model.input.mouseLeftPressed = false
            model.input.mouseLeft = false
        elseif button == 2 then
            model.input.mouseRightPressed = false
            model.input.mouseRight = false
        end
    end


love.mousemoved =
    function ( x, y, dx, dy, isTouch )
        model.input.mouse.x = x
        model.input.mouse.y = y
    end


--------------------
-- DRAW
--------------------


love.draw =
    function ()
        love.graphics.setCanvas ( model.canvas )

            love.graphics.clear ()
            Array.map ( model.entities, Draw.entity )
            Draw.cursor ( model.input )

        love.graphics.setCanvas ()

        love.graphics.draw ( model.canvas )
    end


Draw = {}


Draw.cursor =
    function ( input )
        local oldColor = Utils.getColor ()
            if input.mouseLeftPressed then
                love.graphics.setColor ( 1, 0, 0 )
            else
                love.graphics.setColor ( 1, 1, 1 )
            end
            love.graphics.circle (
                "line"
                , input.mouse.x
                , input.mouse.y
                , 10
                , 20
                )
        love.graphics.setColor ( oldColor )
    end


Draw.entity =
    function ( entity )
        if entity.position
            and entity.width
            and entity.height
        then
            love.graphics.rectangle (
                "line"
                , entity.position.x
                , entity.position.y
                , entity.width
                , entity.height
                )
        end
    end


--------------------
-- ENTITY
--------------------


Entity = {}


Entity.applyForce =
    function ( entity, appliedForce )
        local force = entity.force
        local remainder = entity.remainder
        if force and remainder then
            force.x, remainder.x = math.modf ( remainder.x + appliedForce.x )
            force.y, remainder.y = math.modf ( remainder.y + appliedForce.y )
        end
    end


Entity.move =
    function ( axis, entity, entities )
        local position = entity.position
        local force = entity.force
        if position and force then
            local sign = Utils.sign ( force [axis] )
            while force [axis] ~= 0 do
                position [axis] = position [axis] + sign
                force [axis] = force [axis] - sign
                local collisions = Entity.collisionsWith ( entity, entities )
                if not Table.empty ( collisions ) then
                    position [axis] = position [axis] - sign
                    return collisions
                end
            end
        end
    end


Entity.collisionsWith =
    function ( entity, entities )
        local collisions = {}
        for _, other in ipairs ( entities ) do
            if Entity.areColliding ( entity, other ) then
                table.insert ( collisions, other )
            end
        end

        return collisions
    end


Entity.areColliding =
    function ( A, B )
        if A ~= B
            and A.position and A.width and A.height
            and B.position and B.width and B.height
            and ( A.mask == nil or not Table.member ( A.mask, B ) )
            and ( B.mask == nil or not Table.member ( B.mask, A ) )
        then
            return A.position.x + A.width > B.position.x
                and A.position.x < B.position.x + B.width
                and A.position.y + A.height > B.position.y
                and A.position.y < B.position.y + B.height
        end
    end


Entity.damage =
    function ( entity, strength )
        if entity.health
            and not entity.immune
        then
            entity.health = entity.health - strength
        end
    end


Entity.divideForce =
    function ( moving, standing )
        if standing.mass
            and moving.mass
            and moving.forceX
        then
            local totalMass = moving.mass + standing.mass
            local fMoving = moving.forceX * moving.mass / totalMass
            local fStanding = moving.forceX * standing.mass / totalMass
            return fMoving, fStanding
        else
            return 0, 0
        end
    end


Entity.onCollision =
    function ( entityA, entityB )

        local A = entityA
        local B = entityB

        Entity.damage ( A, B.strength )
        Entity.damage ( B, A.strength )
    end


--------------------
-- UTILS
--------------------


Utils = {}


Utils.clamp =
    function ( value, min, max )
        math.min ( max, math.max ( min, value ) )
    end


Utils.sign =
    function ( value )
        if value > 0 then
            return 1
        elseif value < 0 then
            return -1
        else
            return 0
        end
    end


Utils.getColor =
    function ()
        local r, g, b, a
        r, g, b, a = love.graphics.getColor ()
        return { r, g, b, a }
    end


--------------------
-- CREATE
--------------------


Entity.Create = {}


Entity.Create.player =
    function ( position )
        return
        { position = Vector.scale ( TILE, position )
        , direction = Vector.null ()
        , force = Vector.null ()
        , remainder = Vector.null ()
        , mass = 1.0
        , width = TILE
        , height = 2 * TILE
        , speed = 0.0 + TILE * 5
        , shooting = true
        , controllable = true
        , health = 10
        , immune = false
        }
    end


Entity.Create.obstacle =
    function ( position )
        return
        { position = Vector.scale ( TILE, position )
        , width = TILE
        , height = TILE
        }
    end


Entity.Create.bullet =
    function ( position, direction, speed, damage )
        return
        { position = Vector.copy ( position )
        , direction = Vector.copy ( direction )
        , force = Vector.null ()
        , remainder = Vector.null ()
        , mass = 0.5
        , width = TILE / 4
        , height = TILE / 4
        , speed = (speed or 10) * TILE
        , damage = (damage or 1)
        }
    end


--------------------
-- ARRAY
--------------------


Array = {}


Array.map =
    function ( array, fun )
        local newArray = {}
        for i, v in ipairs ( array ) do
            newArray [i] = fun ( v )
        end
        return newArray
    end


Array.filter =
    function ( array, fun )
        local newArray = {}
        for i, v in ipairs ( array ) do
            if fun ( v ) then
                table.insert ( newArray, v )
            end
        end
        return newArray
    end
