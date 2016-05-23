-- Setup LED and UART1
myLed = {}

-- LED test on bootup
function myLed.test(numLeds)
    local r,g,b
    local ledTbl = {}
    local timeOut = 100000

    ws2812.init()
    ws2812.write(string.char(0,0,0):rep(numLeds))

    for k=1,3 do
        if k == 1 then
            r = 255; g = 0; b = 0
        elseif k == 2 then
            r = 0; g = 255; b = 0
        else
            r = 0; g = 0; b = 255
        end

        for i=1,numLeds do
            ledTbl = {}
            table.insert(ledTbl, string.char(0,0,0):rep(i-1))
            table.insert(ledTbl, string.char(r,g,b))
            table.insert(ledTbl, string.char(0,0,0):rep(numLeds-i))

            ws2812.write(table.concat(ledTbl))
            tmr.delay(timeOut)
        end
    end

    ws2812.write(string.char(0,0,0):rep(numLeds))
end

-- Control LEDs through website
function myLed.write(numColors, numLeds, colorCodes)
    local r,g,b
    local ledTbl = {}
    for i=1,numColors do
        r = "0x"..(colorCodes[i]:sub(1,2) or 0)
        g = "0x"..(colorCodes[i]:sub(3,4) or 0)
        b = "0x"..(colorCodes[i]:sub(5,6) or 0)
        table.insert(ledTbl, string.char(r,g,b):rep(numLeds[i] or 0))
    end

    ws2812.write(table.concat(ledTbl))
end
