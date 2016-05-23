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
                for k,v in pairs(arg[i]) do
                    print("arg["..i.."]: ", k, v)
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
    local temp
    myWebsite.debugPrint("cbReceive", payload)

    -- Serve webpage/files
    temp = payload:match("GET /([^%s/]*) HTTP/1.1")
    if temp ~= nil then
        if temp == "" then
            myWebsite.sendFile(sk, "index.html")
        else
            myWebsite.sendFile(sk, temp)
        end
    end

    -- Reboot button was pressed
    temp = payload:match("btnReboot")
    if temp ~= nil then
        sk:send("HTTP/1.1 204 No Content\r\n\r\n", function(sk) sk:close() end)
        tmr.softwd(2)
    end

    -- Find number of LEDs and colorCodes
    temp = payload:match("btnSubmit")
    if temp ~= nil then
        local numColors = 0
        local numLeds = {}
        local colorCodes = {}

        -- Fill tables
        local i = 1
        while true do
            temp = payload:match("numLED"..i.."=(%d+)")
            if temp ~= nil then
                numLeds[i] = temp
                colorCodes[i] = payload:match("colorCode"..i.."=%%23(%x+)")
                i = i + 1
            else
                break
            end
        end

        numColors = #numLeds

        -- Update LED colors
        myWebsite.debugPrint("myLED.write", numColors, numLeds, colorCodes)
        myLed.write(numColors, numLeds, colorCodes)

        sk:send("HTTP/1.1 204 No Content\r\n\r\n", function(sk) sk:close() end)
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
