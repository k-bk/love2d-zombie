--------------------
-- TABLE
--------------------


local Table = {}


Table.serialize =
    function ( table )
        local result = "{ "
        for k, v in pairs ( table ) do
            result = result .. k .. " = " .. tostring (v) .. ", "
        end
        return result .. "}"
    end


Table.print =
    function ( table )
        if table == nil then
            error "Table.print was given nil instead of table"
        else
            print ( Table.serialize ( table ) )
        end
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


return Table
