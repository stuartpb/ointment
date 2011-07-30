------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------
local iup = require "iuplua"

--Local version comparison module
local vercmp = require "vercmp"

if vercmp.lt (iup._VERSION,"3.4") then
  iup.Message("Insufficient version",
    "Magic Ointment requires at least IUP 3.4 (earlier versions tend to crash).")
  os.exit()
end

--Platform-specific functionality.
local platform; do
  local driver = iup.GetGlobal"DRIVER"
  if driver == "Win32" then
    platform = require "mo-windows"
  else
    iup.Message("Platform not supported",
      "Magic Ointment only comes with Windows support.")
    os.exit()
  end
end

------------------------------------------------------------------------------
-- Globals or what have you
------------------------------------------------------------------------------
local ondc={}
local onrc={}

------------------------------------------------------------------------------
-- Local functions
------------------------------------------------------------------------------

--Toggles the value at index k of table t.
local function tog_tk(t,k)
  return function()
    t[k] = not t[k]
  end
end

------------------------------------------------------------------------------
-- Interface stuff
------------------------------------------------------------------------------
local iup = require "iuplua"

local voltorb = iup.image{
    width = 16,
    height = 16,
    pixels = {
      11,11,11,11, 0, 0, 0, 0, 0, 0, 0, 0,11,11,11,11,
      11,11, 0, 0, 4, 4, 4, 3, 3, 4, 4, 3, 5, 5,11,11,
      11, 0, 4, 4, 4, 3, 3, 4, 4, 4, 3, 3, 4, 3, 5,11,
       0, 4, 4, 3, 3, 4, 4, 4, 3, 3, 4, 4, 4, 3, 3, 5,
       0, 3, 3, 4, 4, 4, 3, 3, 4, 4, 4, 3, 3, 4, 4, 5,
       5, 3, 4, 4, 3, 3, 4, 4, 4, 3, 3, 4, 4, 4, 4, 5,
       5, 2, 3, 3, 4, 4, 4, 3, 3, 4, 4, 4, 4, 4, 1, 5,
       5, 2, 1, 1, 4, 3, 3, 4, 4, 4, 4, 4, 0, 0, 1, 5,
      11, 5, 1, 1, 3, 2, 2, 1, 0, 1, 0, 1, 0, 0, 5,11,
       5,10, 5, 1, 3, 2, 2, 1, 0, 1, 0, 1, 0, 5,10, 5,
       5, 8,10, 9, 5, 5, 5, 5, 5, 5, 5, 5, 9,10, 7, 5,
       5, 8, 7, 7,10,10, 9,10,10,10,10, 9, 7, 6, 7, 5,
       5, 7, 7, 7, 9, 8, 8, 7, 6, 7, 6, 7, 6, 6, 6, 5,
      11, 5, 7, 7, 9, 8, 8, 7, 6, 7, 6, 7, 6, 6, 5,11,
      11,11, 5, 6, 7, 7, 7, 7, 7, 7, 7, 7, 5, 5,11,11,
      11,11,11,11, 5, 5, 5, 5, 5, 5, 5, 5,11,11,11,11,
    },
    colors = {
      "128 32 32",
      "152 56 56",
      "207 143 143",
      "247 183 183",
      "248 228 228",
      "48 48 48",
      "104 104 80",
      "128 128 104",
      "192 192 176",
      "232 232 216",
      "248 248 248",
      "BGCOLOR",
    }
  }

local dclabel=iup.label{title="When headphones are disconnected:"}
local mutedc=iup.toggle{title="Mute volume", action=tog_tk(ondc,"mute")}
local pausedc=iup.toggle{title="Pause media", action=tog_tk(ondc,"pause")}
local rclabel=iup.label{title="When headphones are reinserted:"}
local unmuterc=iup.toggle{title="Unmute volume", action=tog_tk(onrc,"unmute")}
local playrc=iup.toggle{title="Play media", action=tog_tk(onrc,"play")}

local function indent(px,control)
  return iup.hbox{iup.fill{rastersize=px},control}
end

local hider=iup.button{title="Hide the ointment",expand="yes"}

local dg = iup.dialog{
  title="Magic Ointment", icon=voltorb,
  tray = "YES", traytip =  "Magic Ointment", trayimage = voltorb;
  iup.vbox{ngap="3x3", nmargin="3x3";
    dclabel,
    indent(20,mutedc),
    indent(20,pausedc),
    rclabel,
    indent(20,unmuterc),
    indent(20,playrc),
    hider, iup.button{title="Pause",action=platform.pause}
  }
}

function hider:action()
  dg.hidetaskbar = "YES"
end

function dg:show_cb(state)
  if state==iup.SHOW then
    --Register our window handle with the Windows stuff
    --TODO: Send self.wid to platform instead?
    platform.reg(self)
  elseif state==iup.HIDE then
    --be a responsible citizen and don't pollute the tray
    self.tray = "NO"
  end
end

function dg:map_cb()
end

function dg:trayclick_cb(b, press, dclick)
  --if left or right clicked
  if (b == 1 or b == 3) and press then
    item_show = iup.item {title = "Show", action = function() dg:show() end}
    item_exit = iup.item {title = "Exit", action = function() dg:hide() end}
    menu = iup.menu{item_show, item_exit}
    menu:popup(iup.MOUSEPOS, iup.MOUSEPOS)
  end
  return iup.DEFAULT
end

------------------------------------------------------------------------------
-- Execution
------------------------------------------------------------------------------

--Show the dialog
dg:show()

--Start the main loop if it's not already running
if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end
