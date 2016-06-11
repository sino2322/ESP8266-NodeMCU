forceset=nil--force set wifi
LPWR=nil--low power mode
node.dsleep(nil,0)
print('link start!')
if adc.force_init_mode(adc.INIT_ADC) then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

dofile('enduser.lua')

--print('get ip '..wifi.sta.getip())
--print('end')
