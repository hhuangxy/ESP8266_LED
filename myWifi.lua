-- Setup WIFI
myWifi = {}

function myWifi.setupAP()
    local cfg = {}

    wifi.sta.disconnect()

    cfg = {
        ssid = "ESP8266",
        pwd = "asdfasdf"
    }
    wifi.ap.config(cfg)

    cfg = {
        ip = "192.168.1.1",
        netmask = "255.255.255.0",
        gateway = "192.168.1.1"
    }
    wifi.ap.setip(cfg)

    wifi.setphymode(wifi.PHYMODE_G)
    wifi.sleeptype(wifi.MODEM_SLEEP)
    wifi.setmode(wifi.SOFTAP)
end

function myWifi.setupSTA()
    local cfg = {}

    wifi.sta.disconnect()

    wifi.setphymode(wifi.PHYMODE_G)
    wifi.sleeptype(wifi.MODEM_SLEEP)
    wifi.setmode(wifi.STATION)

    cfg = {
        ssid = "",
        pwd = "",
        hostname = ""
    }
    wifi.sta.sethostname(cfg.hostname)
    wifi.sta.config(cfg.ssid, cfg.pwd)
end
