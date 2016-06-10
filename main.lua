local sleepmins=0.5--max 70 mins
local sleepcnt=60000000*sleepmins

print('hello IoT')
require('lewei')
node.dsleep(nil,0)
--tmr.alarm(4,100,1,
--    function()
        
--    end)
if LPWR==nil then
    lewei.init()
    tmr.alarm(3, 60000, 1,
    function()
        lewei.updateSensors()
    end)
else
    lewei.postSensors()--low power cost method
    --tmr.alarm(3, 60000, 1,
    --function()
        --lewei.updateSensors()
    --end)
end
    
--rerun this script
--it will lead to a dead loop bug
--loop 3-10 times a sec
--so there is a configuration in lewei.lua#69-75
