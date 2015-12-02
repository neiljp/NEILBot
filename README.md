# NEILBot (Neil's ESP8266 IRC Lua Bot)

An IRC bot for NodeMCU, the Lua firmware for ESP8266.

If you use this and particularly if you find it useful, I would appreciate an
email to my public github email address, github_neiljp@kepier.clara.net.
Contributions are welcome, including perhaps some sample
configurations/customisations!

When compiled, the code should fit easily in the ESP8266 RAM/flash. It has been
tested with an '01' module, but there shouldn't be a problem with using others.
Of course you will need to set up the network connection first, before using
`dofile("ircbot.lc")` or equivalent in either `init.lua` or another file called
from it.

## Design

The code is purposely split into a 'fixed' core file and a configuration file,
partly for separation of concerns, but also to allow reconfiguration to only
require upload of a small(er) separate file. These files are currently:

- `ircbot.lua` : The core functional code
- `config_ircbot.lua` : The base configuration and extra customisation code

I aim to keep the code relatively lean, responsive and easy to understand,
though this can be challenging at times! 

## Features & Configuration

Other than setting obvious things like the bot *nick*, which *channels* to join
and which *server* (and *port*) to connect to, the configuration allows:

* specification of nick suffixes, to allow for reconnection
* customisation to fit with other modules (tmr number, logging options) 
* bot commands (prefixed, listable and easily extended, subject to memory constraints)
* arbitrary responses, matching a pattern (also easily extended subject to memory constraints)

## History

What is now NEILBot was originally developed to allow easy online interaction
with a ESP8266-based project during a weekend hackathon at [57North
Hacklab](https://57north.org.uk). Other Lua ESP8266 IRC-bot code
existed/exists, but appeared customised, limited, or primarily proof of
concept, though all certainly acted as inspiration that such a thing was
possible! Developing a separate one was also a useful learning experience.

The code remains under fairly heavy development as of Dec 2015, and the
configuration file format is subject to change, though variations between
versions should be fairly easy to track. Let me know if you start actively
using it, and I might not alter things quite so rapidly ;)

## Name

The project originally had a rather generic name, before moving to one based on
a simpler short acronym, then finally taking a little artistic licence to
switch the order of two words and arrive at a recursive-style name. Which words
were rearranged is left as an exercise for the reader ;)
