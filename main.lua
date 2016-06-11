local sleepmins=1--max 70 mins
local sleepcnt=60000000*sleepmins
--print('sleepcnt is '..sleepcnt)

print('hello IoT')
require('lewei')
node.dsleep(nil,0)

if LPWR==nil then
    lewei.init()
    tmr.alarm(3, 120000, 1,
    function()
        lewei.updateSensors()
        print('ram '..node.heap())
    end)
else
    lewei.linit()
    tmr.alarm(3, 1000, tmr.ALARM_SINGLE,
    function()
        lewei.updateSensors()
        print(node.heap())
    end)
    tmr.alarm(4, 8000, tmr.ALARM_SINGLE,
    function()
        node.dsleep(sleepcnt,nil)
    end)
    --wait to recv svr's ack
end
    
--rerun this script
--it will lead to a dead loop bug
--loop 3-10 times a sec
--so there is a configuration in lewei.lua#69-75
--haven't found reason yet
