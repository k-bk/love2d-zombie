Alarm = require "src/Alarm"
Array = require "src/Array"
Color = require "src/Color"
Entity = require "src/Entity"
Input = require "src/Input"
Math = require "src/Math"
Navigation = require "src/Navigation"
Queue = require "src/Queue"
Sound = require "src/Sound"
Table = require "src/Table"
Vector = require "src/Vector"


--------------------
-- LOAD
--------------------


TILE =
    64


love.load =
    function ()
        local player =
            Entity.Create.player { x = 1, y = 1 }

        local staticObstacles =
            { Entity.Create.obstacle { x = 5, y = 5 }
            , Entity.Create.obstacle { x = 5, y = 6 }
            , Entity.Create.obstacle { x = 6, y = 7 }
            , Entity.Create.obstacle { x = 4, y = 7 }
            , Entity.Create.obstacle { x = 4, y = 8 }
            , Entity.Create.obstacle { x = 6, y = 8 }
            }

        local dynamicEntities =
            { player
            , Entity.Create.box ( { x = 3, y = 3 }, 1 )
            , Entity.Create.box ( { x = 5, y = 3 }, 1 )
            , Entity.Create.box ( { x = 4, y = 3 }, 1 )
            , Entity.Create.enemy { x = 7, y = 7 }
            }

        local screenWidth = 800
        local screenHeight = 600

        Sound.load ( screenWidth, screenHeight )

        model =
            { entities = Array.union ( staticObstacles, dynamicEntities )
            , player = player
            , screenWidth = screenWidth
            , screenHeight = screenHeight
            , canvas = love.graphics.newCanvas ( screenWidth, screenHeight )
            , input = Input.load ()
            , alarms = Alarm.load ()
            --, navigationMesh = Navigation.createMesh ( staticObstacles, 800, 600 )
            }
    end


--------------------
-- UPDATE
--------------------


love.update =
    function ( timeDelta )
        model.time = love.timer.getTime ()
        Input.updateGestures ( model.input, model.time )
        local inputVector = Input.toVector ( model.input )

        Update.shooting ( model.entities, model.input, timeDelta )
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
            local control = entity.control
            if entity.direction then
                if control == Entity.Control.input then
                    entity.direction = Vector.copy ( inputVector )
                elseif control == Entity.Control.AI then
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
    function ( entities, input, timeDelta )
        local shoot =
            function ( entity )
                local shooting = entity.shooting
                local position = Vector.add ( entity.position, shooting.origin )
                local dir = Vector.sub ( input.mouse, position )
                dir = Vector.normalize ( dir )
                local bullet = Entity.Create.bullet ( position, dir )
                bullet.mask = { entity }
                return bullet
            end

        local loadGun =
            function ( entity )
                local phase = entity.shooting.phase
                if phase == Gun.loading and input.wheelUp > 0 then
                    entity.shooting.phase = Gun.loaded
                    Input.resetWheel ( input )
                    Sound.playRandomized (
                        Sound.shotgun.loaded
                        , entity.position
                        , 1 )
                elseif phase == Gun.empty and input.wheelDown > 0 then
                    entity.shooting.phase = Gun.loading
                    Input.resetWheel ( input )
                    Sound.playRandomized (
                        Sound.shotgun.loading
                        , entity.position
                        , 1 )
                end
            end

        local newBullets = {}
        for _, entity in ipairs ( entities ) do
            if entity.position and entity.shooting then
                loadGun ( entity )
                if input.mouseLeftPressed
                    and entity.shooting.phase == Gun.loaded
                then
                    local bullet = shoot ( entity )
                    table.insert ( newBullets, bullet )
                    entity.shooting.phase = Gun.empty
                    Sound.playRandomized (
                        Sound.shotgun.shoot
                        , entity.position
                        , 1 )
                    Input.resetWheel ( input )
                end
            end
        end
        for _, bullet in ipairs ( newBullets ) do
            table.insert ( entities, bullet )
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


love.wheelmoved =
    function ( x, y )
        Input.wheelMoved ( model.input, y, model.time )
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
            Draw.cursorTrace ( model.input )

            local oldColor = Color.getActual ()
            love.graphics.setColor ( 0.8, 0, 0 )
            Navigation.drawVertices ( model.navigationMesh )
            love.graphics.setColor ( oldColor )

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


Draw.cursorTrace =
    function ( input )
        local pointA = Queue.head ( input.mouseHistory )
        for pointB in Queue.iterate ( input.mouseHistory ) do
            love.graphics.line ( pointA.x, pointA.y, pointB.x, pointB.y )
            pointA = pointB
        end
    end
