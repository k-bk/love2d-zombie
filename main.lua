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
            , mouseRight = false
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
        local inputVector = inputToVector ( model.input )
        Update.shoot ( model.player, model.input, model.entities )
        Update.controllable ( model.entities, inputVector )
        Update.moveAll ( model.entities, timeDelta )
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


Update.shoot =
    function ( entity, input, entities )
        if entity.position and input.mouseLeft then
            local dir
            dir = Vector.copy ( entity.position )
            dir = Vector.sub ( dir, input.mouse )
            dir = Vector.normalize ( dir )
            local bullet
            bullet = Entity.Create.bullet ( entity.position, dir )
            bullet.mask = { entity }

            table.insert ( entities, bullet )
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
                    Vector.scale ( entity.direction, entity.speed * timeDelta )
                print ( Table.toString (force) )
                Entity.applyForce ( entity, force )
            end
        end
    end


Update.moveAll =
    function ( entities )
        local shouldIterateAgain = true
        while shouldIterateAgain do
            for _, entity in ipairs ( entities ) do
                local collisions = Entity.moveX ( entity )
            end
        end
    end


Update.processCollisions =
    function ( entity, collisions )
        for _, colliding in pairs ( collisions ) do
        end
    end


inputToVector =
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
            model.input.mouseLeft = true
        elseif button == 2 then
            model.inpu.mouseRight = true
        end
    end


love.mousereleased =
    function ( x, y, button, isTouch )
        model.input.mouseX = x
        model.input.mouseY = y
        if button == 1 then
            model.input.mouseLeft = false
        elseif button == 2 then
            model.inpu.mouseRight = false
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
            if input.mouseLeft then
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


--------------------
-- ENTITY
--------------------


Entity = {}


Entity.applyForce =
    function ( entity, force )
        if entity.force
            and entity.remainder
        then
            entity.force.x, remainder.x = math.modf ( remainder.x + force.x )
            entity.force.y, remainder.y = math.modf ( remainder.y + force.y )
        end
    end


Entity.moveX =
    function ( entity, entities )
        local position = entity.position
        local remainder = entity.remainder
        local force = entity.force

        if position and remainder and force then
            local sign = Utils.sign (force.x)
            while force.x ~= 0 do
                position.x = position.x + sign
                force.x = force.x - sign
                local collisions = Entity.collisionsWith ( entity, entities )
                if not Table.empty ( collisions ) then
                    position.x = position.x - sign
                    return collisions
                end
            end
        end
    end


Entity.moveY =
    function ( entity, entities )
        local position = entity.position
        local remainder = entity.remainder
        local force = entity.force

        if position and remainder and force then
            local sign = Utils.sign (force.y)
            while force.y ~= 0 do
                position.y = position.y + sign
                force.y = force.x - sign
                local collisions = Entity.collisionsWith ( entity, entities )
                if not Table.empty ( collisions ) then
                    position.y = position.y - sign
                    return collisions
                end
            end
        end
    end


Entity.collisionsWith =
    function ( entity, entities )
        local canCollide =
            function ( e )
                return e.position
                    and e.width
                    and e.height
            end

        local collisions = {}

        if canCollide ( entity ) then
            for _, other in ipairs ( entities ) do
                if other.mask == nil
                    or not Table.member ( other.mask, entity )
                then
                    if other ~= entity
                        and canCollide ( other )
                        and entity.x + entity.width > other.x
                        and entity.x < other.x + other.width
                        and entity.y + entity.height > other.y
                        and entity.y < other.y + other.height
                    then
                        table.insert ( collisions, other )
                    end
                end
            end
        end

        return collisions
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
-- TABLE
--------------------


Table = {}


Table.toString =
    function ( table )
        local result = "{ "
        for k, v in pairs ( table ) do
            result = result .. k .. " = " .. tostring (v) .. ", "
        end
        return result .. "}"
    end


Table.empty =
    function ( table )
        return next ( table ) == nil
    end


Table.member =
    function ( table, value )
        for _, v in pairs ( table ) do
            if v == value then
                return true
            end
        end
        return false
    end


--------------------
-- VECTOR
--------------------


Vector = {}


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
    function ( v, a )
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


--------------------
-- CREATE
--------------------


Entity.Create = {}


Entity.Create.player =
    function ( position )
        return
        { position = Vector.scale ( position, TILE )
        , remainder = Vector.null ()
        , direction = Vector.null ()
        , force = Vector.null ()
        , mass = 1.0
        , width = TILE
        , height = 2 * TILE
        , speed = 0.0 + TILE * 5
        , controllable = true
        , health = 10
        , immune = false
        }
    end


Entity.Create.obstacle =
    function ( position )
        return
        { position = Vector.scale ( position, TILE )
        , width = TILE
        , height = TILE
        }
    end


Entity.Create.bullet =
    function ( position, direction, speed, damage )
        return
        { position = { x = position.x, y = position.y }
        , remainder = Vector.null ()
        , direction = Vector.null ()
        , force = Vector.null
        , mass = 0.5
        , width = TILE / 4
        , height = TILE / 4
        , speed = (speed or 10) * TILE
        , damage = (damage or 1)
        }
    end
