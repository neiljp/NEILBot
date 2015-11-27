irc.nick = "ESPTestn"
irc.suffixes = { '_','__'}
irc.channels = {"#57Ntest","#57N"}
irc.server = "chat.freenode.net"
irc.port = 6667
irc.join_message = nil

irc.reconnect_time = 60 -- seconds before trying to reconnect to server
irc.alarm_tmr = 3 -- alarm timer to use internally (to reconnect to server)

irc.action_char = "~"
irc.actions = { 
  uptime = function(n) return uptime() end ,
  wifi = function(n) return wifistatus(2) end ,
  heap = function(n) return node.heap() end ,
  IDs = function(n) return "ChipID: "..node.chipid().." FlashID: "..node.flashid() end ,
  MAC = function(n) return wifi.sta.getmac() end ,
}
irc.responses = {
  ["^[Dd]ing$"] = function(n) return "DONG!" end ,
  ["^[Hh][iI] "..irc.nick] = function(n) return "Hi "..n.."!" end ,
}

irc.raw_server_messages = false -- Show messages sent from server? (aids debugging)
irc.log = print -- Function to use to log messages (use print or define your own)
