------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------
local iup = require "iuplua"

--Magic Ointment modules
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
      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
      6, 6, 6, 6, 6, 1, 1, 1, 1, 1, 1, 6, 6, 6, 6, 6,
      6, 6, 6, 1, 1, 3, 4, 4, 4, 4, 3, 1, 1, 6, 6, 6,
      6, 6, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 6, 6,
      6, 6, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 6, 6,
      6, 1, 3, 1, 4, 4, 4, 4, 4, 4, 4, 4, 1, 3, 1, 6,
      6, 1, 4, 5, 1, 4, 1, 4, 4, 1, 4, 1, 5, 4, 1, 6,
      6, 1, 4, 5, 5, 1, 1, 4, 4, 1, 1, 5, 5, 4, 1, 6,
      6, 1, 4, 5, 5, 1, 5, 4, 4, 5, 1, 5, 5, 4, 1, 6,
      6, 1, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 1, 6,
      6, 1, 2, 5, 5, 4, 4, 4, 4, 4, 4, 5, 5, 2, 1, 6,
      6, 6, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 6, 6,
      6, 6, 1, 1, 5, 5, 5, 5, 5, 5, 5, 5, 1, 1, 6, 6,
      6, 6, 6, 1, 1, 2, 5, 5, 5, 5, 2, 1, 1, 6, 6, 6,
      6, 6, 6, 6, 6, 1, 1, 1, 1, 1, 1, 6, 6, 6, 6, 6,
      6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
    },
    colors = {
      "0 0 0",
      "64 64 64",
      "40 160 104",
      "160 88 80",
      "224 112 80",
      "208 232 224",
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
    hider
  }
}

function hider:action()
  dg.hidetaskbar = "YES"
end

function dg:show_cb(state)
  if state==iup.SHOW then
    --Register our window handle with the Windows stuff
    --TODO: Send self.wid to platform instead?
    --BUG: https://github.com/stuartpb/ointment/issues/#issue/1
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
