local prefix="IRC: "

irc={}; irc.actions={}; irc.responses={}
local irc_cfg=loadfile("config_ircbot.lc")
if irc_cfg == nil then irc_cfg=assert(loadfile("config_ircbot.lua")) end
irc_cfg() -- Handle this more gracefully, ideally
irc_cfg=nil

local actions_={} -- Construct list of bot commands/actions
for k,v in pairs(irc.actions) do table.insert(actions_,k) end
local action_help="Commands: help "..table.concat(actions_," ")
actions_=nil

local connected=false
local current_nick = irc.nick

function on_connect(c)
  connected=true
  print(prefix.."Connected to: "..irc.server)
  c:send("NICK "..current_nick.."\r\n")
  c:send("USER "..current_nick .." 8 * :"..current_nick.."\r\n")
  for i,ch in ipairs(irc.channels) do 
    c:send("JOIN "..ch.."\r\n")
    if irc.join_message then send_msg_to_channel(c,irc.welcome_message) end
  end
end

function on_disconnect(c)
  connected=false
  print(prefix.."Disconnected from: "..irc.server)
  irc_connection=nil
end

function on_receive(c, text)
  if irc.raw_server_messages then print("--\n"..prefix.."Server sent:\n  "..text:sub(1,-2)) end
  if text:find("PING :") == 1 then
    c:send("PONG :" .. text:sub(7))
    print(prefix.."Responded to server ping with pong")
  elseif text:find(":Nickname is already in use") then
    print(prefix.."Nickname in use")
    if #irc.suffixes > 0 then
      print(prefix.."Trying an alternative nick suffix")
      if current_nick == irc.nick then current_nick = current_nick..irc.suffixes[1]
      else
        for i,v in pairs(irc.suffixes) do
          if current_nick == irc.nick..v then 
            if i ~= #irc.suffixes then current_nick = irc.nick..irc.suffixes[i+1]
            else current_nick = irc.nick
            end
          end
        end
      end
      print("  new nick is: "..current_nick)
      on_connect(c)
    else
      print(prefix.."Disconnecting to try again in ~"..irc.reconnect_time.."s")
      c:close()
    end
  elseif text:find("PRIVMSG ") then -- Channel message
    local user,name,ip,chan,msg = text:match(":([%w_]+)!~([%w_]+)@(%S-)%sPRIVMSG%s(%S-)%s:(%C+)")
    if chan == current_nick then chan = user end -- return message goes back to user
    if msg~=nil then
      print(prefix..user.."("..name..") in "..chan.." sent '"..msg.."'")
      if msg:sub(1,1) == irc.action_char then
        local cmd = msg:sub(2)
        if cmd == 'help' then -- assumed not in actions so check first
          print(prefix.."Identified a command: 'help'")
          send_msg_to_channel(chan, action_help)
        elseif irc.actions[cmd] == nil then
          print(prefix.."Identified a command: '"..cmd.."' (not a command)")
          send_msg_to_channel(chan, "No such command! "..action_help)
        else
          print(prefix.."Identified a command: '"..cmd.."'")
          send_msg_to_channel(chan,irc.actions[cmd](who_said_it))
        end
      end
      for k,v in pairs(irc.responses) do 
        if msg:match(k)~=nil then
          print(prefix.."'"..msg.."' matches response pattern '"..k.."'")
          send_msg_to_channel(chan,v(user))
        end 
      end
    end
  elseif text:find("JOIN ") then
    local user,name,ip,chan=text:match(":([%w_]+)!~([%w_]+)@(%S-)%sJOIN%s([%S]+)")
    print(prefix..user.."("..name..") joined channel "..chan)
  elseif text:find("QUIT") then
    local user,name,ip,reason=text:match(":([%w_]+)!~([%w_]+)@(%S-)%sQUIT%s([%S]+)")
    print(prefix..user.."("..name..") quit due to "..reason)
  elseif text:find("PART") then
    local user,name,ip,chan,reason=text:match(":([%w_]+)!~([%w_]+)@(%S-)%sPART%s([%S]+)%s([%S]+)")
    print(prefix..user.."("..name..") left "..chan.." due to "..reason)
  elseif text:find("NICK") then
    local user,name,ip,newuser = text:match(":([%w_]+)!~([%w_]+)@(%S-)%sNICK%s:([%S]+)")
    print(prefix..name.." changed nick from '"..user.."' to '"..newuser.."'")
  elseif text:find("KICK") then
    print("KICK")
  elseif text:find("ERROR") then
    print("ERROR")
  else
  end
end

function send_msg_to_channel(chan, msg)
  print(prefix.."Message '"..msg.."' sent to "..chan)
  irc_connection:send("PRIVMSG "..chan.." :"..msg.."\r\n")
end

function connect_to_irc_if_have_wifi_and_not_connected()
  if wifi.sta.status()~=5 then
    print(prefix.."Waiting for wifi connection before connecting to server")
  elseif connected == false then 
    print(prefix.."Connecting to IRC server")
    irc_connection = net.createConnection(net.TCP, 0) -- no SSL
    irc_connection:on("receive", on_receive)
    irc_connection:on("connection", on_connect)
    irc_connection:on("disconnection",on_disconnect)
    irc_connection:connect(irc.port,irc.server) -- if network is setup upon loading this file
  end
end
connect_to_irc_if_have_wifi_and_not_connected()
tmr.alarm(irc.irc_timer, irc.reconnect_time*1000, 1, connect_to_irc_if_have_wifi_and_not_connected)