--------------------
-- TABLE
--------------------


local Table = {}


Table.serialize =
    function ( table )
        if type ( table ) == "table" then
            local result = "{ "
            for k, v in pairs ( table ) do
                result = result .. k .. " = "
                if type ( v ) == "table" then
                    result = result .. Table.serialize (v) .. ", "
                else
                    result = result .. tostring (v) .. ", "
                end
            end
            return result .. "}"
        else
            return "Not a table"
        end
    end


Table.print =
    function ( table )
        if table == nil then
            print ( "nil" )
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
