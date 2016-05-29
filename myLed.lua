-- Setup LED and UART1
myLed = {}

-- Initialize variables
myLed.gammaTable = {
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,
      2,   3,   3,   3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   5,   5,   5,
      5,   6,   6,   6,   6,   7,   7,   7,   7,   8,   8,   8,   9,   9,   9,  10,
     10,  10,  11,  11,  11,  12,  12,  13,  13,  13,  14,  14,  15,  15,  16,  16,
     17,  17,  18,  18,  19,  19,  20,  20,  21,  21,  22,  22,  23,  24,  24,  25,
     25,  26,  27,  27,  28,  29,  29,  30,  31,  32,  32,  33,  34,  35,  35,  36,
     37,  38,  39,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  50,
     51,  52,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,  64,  66,  67,  68,
     69,  70,  72,  73,  74,  75,  77,  78,  79,  81,  82,  83,  85,  86,  87,  89,
     90,  92,  93,  95,  96,  98,  99, 101, 102, 104, 105, 107, 109, 110, 112, 114,
    115, 117, 119, 120, 122, 124, 126, 127, 129, 131, 133, 135, 137, 138, 140, 142,
    144, 146, 148, 150, 152, 154, 156, 158, 160, 162, 164, 167, 169, 171, 173, 175,
    177, 180, 182, 184, 186, 189, 191, 193, 196, 198, 200, 203, 205, 208, 210, 213,
    215, 218, 220, 223, 225, 228, 231, 233, 236, 239, 241, 244, 247, 249, 252, 255
}

myLed.maxLeds = 20

-- LED test on bootup
function myLed.test()
    local r,g,b
    local numLeds = myLed.maxLeds
    local timeOut = 100000

    ws2812.init()
    ws2812.write(string.rep("\000\000\000", numLeds))

    for k=1,3 do
        if k == 1 then
            r,g,b = 255,0,0
        elseif k == 2 then
            r,g,b = 0,255,0
        else
            r,g,b = 0,0,255
        end

        for i=1,numLeds do
            ws2812.write(
                string.rep("\000\000\000", i-1)..
                string.char(r,g,b)..
                string.rep("\000\000\000", numLeds-i)
            )
            tmr.delay(timeOut)
        end
    end

    ws2812.write(string.rep("\000\000\000", numLeds))
end

-- Control LEDs through website
function myLed.write(numColors, numLeds, colorCodes)
    local r,g,b
    local nLeds,tLeds = 0,0
    local ledTbl = {}

    for i=1,numColors do
        -- +1 because Lua tables start at index 1
        r = "0x"..(colorCodes[i]:sub(1,2) or 0)
        r = myLed.gammaTable[r+1]

        g = "0x"..(colorCodes[i]:sub(3,4) or 0)
        g = myLed.gammaTable[g+1]

        b = "0x"..(colorCodes[i]:sub(5,6) or 0)
        b = myLed.gammaTable[b+1]

        nLeds = numLeds[i] or 0
        tLeds = tLeds + nLeds
        table.insert(ledTbl, string.char(r,g,b):rep(nLeds))
    end

    -- Blank LEDs
    if tLeds < myLed.maxLeds then
        table.insert(ledTbl, string.rep("\000\000\000", myLed.maxLeds-tLeds))
    end

    ws2812.write(table.concat(ledTbl))
end
