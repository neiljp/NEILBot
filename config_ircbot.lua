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

  actions_char = "~" ,
  actions_usenotice = true , -- use NOTICE? (or else PRIVMSG = regular messages)
  actions = { -- command_name = string | function
    uptime = function(n) return uptime() end ,
    wifi = function(n) return wifistatus(2) end ,
    heap = function(n) return node.heap() end ,
    df = function(n) local free,used,tot=file.fsinfo() return free.." (free) + "..used.." (used) = "..tot.." (total)" end ,
    IDs = "Chip: "..node.chipid().." Flash: "..node.flashid() ,
    MAC = function(n) return wifi.sta.getmac() end ,
    src = "https://github.com/neiljp/nodemcu_lua_ircbot" ,
  } ,
  responses = {
    ["^[Pp]ing$"] = function(n) return "Ack!" end ,
    ["^[Hh][iI] "..me] = function(n) return "Hi "..n.."!" end ,
  } ,

  raw_server_messages = false , -- Show messages sent from server? (aids debugging)
  log = function(s) print("IRC: "..uptime().." "..s) end , -- How to log messages
}
