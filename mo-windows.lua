------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------
local alien = require "alien"

------------------------------------------------------------------------------
-- FFI definitions
------------------------------------------------------------------------------
local user32 = alien.load 'user32.dll'
user32.SetWindowLongA:types{abi="stdcall", ret="long";
  "pointer", --HWND hWnd
  "int", --int nIndex
  "long", --LONG dwNewLong
}
--todo: RegisterDeviceNotification (currently nothing happens)
--      CallWindowProc (for deferring back to IUP's wndproc)
--      PostMessage (for sending the Pause message)

-- Constants
local GWLP_WNDPROC = -4
local WM_DEVICECHANGE = 0x219
local LONG_PTR = "long"
local UINT = "int" --should be "uint" but Alien 0.41 doesn't have it
local UINT_PTR = UINT

------------------------------------------------------------------------------
-- Device stuff
------------------------------------------------------------------------------

local function make_wndproc(f)
  return alien.callback(f,LONG_PTR,--LRESULT
    "pointer", --HWND hwnd
    UINT, --UINT uMsg
    UINT_PTR, --WPARAM wParam
    LONG_PTR --LPARAM lParam
  )
end

local dchook = make_wndproc(
  function (hWnd, uMsg, wParam, lParam)
    if uMsg == WM_DEVICECHANGE then
      iup.Message("WM_DEVICECHANGE",
        string.format("0x%X",wParam))
    end
  end)

------------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------------
local win={}

function win.reg(dlg)
  --TODO: Register for device change events

  --Override the MO dialog's WNDPROC
  user32.SetWindowLongA(
    dlg.hwnd, --for the MO dialog
    GWLP_WNDPROC, --set the WNDPROC
    dchook) --to the hook specified above
end

return win
