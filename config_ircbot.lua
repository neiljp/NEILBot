local me="ESPTestn"
irc = {
  nick = me ,
  suffixes = { '_','__'} ,
  channels = {"#57Ntest","#57N"} ,
  server = "chat.freenode.net" ,
  port = 6667 ,
  join_message = nil ,

  reconnect_time = 60 , -- seconds before trying to reconnect to server
  alarm_tmr = 3 , -- alarm timer to use internally (to reconnect to server)

  action_char = "~" ,
  actions = { 
    uptime = function(n) return uptime() end ,
    wifi = function(n) return wifistatus(2) end ,
    heap = function(n) return node.heap() end ,
    IDs = function(n) return "ChipID: "..node.chipid().." FlashID: "..node.flashid() end ,
    MAC = function(n) return wifi.sta.getmac() end ,
  } ,
  responses = {
    ["^[Pp]ing$"] = function(n) return "Ack!" end ,
    ["^[Hh][iI] "..me] = function(n) return "Hi "..n.."!" end ,
  } ,

  raw_server_messages = false , -- Show messages sent from server? (aids debugging)
  log = print ,-- Function to use to log messages (use print or define your own)
}
