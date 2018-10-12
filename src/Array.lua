--------------------
-- ARRAY
--------------------


local Array = {}


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


Array.union =
    function ( A, B )
        local C = {}
        for _, v in ipairs ( A ) do
            table.insert ( C, v )
        end
        for _, v in ipairs ( B ) do
            table.insert ( C, v )
        end
        return C
    end


return Array
