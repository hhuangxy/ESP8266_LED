-- Setup website
myWebsite = {}

-- Initialize variables
myWebsite.debugFlag = false

function myWebsite.setup()
  if myWebsite.sv ~= nil then
    myWebsite.sv:close()
  end

  -- Create TCP server with 30s timeout
  myWebsite.sv = net.createServer(net.TCP, 30)

  -- Listen on port 80
  myWebsite.sv:listen(80, myWebsite.cbListen)
end

function myWebsite.debugPrint(...)
  if myWebsite.debugFlag == true then
    for i=1,#arg do
      if type(arg[i]) == "table" then
        for k=1,#arg[i] do
          print("arg["..i.."]: ", k, arg[i][k])
        end
      else
        print("arg["..i.."]: ", arg[i])
      end
    end
  end
end

function myWebsite.cbListen(sk)
  sk:on("receive", myWebsite.cbReceive)
end

function myWebsite.cbReceive(sk, payload)
  local temp, state
  myWebsite.debugPrint("cbReceive", payload)

  -- Determine state
  temp = payload:match("GET /([^%s/]*) HTTP/1.1")
  if temp ~= nil then
    state = "website"

  elseif payload:match("btnSubmit") ~= nil then
    state = "submit"

  elseif payload:match("btnTest") ~= nil then
    state = "test"

  elseif payload:match("btnReboot") ~= nil then
    state = "reboot"

  else
    state = "default"
  end

  -- Execute state
  if state == "submit" then
    -- Find number of LEDs and colorCodes
    local numColors = 0
    local numLeds = {}
    local colorCodes = {}

    for t=1,1 do
      -- All LEDs
      temp = payload:match("colorCodeAll=%%23(%x+)")
      if temp ~= nil then
        numLeds[1] = myLed.maxLeds
        colorCodes[1] = temp
        break
      end

      -- Each letter
      temp = payload:match("colorCodeD1=%%23(%x+)")
      if temp ~= nil then
        numLeds[1] = 8
        numLeds[2] = 11
        numLeds[3] = 8
        colorCodes[1] = temp
        colorCodes[2] = payload:match("colorCodeD2=%%23(%x+)")
        colorCodes[3] = payload:match("colorCodeD3=%%23(%x+)")
        break
      end

      -- Advance
      for i=1,myLed.maxLeds do
        temp = payload:match("numLED"..i.."=(%d+)")
        if temp ~= nil then
          numLeds[i] = temp
          colorCodes[i] = payload:match("colorCode"..i.."=%%23(%x+)")
        else
          break
        end
      end
    end -- End of t

    numColors = #numLeds

    -- Update LED colors
    myWebsite.debugPrint("myLED.write", numColors, numLeds, colorCodes)
    myLed.write(numColors, numLeds, colorCodes)

    sk:send("HTTP/1.1 204 No Content\r\n\r\n", function(sk) sk:close() end)

  elseif state == "website" then
    -- Serve webpage/files
    if temp == "" then
      -- Send homepage
      myWebsite.sendFile(sk, "index.html")
    elseif #temp < 20 then
      -- Assume that max filename length is < 20
      myWebsite.sendFile(sk, temp)
    else
      -- Send 404
      sk:send("HTTP/1.1 404 Not Found\r\n\r\n", function(sk) sk:close() end)
    end

  elseif state == "test" then
    -- Test pattern button was pressed
    sk:send("HTTP/1.1 204 No Content\r\n\r\n",
      function(sk)
        sk:close()
        myLed.testPatt()
      end
    )

  elseif state == "reboot" then
    -- Reboot button was pressed
    sk:send("HTTP/1.1 204 No Content\r\n\r\n",
      function(sk)
        sk:close()
        node.restart()
      end
    )

  else
    sk:send("HTTP/1.1 404 Not Found\r\n\r\n", function(sk) sk:close() end)
  end
end

function myWebsite.sendFile(sk, fName)
  local fStr = ""
  local respTbl = {}

  -- Build response table
  if file.open(fName, "r") ~= nil then
    respTbl = {"HTTP/1.1 200 OK\r\n\r\n"}
    fStr = file.read()
    while (fStr ~= nil) do
      table.insert(respTbl, fStr)
      fStr = file.read()
    end
    myWebsite.debugPrint("sendFile", "Closing "..fName)
    file.close()
  else
    respTbl = {
      "HTTP/1.1 404 Not Found\r\n\r\n",
      "<!DOCTYPE html><html><body>Error: "..fName.." not found</body></html>"
    }
  end

  -- Sent CB to send response table
  local function cbSendMore (sk)
    if #respTbl > 0 then
      sk:send(table.remove(respTbl, 1))
    else
      myWebsite.debugPrint("sendFile", "Closing", sk)
      sk:close()
    end
  end

  sk:on("sent", cbSendMore)
  cbSendMore(sk)
end
