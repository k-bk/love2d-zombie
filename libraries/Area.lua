--------------------
-- AREA
--------------------


local Area = {}


Area.read =
    function ( filename )
        -- TODO read map from JSON format file or sth
        -- return Area
    end


Area.findNavMesh =
    function ( area )
        local findMaxRect =
            function ( x, y )
                local x2, y2 = x - 1, y
                while x2 < area.width and area [x2 + 1][y2] == nil do
                    x2 = x2 + 1
                end

                while y2 < area.height do
                    for i = x, x2 do
                        if area [x2][y2 + 1] != nil then
                            return x2, y2
                        end
                    end





        for i = 1, area.width do
            for