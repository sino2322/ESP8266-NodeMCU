local moduleName = ...
local M = {}
_G[moduleName] = M


local dht_pin=5

local switch_pin=1
--local RGB_LED_Data=4--stastic
--local RGB_LED_Read=switch_pin--only test use
local T3,H3,S3,A3=nil

local function DHT()
    status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)
    if status == dht.OK then
    -- Float firmware using 
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
    return temp,humi
end

local function ADC()
    val = adc.read(0)
    print("ADC:"..val)
    return val
end

local function readSwitch()
    sw = gpio.read(switch_pin)
    print("Switch:"..sw)
    return sw
end
--HERE TO ADD NEW SENSORS
    

function M.getallsensors()
    T3,H3=DHT()
    A3=ADC()
    S3=readSwitch()
    --HERE TO ADD NEW
    --don't forget add it to return
    return T3,H3,S3,A3
end

function M.switch(p1,p2)--waiting to extend
    --print('control received! program not completed yet!')
    if p1=='S3' then
        gpio.mode(switch_pin, gpio.OUTPUT)
        gpio.write(switch_pin,p2)
    end
end

function M.RGBset(p1,p2,p3,p4)
    if p1=='D3' then
        print(p1,p2,p3)
        ws2812.init()
        ws2812.write(string.char(p2,p3,p4))
        gpio.mode(4, gpio.OUTPUT)
        gpio.write(4,1)
    end
end

