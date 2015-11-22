irc.nick = "ESPTestn"
irc.suffixes = { '_','__'}
irc.channels = {"#57Ntest","#57N"}
irc.server = "chat.freenode.net"
irc.port = 6667
irc.join_message = nil
irc.reconnect_time = 60 -- seconds

irc.action_char = "~"

irc.actions["uptime"] = function(n) return uptime() end
irc.actions["wifistatus"] = function(n) return wifistatus(2) end
irc.actions["heap"] = function(n) return node.heap() end
irc.actions["IDs"] = function(n) return "ChipID: "..node.chipid().." FlashID: "..node.flashid() end
irc.actions["MAC"] = function(n) return wifi.sta.getmac() end
irc.responses["^[Dd]ing$"]=function(n) return "DONG!" end
irc.responses["^[Hh][iI] "..irc.nick]=function(n) return "Hi "..n.."!" end

irc.irc_timer = 3
irc.raw_server_messages = true
