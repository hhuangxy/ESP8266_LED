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

myLed.maxLeds = 27

-- Initialize buffer and setup UART1
function myLed.setup()
  ws2812.init()
  myLed.buf = ws2812.newBuffer(myLed.maxLeds, 3)
  myLed.buf:fill(0,0,0)
  myLed.buf:write()
end

-- LED test pattern
myLed.tstPat = {
  state = "off",
  timeout = 100,
  i = 1,
  j = 1
}
function myLed.testPatt()
  -- Init
  local i,j
  local tstPat = myLed.tstPat

  if tstPat.state == "last" then
    tstPat.state = "off"
    myLed.buf:fill(0,0,0)
    myLed.buf:write()
    return
  elseif tstPat.state == "off" then
    tstPat.state = "fwd"
    myLed.buf:fill(0,0,0)
    tstPat.i,tstPat.j = 1,1
  end

  i,j = tstPat.i,tstPat.j

  -- R, G, or B?
  if i == 1 then
    myLed.buf:set(j,255,0,0)
  elseif i == 2 then
    myLed.buf:set(j,0,255,0)
  elseif i == 3 then
    myLed.buf:set(j,0,0,255)
  else
    myLed.buf:set(j,0,0,0)
  end

  myLed.buf:write()

  -- Determine next state
  if i == 4 and j == 1 then
    tstPat.state = "last"

  elseif tstPat.state == "fwd" then
    if j == myLed.buf:size() then
      tstPat.state = "hold"
      tstPat.i = i + 1
    else
      tstPat.j = j + 1
    end

  elseif tstPat.state == "bwd" then
    if j == 1 then
      tstPat.state = "hold"
      tstPat.i = i + 1
    else
      tstPat.j = j - 1
    end

  elseif tstPat.state == "hold" then
    if j == 1 then
      tstPat.state = "fwd"
      tstPat.j = j + 1
    else
      tstPat.state = "bwd"
      tstPat.j = j - 1
    end

  end

  -- Arm
  tmr.alarm(0, tstPat.timeout, tmr.ALARM_SINGLE, function() myLed.testPatt() end)
end

-- Control LEDs through website
function myLed.write(numColors, numLeds, colorCodes)
  local r,g,b
  local nLeds,tLeds = 0,0
  myLed.buf:fill(0,0,0)

  for i=1,numColors do
    -- +1 because Lua tables start at index 1
    r = "0x"..(colorCodes[i]:sub(1,2) or 0)
    r = myLed.gammaTable[r+1]

    g = "0x"..(colorCodes[i]:sub(3,4) or 0)
    g = myLed.gammaTable[g+1]

    b = "0x"..(colorCodes[i]:sub(5,6) or 0)
    b = myLed.gammaTable[b+1]

    nLeds = numLeds[i] or 0
    for j=1,nLeds do
      tLeds = tLeds+1
      myLed.buf:set(tLeds,r,g,b)
    end
  end

  myLed.buf:write()
end
