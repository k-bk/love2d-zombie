--------------------
-- INPUT
--------------------


require "src/Queue"


local Input = {}


Input.load =
    function ()
        return
        { up = false
        , down = false
        , left = false
        , right = false
        , mouseLeft = false
        , mouseLeftPressed = false
        , mouseRight = false
        , mouseRightPressed = false
        , mouse = Vector.null ()
        , mouseHistory = Queue.new ()
        , wheelUp = 0
        , wheelDown = 0
        , wheelHistory = {}
        }
    end


Input.resetPressed =
    function ( input )
        input.mouseLeftPressed = false
        input.mouseRightPressed = false
    end


Input.updateGestures =
    function ( input, currentTime )
        local maxTime = 0.5
        input.wheelUp = 0
        input.wheelDown = 0
        for time, move in pairs ( input.wheelHistory ) do
            if currentTime - time > maxTime then
                input.wheelHistory [time] = nil
            elseif move > 0 then
                input.wheelUp = input.wheelUp + move
            elseif move < 0 then
                input.wheelDown = input.wheelDown - move
            end
        end
    end


Input.resetWheel =
    function ( input )
        input.wheelUp, input.wheelDown, input.wheelHistory = 0, 0, {}
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


Input.keyPressed =
    function ( input, scanCode )
        if scanCode == "w" or scanCode == "up" then
            input.up = true
        elseif scanCode == "s" or scanCode == "down" then
            input.down = true
        elseif scanCode == "a" or scanCode == "left" then
            input.left = true
        elseif scanCode == "d" or scanCode == "right" then
            input.right = true
        end
    end


Input.keyReleased =
    function ( input, scanCode )
        if scanCode == "w" or scanCode == "up" then
            input.up = false
        elseif scanCode == "s" or scanCode == "down" then
            input.down = false
        elseif scanCode == "a" or scanCode == "left" then
            input.left = false
        elseif scanCode == "d" or scanCode == "right" then
            input.right = false
        end
    end


Input.mousePressed =
    function ( input, x, y, button )
        input.mouse = { x = x, y = y }
        if button == 1 then
            input.mouseLeftPressed = true
            input.mouseLeft = true
        elseif button == 2 then
            input.mouseRightPressed = true
            input.mouseRight = true
        end
    end


Input.mouseReleased =
    function ( input, x, y, button )
        input.mouse = { x = x, y = y }
        if button == 1 then
            input.mouseLeftPressed = false
            input.mouseLeft = false
        elseif button == 2 then
            input.mouseRightPressed = false
            input.mouseRight = false
        end
    end


Input.mouseMoved =
    function ( input, x, y )
        input.mouse = { x = x, y = y }
        Queue.push ( input.mouseHistory, input.mouse )
        if Queue.size ( input.mouseHistory ) > 50 then
            Queue.pop ( input.mouseHistory )
        end
    end


Input.wheelMoved =
    function ( input, move, time )
        input.wheelHistory [time] = move
    end


return Input
