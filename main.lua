Vector = require "src/Vector"
Table = require "src/Table"
Input = require "src/Input"
Queue = require "src/Queue"
Array = require "src/Array"
Math = require "src/Math"
Color = require "src/Color"


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
            , Entity.Create.box ( { x = 3, y = 3 }, 1 )
            , Entity.Create.box ( { x = 5, y = 3 }, 1 )
            , Entity.Create.box ( { x = 4, y = 3 }, 1 )
            , Entity.Create.enemy { x = 7, y = 7 }
            }

        model =
            { entities = entities
            , player = player
            , screenWidth = 800
            , screenHeight = 600
            , canvas = love.graphics.newCanvas ( 800, 600 )
            , input = Input.load ()
            , alarms = Alarm.load ()
            }
    end


--------------------
-- UPDATE
--------------------


love.update =
    function ( timeDelta )
        local inputVector = Input.toVector ( model.input )
        Update.shooting ( model.entities, model.input, model.alarms, timeDelta )
        Update.controllable ( model.entities, inputVector )
        Update.applyForces ( model.entities, timeDelta )
        Update.moveAll ( model.entities, timeDelta )
        model.alarms = Update.alarms ( model.alarms, timeDelta )
        model.entities = Update.immune ( model.entities, timeDelta )
        model.entities = Update.removeDead ( model.entities )
        Input.resetPressed ( model.input )
    end


Update = {}


Update.alarms =
    function ( alarms, timeDelta )
        local newAlarms = {}

        for k, alarm in pairs ( alarms ) do
            alarm = Alarm.update ( alarm, timeDelta )
            if not (alarm == Alarm.done) then
                table.insert ( newAlarms, alarm )
            end
        end
        return newAlarms
    end


Update.controllable =
    function ( entities, inputVector )
        for _, entity in ipairs ( entities ) do
            local control = entity.controllable
            if entity.direction then
                if control == Control.input then
                    entity.direction = Vector.copy ( inputVector )
                elseif control == Control.AI then
                    local dir
                    dir = entity.position
                    dir = Vector.sub ( model.player.position, dir )
                    dir = Vector.normalize ( dir )
                    entity.direction = dir
                end
            end
        end
    end


Update.shooting =
    function ( entities, input, alarms, timeDelta )
        local loadWeapon =
            function ( entity )
                return function ()
                    entity.shooting.loaded = true
                end
            end

        local shoot =
            function ( entity )
                local shooting = entity.shooting
                local position = Vector.add ( entity.position, shooting.origin )
                local dir = Vector.sub ( input.mouse, position )
                dir = Vector.normalize ( dir )
                local bullet = Entity.Create.bullet ( position, dir )
                bullet.mask = { entity }

                shooting.loaded = false
                Alarm.set ( alarms, shooting.reloadTime, loadWeapon ( entity ) )
                return bullet
            end

        if input.mouseLeftPressed then
            local newBullets = {}
            for _, entity in ipairs ( entities ) do
                if entity.position
                    and entity.shooting
                    and entity.shooting.loaded
                then
                    local bullet = shoot ( entity )
                    table.insert ( newBullets, bullet )
                end
            end
            for _, bullet in ipairs ( newBullets ) do
                table.insert ( entities, bullet )
            end
        end
    end


Update.applyForces =
    function ( entities, timeDelta )
        for _, entity in ipairs ( entities ) do
            if entity.position
                and entity.speed
                and entity.direction
                and entity.force
            then
                local force =
                    Vector.scale ( entity.speed * timeDelta, entity.direction )
                Entity.forceBase = force
                Entity.applyForce ( entity, force )
            end
        end
    end


Update.moveAll =
    function ( entities )
        local movingQueue = Queue.new ()
        for _, entity in ipairs ( entities ) do
            if entity.position
                and entity.force
            then
                Queue.push ( movingQueue, entity )
            end
        end

        while not Queue.empty ( movingQueue ) do
            local entity = Queue.pop ( movingQueue )

            local collisionsX = Entity.move ( "x", entity, entities )
            if not Table.empty ( collisionsX ) then
                for _, colliding in ipairs ( collisionsX ) do
                    Queue.push ( movingQueue, colliding )
                    Update.processCollision ( "x", entity, colliding )
                end
                Queue.push ( movingQueue, entity )
            end

            local collisionsY = Entity.move ( "y", entity, entities )
            if not Table.empty ( collisionsY ) then
                for _, colliding in ipairs ( collisionsY ) do
                    Queue.push ( movingQueue, colliding )
                    Update.processCollision ( "y", entity, colliding )
                end
                Queue.push ( movingQueue, entity )
            end
        end
    end


Update.immune =
    function ( entities, timeDelta )
        local updateImmunity =
            function ( entity )
                if entity.immune and entity.immune > 0 then
                    entity.immune = entity.immune - timeDelta
                else
                    entity.immune = nil
                end
                return entity
            end
        return Array.map ( entities, updateImmunity )
    end


Update.removeDead =
    function ( entities )
        local isAlive =
            function ( entity )
                return not entity.dead
            end

        return Array.filter ( entities, isAlive )
    end


