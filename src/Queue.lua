--------------------
-- Queue
--------------------


local Queue = {}


Queue.new =
    function ()
        return {first = 1, last = 0}
    end


Queue.push =
    function ( queue, element )
        queue.last = queue.last + 1
        queue [queue.last] = element
    end


Queue.pop =
    function ( queue )
        if Queue.empty ( queue ) then
            error ("queue is empty")
        else
            local element = queue [queue.first]
            queue [queue.first] = nil
            queue.first = queue.first + 1
            return element
        end
    end


Queue.empty =
    function ( queue )
        return queue.first > queue.last
    end


return Queue
