------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------
local alien = require "alien"

------------------------------------------------------------------------------
-- FFI definitions
------------------------------------------------------------------------------
local user32 = alien.load 'user32.dll'

-- Types
local DWORD = "ulong"
local LONG = "long"
local LONG_PTR = LONG --64-bit sensitive
local LPARAM = LONG_PTR
local LRESULT = LONG_PTR
local UINT = "uint"
local UINT_PTR = UINT --64-bit sensitive
local WPARAM = UINT_PTR
local LPVOID = "pointer"
local PVOID = "pointer"
local HANDLE = PVOID
local HWND = HANDLE
 --of course this is NOWHERE on the MSDN and I had to open winuser.h myself
local HDEVNOTIFY = PVOID

-- Constants
local GWLP_WNDPROC = -4
local WM_DEVICECHANGE = 0x219
local DEVICE_NOTIFY_WINDOW_HANDLE = 0x00000000
local DEVICE_NOTIFY_ALL_INTERFACE_CLASSES = 0x00000004

-- Structs
--GUID
--DEV_BROADCAST_DEVICEINTERFACE

--  Note: For these to work, there's going to be extra work involved
--  (because Alien doesn't support structs this fancy).
--  It's probably going to end up being better
--  to write high-level functions that manipulate
--  buffers of the correct size.

-- Functions
user32.SetWindowLongA:types{abi="stdcall", ret=LONG;
  HWND, --HWND hWnd
  "int", --int nIndex
  LONG --LONG dwNewLong
}
user32.CallWindowProcA:types{abi="stdcall", ret=LRESULT;
  "pointer", --WNDPROC lpPrevWndFunc
  HWND, --HWND hwnd
  UINT, --UINT uMsg
  WPARAM, --WPARAM wParam
  LPARAM --LPARAM lParam
}
user32.RegisterDeviceNotificationA:types{abi="stdcall", ret=HDEVNOTIFY;
  HANDLE, --HANDLE hRecipient
  LPVOID, --LPVOID NotificationFilter
  DWORD --DWORD Flags
}
--todo: PostMessage (for sending the Pause message)


------------------------------------------------------------------------------
-- Device stuff
------------------------------------------------------------------------------

local function make_wndproc(f)
  return alien.callback(f,LRESULT,
    HWND, --HWND hwnd
    UINT, --UINT uMsg
    WPARAM, --WPARAM wParam
    LPARAM --LPARAM lParam
  )
end

--The callback this replaced.
local prevWndProc

--Disconnection Hook, a WndProc
local dchook
dchook = make_wndproc(
  function (hWnd, uMsg, wParam, lParam)
    --If this is a DEVICECHANGE message,
    --do tell
    if uMsg == WM_DEVICECHANGE then
      iup.Message("WM_DEVICECHANGE",
        string.format("0x%X",wParam))

    --Otherwise, defer to the WndProc this replaced
    else
      user32.CallWindowProc(prevWndProc,
        hWnd, uMsg, wParam, lParam)
    end
  end)

------------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------------
local win={}

function win.reg(dlg)
  --TODO: Register for device change events
  --iup.Message("Wait a minute-","Wait- wait a minute")

  --Override the MO dialog's WNDPROC
  prevWndProc = user32.SetWindowLongA(
    dlg.hwnd, --for the MO dialog
    GWLP_WNDPROC, --set the WNDPROC
    dchook) --to the hook specified above
end

return win
