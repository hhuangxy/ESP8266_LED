-- Setup WIFI
myWifi = {}

function myWifi.setupAP()
  local cfg = {}
  local mode, ssid, pwd, ip, netmask, gateway

  wifi.sta.disconnect()

  wifi.setphymode(wifi.PHYMODE_G)
  wifi.sleeptype(wifi.MODEM_SLEEP)

  mode = wifi.getmode()
  if mode ~= wifi.SOFTAP then
    wifi.setmode(wifi.SOFTAP)
  end

  cfg = {
    ssid = "ESP8266_LED",
    pwd = "ESP8266_LED"
  }
  ssid, pwd = wifi.ap.getconfig()
  if ssid ~= cfg.ssid or
     pwd  ~= cfg.pwd then

    wifi.ap.config(cfg)
  end

  cfg = {
    ip = "192.168.1.1",
    netmask = "255.255.255.0",
    gateway = "192.168.1.1"
  }
  ip, netmask, gateway = wifi.ap.getip()
  if ip      ~= cfg.ip or
     netmask ~= cfg.netmask or
     gateway ~= cfg.gateway then

    wifi.ap.setip(cfg)
  end
end

function myWifi.setupSTA()
  local cfg = {}
  local mode, ssid, pwd

  wifi.sta.disconnect()

  wifi.setphymode(wifi.PHYMODE_N)
  wifi.sleeptype(wifi.MODEM_SLEEP)

  mode = wifi.getmode()
  if mode ~= wifi.STATION then
    wifi.setmode(wifi.STATION)
  end

  cfg = {
    ssid = "ABCD1234",
    pwd = "ABCD1234",
    hostname = "ABCD1234"
  }
  wifi.sta.sethostname(cfg.hostname)

  ssid, pwd = wifi.sta.getconfig()
  if ssid ~= cfg.ssid or
     pwd  ~= cfg.pwd then

    wifi.sta.config(cfg.ssid, cfg.pwd)
  end
end
