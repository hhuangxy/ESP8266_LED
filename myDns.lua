-- Setup DNS server
myDns = {}

function myDns.setup()
    if myDns.sv ~= nil then
        myDns.sv:close()
    end

    -- Get response IP and encode it
    local respIp = wifi.ap.getip()
    local ip1, ip2, ip3, ip4
    ip1, ip2, ip3, ip4 = respIp:match("(%d+).(%d+).(%d+).(%d+)")
    myDns.respIp = string.char(ip1, ip2, ip3, ip4)

    myDns.sv = net.createServer(net.UDP)

    myDns.sv:on("receive",
        function(sv,pl)
            local transId, dnsQ
            transId, dnsQ = myDns.decodePayload(pl)
            sv:send(myDns.buildPayload(transId, dnsQ, myDns.respIp))
        end
    )

    myDns.sv:listen(53)
end

function myDns.decodePayload(pl)
    -- Transaction ID is the first 2 bytes
    local transId = pl:sub(1, 2)

    -- DNS query starts at byte 13
    local dnsQSt = 13
    local dnsQEnC = string.char(0)
    local dnsQEn = pl:find(dnsQEnC, dnsQSt, true)
    local dnsQ = pl:sub(dnsQSt, dnsQEn+4) -- Add remaining 4 bytes for query type and class

    return transId, dnsQ
end

function myDns.buildPayload(transId, dnsQ, respIp)
    local respFlagCodes = string.char(0x80, 0x00)
    local qCount = string.char(0x00, 0x01) -- 1 question
    local aCount = string.char(0x00, 0x01) -- 1 response
    local auCount = string.char(0x00, 0x00)
    local arCount = string.char(0x00, 0x00)

    local dNam = string.char(0xC0, 0x0C) -- Name is a pointer (0xC0), at location 0x0C
    local dTyp = string.char(0x00, 0x01) -- Type is host address
    local dCla = string.char(0x00, 0x01) -- Class is internet address
    local dTtl = string.char(0x00, 0x00, 0x01, 0x00) -- TTL 256 seconds
    local dLen = string.char(0x00, 0x04) -- Length 4 bytes

    return transId..respFlagCodes..qCount..aCount..auCount..arCount..
        dnsQ..
        dNam..dTyp..dCla..dTtl..dLen..respIp
end
