--------------------
-- ALARM
--------------------
local Math = require "src/Math"


local Alarm = {}


Alarm.done = {}


Alarm.load =
    function ()
        return {}
    end


Alarm.set =
    function ( alarms, time, event )
        local newAlarm = { total = time, time = 0, event = event }
        table.insert ( alarms, newAlarm )
    end


Alarm.progress =
    function ( alarm )
        Math.clamp ( alarm.time / alarm.total, 0, 1 )
    end


Alarm.update =
    function ( alarm, timeDelta )
        alarm.time = alarm.time + timeDelta
        if alarm.time >= alarm.total then
            if alarm.event then
                alarm.event ()
            end
            return Alarm.done
        end
        return alarm
    end


return Alarm