Update.processCollision =
    function ( axis, A, B )
        local newForceA, newForceB = Entity.newForces ( A, B )
        local partA = Vector.null ()
        partA [axis] = newForceA [axis]
        local partB = Vector.null ()
        partB [axis] = newForceB [axis]
        Entity.applyForce ( A, partA )
        Entity.applyForce ( B, partB )
        Entity.damage ( A, B.strength )
        Entity.damage ( B, A.strength )
    end


--------------------
-- SUBSCRIPTIONS
--------------------


love.keypressed =
    function ( _, scanCode, isRepeat )
        Input.keyPressed ( model.input, scanCode )
    end


love.keyreleased =
    function ( _, scanCode )
        Input.keyReleased ( model.input, scanCode )
    end


love.mousepressed =
    function ( x, y, button, isTouch )
        Input.mousePressed ( model.input, x, y, button )
    end


love.mousereleased =
    function ( x, y, button, isTouch )
        Input.mouseReleased ( model.input, x, y, button )
    end


love.mousemoved =
    function ( x, y, dx, dy, isTouch )
        Input.mouseMoved ( model.input, x, y )
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
        local oldColor = Color.getActual ()
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
        local collisions = {}
        if position and force then
            local broadPhase =
                Entity.collisionBroadPhase ( axis, entity, entities)
            local sign = Math.sign ( force [axis] )
            while force [axis] ~= 0 do
                position [axis] = position [axis] + sign
                force [axis] = force [axis] - sign
                collisions = Entity.collisionsWith ( entity, broadPhase )
                if not Table.empty ( collisions ) then
                    position [axis] = position [axis] - sign
                    return collisions
                end
            end
        end
        return collisions
    end


Entity.collisionBroadPhase =
    function ( axis, entity, entities )
        local position = entity.position
        local force = entity.force
        if position and force
            and entity.width and entity.height
        then
            local movementBoundary = Entity.Create.collider (
                Vector.add ( position, force )
                , ( entity.width or 0 ) + math.abs ( entity.force.x )
                , ( entity.height or 0 ) + math.abs ( entity.force.y )
                )
            return Entity.collisionsWith ( movementBoundary, entities )
        else
            return {}
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
            and not ( A.mask and Table.member ( A.mask, B ) )
            and not ( B.mask and Table.member ( B.mask, A ) )
        then
            return A.position.x + A.width > B.position.x
                and A.position.x < B.position.x + B.width
                and A.position.y + A.height > B.position.y
                and A.position.y < B.position.y + B.height
        end
    end


Entity.damage =
    function ( entity, strength )
        if entity.health and not entity.immune then
            if strength then
                entity.health = entity.health - strength
                entity.immune = 0.3
            end
            if entity.health <= 0 then
                entity.dead = true
            end
        end
    end


Entity.newForces =
    function ( A, B )
        local fA = Vector.null ()
        local fB = Vector.null ()
        if A.mass
            and B.mass
            and A.force
            and B.force
        then
            local totalMass = A.mass + B.mass
            fA = Vector.add (
                Vector.scale ( A.mass - B.mass, A.force )
                , Vector.scale ( 2 * B.mass, B.force )
                )
            fA = Vector.scale ( 1 / totalMass, fA )
            fB = Vector.add (
                Vector.scale ( B.mass - A.mass, B.force )
                , Vector.scale ( 2 * A.mass, A.force )
                )
            fB = Vector.scale ( 1 / totalMass, fB )
        end
        return fA, fB
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
        , shooting =
            { origin = { x = TILE / 2, y = TILE }
            , loaded = true
            , reloadTime = 0.3
            }
        , controllable = Control.input
        , health = 10
        }
    end


Entity.Create.collider =
    function ( position, width, height )
        return
        { position = Vector.copy ( position )
        , width = width
        , height = height
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


Entity.Create.box =
    function ( position, mass )
        return
        { position = Vector.scale ( TILE, position )
        , direction = Vector.null ()
        , force = Vector.null ()
        , remainder = Vector.null ()
        , mass = mass
        , width = TILE
        , height = TILE
        }
    end


Entity.Create.bullet =
    function ( position, direction, speed, strength )
        return
        { position = Vector.copy ( position )
        , direction = Vector.copy ( direction )
        , force = Vector.null ()
        , remainder = Vector.null ()
        , mass = 10
        , width = TILE / 4
        , height = TILE / 4
        , speed = (speed or 10) * TILE
        , strength = (strenght or 1)
        , health = 0
        }
    end


Entity.Create.enemy =
    function ( position, speed, strength )
        return
        { position = Vector.scale ( TILE, position )
        , direction = Vector.null ()
        , force = Vector.null ()
        , remainder = Vector.null ()
        , mass = 1
        , width = TILE
        , height = TILE * 1.5
        , speed = (speed or 2) * TILE
        , strength = (strength or 1)
        , health = 10
        , controllable = Control.AI
        }
    end


Control =
    { input = {}
    , AI = {}
    }


--------------------
-- ALARM
--------------------


Alarm = {}


Alarm.done = {}


Alarm.load =
    function ()
        return {}
    end


Alarm.set =
    function ( alarms, time, event )
        local newAlarm = { time = time, event = event }
        table.insert ( alarms, newAlarm )
    end


Alarm.update =
    function ( alarm, timeDelta )
        alarm.time = alarm.time - timeDelta
        if alarm.time <= 0 then
            alarm.event ()
            return Alarm.done
        end
        return alarm
    end
