local moduleName = ...
local M = {}
_G[moduleName] = M

local dht_pin=5
local switch_pin_read=6
local switch_pin_write=4
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
    gpio.mode(switch_pin_read, gpio.INPUT)
    sw = gpio.read(switch_pin_read)
    print("Switch:"..sw)
    return sw
end

    

function M.getallsensors()
    T3,H3=DHT()
    A3=ADC()
    S3=readSwitch()
    return T3,H3,S3,A3
end

function M.switch(p1,p2)--waiting to extend
    --print('control received! program not completed yet!')
    if p1=='S3' then
        gpio.mode(switch_pin_write, gpio.OUTPUT)
        gpio.write(switch_pin_write,p2)
    end
end
