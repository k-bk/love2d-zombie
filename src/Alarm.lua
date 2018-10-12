--------------------
-- ALARM
--------------------


local Alarm = {}


Alarm.done = {}


Alarm.load =
    function ()
        return {}
    end


Alarm.set =
    function ( alarms, time, event )
        local newAlarm = { time = time, event = event }
        table.insert ( alarms, newAlarm )
    end


Alarm.update =
    function ( alarm, timeDelta )
        alarm.time = alarm.time - timeDelta
        if alarm.time <= 0 then
            alarm.event ()
            return Alarm.done
        end
        return alarm
    end


return Alarm
