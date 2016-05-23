-- Setup DNS server
myDns = {}

-- Initialize variables
myDns.respHeader = {
    transId = string.char(0x00, 0x00),

    respFlagCodes = string.char(0x80, 0x00),
    qCount = string.char(0x00, 0x01), -- 1 question
    aCount = string.char(0x00, 0x01), -- 1 response
    auCount = string.char(0x00, 0x00),
    arCount = string.char(0x00, 0x00),

    dnsQ =  string.char(0x00),

    dNam = string.char(0xC0, 0x0C), -- Name is a pointer (0xC0),, at location 0x0C
    dTyp = string.char(0x00, 0x01), -- Type is host address
    dCla = string.char(0x00, 0x01), -- Class is internet address
    dTtl = string.char(0x00, 0x00, 0x01, 0x00), -- TTL 256 seconds
    dLen = string.char(0x00, 0x04), -- Length 4 bytes

    respIp = string.char(0x00, 0x00, 0x00, 0x00)
}

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
    return transId..
        myDns.respHeader.respFlagCodes..
        myDns.respHeader.qCount..
        myDns.respHeader.aCount..
        myDns.respHeader.auCount..
        myDns.respHeader.arCount..
        dnsQ..
        myDns.respHeader.dNam..
        myDns.respHeader.dTyp..
        myDns.respHeader.dCla..
        myDns.respHeader.dTtl..
        myDns.respHeader.dLen..
        respIp
end
