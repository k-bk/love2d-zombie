--------------------
-- ALARM
--------------------
local Math = require "libraries/Math"


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
        return newAlarm
    end


Alarm.progress =
    function ( alarm )
        if alarm == Alarm.done then
            return 0
        else
            return Math.clamp ( alarm.time / alarm.total, 0, 1 )
        end
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
