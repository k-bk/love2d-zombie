--------------------
-- Queue
--------------------


local Queue = {}


Queue.new =
    function ()
        return {first = 1, last = 0}
    end


Queue.size =
    function ( queue )
        return queue.last - queue.first + 1
    end


Queue.head =
    function ( queue )
        if Queue.empty ( queue ) then
            return {}
        else
            return queue [queue.first]
        end
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


Queue.iterate =
    function ( queue )
        local current = queue.first
        local last = queue.last
        return
        function ()
            if current < last then
                current = current + 1
                return queue [current]
            end
        end
    end


return Queue
