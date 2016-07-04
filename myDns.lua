-- Setup DNS server
myDns = {}

-- Initialize variables
myDns.respHeader = {
  transId = "\000\000",

  respFlagCodes = "\128\000",
  qCount  = "\000\001", -- 1 question
  aCount  = "\000\001", -- 1 response
  auCount = "\000\000",
  arCount = "\000\000",

  dnsQ =  "\000",

  dNam = "\192\012", -- Name is a pointer (0xC0) at location 0x0C
  dTyp = "\000\001", -- Type is host address
  dCla = "\000\001", -- Class is internet address
  dTtl = "\000\000\001\000", -- TTL 256 seconds
  dLen = "\000\004", -- Length 4 bytes

  respIp = "\000\000\000\000"
}

function myDns.setup()
  if myDns.sv ~= nil then
    myDns.sv:close()
  end

  -- Get response IP and encode it
  local respIp = wifi.ap.getip()
  local ip1, ip2, ip3, ip4 = respIp:match("(%d+).(%d+).(%d+).(%d+)")
  myDns.respHeader.respIp = string.char(ip1, ip2, ip3, ip4)

  myDns.sv = net.createServer(net.UDP)

  myDns.sv:on("receive",
    function(sv,pl)
      local transId, dnsQ = myDns.decodePayload(pl)
      sv:send(myDns.buildPayload(transId, dnsQ))
    end
  )

  myDns.sv:listen(53)
end

function myDns.decodePayload(pl)
  -- Transaction ID is the first 2 bytes
  local transId = pl:sub(1, 2)

  -- DNS query starts at byte 13
  local dnsQSt = 13
  local dnsQEn = pl:find("\000", dnsQSt, true)
  local dnsQ   = pl:sub(dnsQSt, dnsQEn+4) -- Add remaining 4 bytes for query type and class

  return transId, dnsQ
end

function myDns.buildPayload(transId, dnsQ)
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
    myDns.respHeader.respIp
end
