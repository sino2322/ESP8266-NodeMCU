local moduleName = ...
local M = {}
_G[moduleName] = M

local socket = nil
local server = "tcp.lewei50.com"
local port = 9960
local bConnected = false
local data = nil
local feedback = nil
local T3,H3,S3,A3=nil--sensors' id
local strOnline=nil
local gateWay=nil
local userKey=nil
local lasttime=0--tmrcnt init
local nowtime=nil--tmrcnt

local function dealResponse(str)
    str=string.gsub (str, '&^!','')
    luat = cjson.decode(str)
    if luat.f == 'getAllSensors' then--sever开关量使能
        require('sensors')
        T3,H3,S3,A3 = sensors.getallsensors()
        data='{\"id\":\"A3\",\"value\":\"'..A3..'\"}'
        data='{\"id\":\"S3\",\"value\":\"'..S3..'\"},'..data
        data='{\"id\":\"H3\",\"value\":\"'..H3..'\"},'..data
        data='{\"id\":\"T3\",\"value\":\"'..T3..'\"},'..data
        feedback='{\"method\":\"response\",\"result\":{\"successful\":true,\"message\":\"ok\",\"data\":['..data..']}}&^!'
        print(feedback)
        socket:send(feedback)
        data=nil
        feedback=nil
    end
    if luat.f == 'LEDcontrol' then--自定义命令
        require('sensors')
        sensors.switch(luat.p1,luat.p2)--return0 if ON,return1 if OFF
        feedback='{\"method\":\"response\",\"result\":{\"successful\":true,\"message\":\"received\"}}&^!'
        socket:send(feedback)
        feedback=nil
    end
    if luat.f == 'updateSensor' then  --response sever's request to control local obj
        require('sensors')
        sensors.switch(luat.p1,luat.p2)
        feedback='{\"method\":\"response\",\"result\":{\"successful\":true,\"message\":\"received\"}}&^!'
        --print(feedback)
        
        socket:send(feedback)
        feedback=nil
    end
    if luat.f == 'RGBSET' then
        require('sensors')
        sensors.RGBset(luat.p1,luat.p2,luat.p3,luat.p4)
        feedback='{\"method\":\"response\",\"result\":{\"successful\":true,\"message\":\"received\"}}&^!'
        socket:send(feedback)
        feedback=nil
    end
    
    --extend your orders
    --if luat.f == 'getAllSensors' then  --extend use
    --if luat.f == 'getAllSensors' then  --extend use
    str=nil
    luat=nil
end
    
--connect to sever
local function connectServer()
     socket=net.createConnection(net.TCP, 0)
     socket:on("connection",
     function(sck, response)
          print("Server Connected")
          socket:send(strOnline)
          bConnected = true
     end)
     socket:on("disconnection",
     function(sck, response)
          print("Server Disconnected")
          bConnected = false
          --save pwr
          if LPWR==nil then
            connectServer()
          end
     end)
     socket:on("receive",
     function(sck, response)
          print("receive"..response)
          dealResponse(response)
     end)
     socket:on("sent",
     function(sck, response)
          nowtime=tmr.now()
          print("sent at systime "..nowtime..' us')
          delta=nowtime-lasttime--to culculate time between loops
          if delta<100000 then--prevent dead loop
            if delta>0 then
                node.restart()--once entered dead loop,then restart
            end
          end
          lasttime=nowtime
     end)
     socket:connect(port, server)
end

--keep alive
local function keepOnline()
     if bConnected == true then
          socket:send(strOnline)
     else
          connectServer()
     end
end


function M.updateSensors()
    require('sensors')
    T3,H3,S3,A3 = sensors.getallsensors()
    data='{\"Name\":\"A3\",\"Value\":\"'..A3..'\"}'
    data='{\"Name\":\"S3\",\"Value\":\"'..S3..'\"},'..data
    data='{\"Name\":\"H3\",\"Value\":\"'..H3..'\"},'..data
    data='{\"Name\":\"T3\",\"Value\":\"'..T3..'\"},'..data
    feedback='{\"method\":\"upload\",\"data\":['..data..']}&^!'
    socket:send(feedback)  
    --print(data)
    --print(feedback)
    data=nil
    feedback=nil
end


function M.init()--keep online,svr control avaliable
    file.open("usercfg.lua", "r")
    userKey=file.readline()--read line 
    --print(userKey)
    userKey=string.gsub (userKey, ':userkey\n','')--去除\n
    gateWay=file.readline()--read line
    --print(gateWay)
    gateWay=string.gsub (gateWay, ':gateway\n','')
    file.close()
    strOnline = "{\"method\":\"update\",\"gatewayNo\":\""..gateWay.."\",\"userkey\":\""..userKey.."\"}&^!"
    userKey=nil
    gateWay=nil
    connectServer()--do not use tim channel 1 2
    tmr.alarm(2, 50000, 1,
    function()
        keepOnline()
    end
    )
end

function M.linit()--do not keep online,svr control not avaliable
    file.open("usercfg.lua", "r")
    userKey=file.readline()--read line 
    --print(userKey)
    userKey=string.gsub (userKey, ':userkey\n','')--去除\n
    gateWay=file.readline()--read line
    --print(gateWay)
    gateWay=string.gsub (gateWay, ':gateway\n','')
    file.close()
    strOnline = "{\"method\":\"update\",\"gatewayNo\":\""..gateWay.."\",\"userkey\":\""..userKey.."\"}&^!"
    userKey=nil
    gateWay=nil
    connectServer()
end
