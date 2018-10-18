--------------------
-- ENTITY
--------------------


local Entity = {}


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


Gun =
    { empty = {}
    , loading = {}
    , loaded = {}
    }

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
            , phase = Gun.loaded
            }
        , control = Entity.Control.input
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
        , control = Entity.Control.AI
        }
    end


Entity.Control =
    { input = {}
    , AI = {}
    }


return Entity
