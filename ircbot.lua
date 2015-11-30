local irc_cfg=loadfile("config_ircbot.lc")
if irc_cfg == nil then irc_cfg=assert(loadfile("config_ircbot.lua")) end
irc_cfg() -- Handle this more gracefully, ideally
irc_cfg=nil collectgarbage()

local actions_={} -- Construct list of bot commands/actions
for k,v in pairs(irc.actions) do table.insert(actions_,k) end
local action_help="Commands: help "..table.concat(actions_," ")
actions_=nil collectgarbage()

local connected=false
local current_nick = irc.nick

local function on_connect(c)
  connected=true
  irc.log("Connected to: "..irc.server)
  c:send("NICK "..current_nick.."\r\n")
  c:send("USER "..current_nick .." 8 * :"..current_nick.."\r\n")
  for i,ch in ipairs(irc.channels) do 
    c:send("JOIN "..ch.."\r\n")
    if irc.join_message then send_msg_to_channel(c,irc.welcome_message,false) end
  end
end

local function on_disconnect(c)
  connected=false
  irc.log("Disconnected from: "..irc.server)
  irc_connection=nil
end

local function on_receive(c, text)
  local user_match = ":([^%s]+)!~([^%s]+)@([^%s]+)%s" -- matches nick,name,location
  if irc.raw_server_messages then irc.log("Server sent:\n["..text.."]") end
  for line in string.gmatch(text,"(.-\r\n)") do -- text may be multiline, so use loop
    if line:find("PING :") == 1 then
      c:send("PONG :" .. line:sub(7))
      irc.log("Responded to server ping with pong")
    elseif line:find(":Nickname is already in use") then
      irc.log("Nickname '"..current_nick.."' is already in use")
      if #irc.suffixes > 0 then
        irc.log("Trying an alternative nick suffix")
        if current_nick == irc.nick then current_nick = current_nick..irc.suffixes[1]
        else
          for i,v in pairs(irc.suffixes) do
            if current_nick == irc.nick..v then 
              if i < #irc.suffixes then current_nick = irc.nick..irc.suffixes[i+1]
              else current_nick = irc.nick end
            end
          end
        end
        irc.log("New nickname is: '"..current_nick.."'")
        on_connect(c)
      else
        irc.log("Disconnecting to try again in ~"..irc.reconnect_time.."s")
        c:close()
      end
    elseif line:find(" PRIVMSG ") then -- Channel message
      local user,name,ip,chan,msg = line:match(user_match.."PRIVMSG%s(%S-)%s:(%C+)")
      if chan == current_nick then chan = user end -- return message goes back to user
      if msg~=nil then
        irc.log(user.."("..name..") in "..chan.." sent '"..msg.."'")
        if msg:sub(1,1) == irc.actions_char then
          local cmd = msg:sub(2)
          if cmd == 'help' then -- assumed not in actions so check first
            irc.log("Identified a command: 'help'")
            send_msg_to_channel(chan, action_help, irc.actions_usenotice)
          elseif irc.actions[cmd] == nil then
            irc.log("Identified a command: '"..cmd.."' (not a command)")
            send_msg_to_channel(chan, "No such command! "..action_help, irc.actions_usenotice)
          else
            irc.log("Identified a command: '"..cmd.."'")
            if type(irc.actions[cmd])=="string" then send_msg_to_channel(chan,irc.actions[cmd], irc.actions_usenotice)
            else send_msg_to_channel(chan,irc.actions[cmd](user), irc.actions_usenotice) end
          end
        end
        for k,v in pairs(irc.responses) do 
          if msg:match(k)~=nil then
            irc.log("'"..msg.."' matches response pattern '"..k.."'")
            send_msg_to_channel(chan,v(user), false)
          end 
        end
      end
    elseif line:find(" JOIN ") then
      local user,name,ip,chan=line:match(user_match.."JOIN%s([%S]+)")
      irc.log(user.."("..name..") joined channel "..chan)
    elseif line:find(" QUIT ") then
      local user,name,ip,reason=line:match(user_match.."QUIT%s([%S]+)")
      irc.log(user.."("..name..") quit due to "..reason)
    elseif line:find(" PART ") then
      local user,name,ip,chan,reason=line:match(user_match.."PART%s([%S]+)%s([%S]+)")
      irc.log(user.."("..name..") left "..chan.." due to "..reason)
    elseif line:find(" NICK ") then
      local user,name,ip,newuser = line:match(user_match.."NICK%s:([%S]+)")
      irc.log(name.." changed nick from '"..user.."' to '"..newuser.."'")
    elseif line:find(" KICK ") then
      irc.log("KICK")
    elseif line:find(" ERROR ") then
      irc.log("ERROR")
    elseif line:find(" NOTICE ") then
      local server,msg = line:match(":(%C+)%sNOTICE%s(%C+)")
      irc.log("NOTICE: "..server.." says: '"..msg.."'")
    else
     -- Unhandled server message
    end
  end -- end of loop through lines
end

function send_msg_to_channel(chan, msg, use_notice)
  irc.log("Message '"..msg.."' sent to "..chan)
  if use_notice then irc_connection:send("NOTICE "..chan.." :"..msg.."\r\n")
  else irc_connection:send("PRIVMSG "..chan.." :"..msg.."\r\n") end
end

local function connect_to_irc_if_have_wifi_and_not_connected()
  if wifi.sta.status()~=5 then
    irc.log("Waiting for wifi connection before connecting to server")
  elseif connected == false then 
    irc.log("Connecting to IRC server")
    irc_connection = net.createConnection(net.TCP, 0) -- no SSL
    irc_connection:on("receive", on_receive)
    irc_connection:on("connection", on_connect)
    irc_connection:on("disconnection",on_disconnect)
    irc_connection:connect(irc.port,irc.server) -- if network is setup upon loading this file
  end
end
connect_to_irc_if_have_wifi_and_not_connected()
tmr.alarm(irc.alarm_tmr, irc.reconnect_time*1000, 1, connect_to_irc_if_have_wifi_and_not_connected)
