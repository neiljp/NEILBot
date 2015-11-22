# nodemcu_lua_ircbot

An IRC bot for nodemcu, the lua firmware for ESP8266.

- `ircbot.lua` : Contains the core functional code
- `config_ircbot.lua` : All the configuration is available here

Other than setting obvious things like the bot *nick*, which *channels* to join
and which *server* (and *port*) to connect to, the configuration allows:

* specification of nick suffixes, to allow for reconnection
* customisation to fit with other modules (tmr number, logging options) 
* bot commands (which can be listed and extended subject to memory constraints)
* responses, matching a pattern (extended subject to memory constraints)

When compiled, the code should fit easily in the ESP8266 RAM/flash. It has been
tested with an '01' module, but there shouldn't be a problem with others.

If you find this useful, please let me know at my public github email address,
github_neiljp@kepier.clara.net.
