-- Setup LEDs
require("myLed")
myLed.test(20)

-- Setup WIFI
require("myWifi")
myWifi.setupAP()

-- Setup Website
require("myWebsite")
myWebsite.setup()

-- Setup DNS
require("myDns")
myDns.setup()
