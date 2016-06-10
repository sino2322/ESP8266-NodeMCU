--global settings
--forceset=1 the flag to keep setting portal opened
node.dsleep(nil,0)--reset setting
wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid="SmartLink",auth=wifi.AUTH_OPEN})
enduser_setup.manual(true)
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end
)

tmrcount = 0
tmr.alarm(1, 5000, tmr.ALARM_AUTO, function() 
    if wifi.sta.getip()== nil then --ip nil?
        if tmrcount <= 36 then--1=5s,36=3min
            print("IP unavaiable, Waiting...") 
            tmrcount = tmrcount+1
        else
            print('NO Configuration!!!REBOOT!!!')
            tmr.delay(100)
            node.restart()
        end
    else 
        tmrcount = nil--free 
        tmr.stop(1)
        
        http.post('http://www.baidu.com','','',function(code)
            if (code < 0) then--post succeeded?
                print("HTTP request failed!!!REBOOT!!!")
                node.restart()
            else
                print("HTTP request succeeded")
                --print("Internet Connected")
                code = nil --free
                if forceset == 1 then --force setting flag
                else   
                    enduser_setup.stop()
                    wifi.setmode(wifi.STATION)
                    wifi.sta.sethostname("SmartIoT")
                end  
                dofile('main.lua')
            end
        end)
    end
end)

--never forget--
--after being conected to ap--
--close port and ap--
--enduser_setup.stop()
--wifi.setmode(wifi.STATION)
