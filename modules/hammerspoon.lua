-- Caps Lock is mapped to these modifiers by Karabiner.
local hyper = { "cmd", "alt", "ctrl", "shift" }

hs.menuIcon(false)
hs.window.animationDuration = 0

hs.hotkey.bind(hyper, "c", function()
  local win = hs.window.focusedWindow()
  if win then
    win:centerOnScreen()
  end
end)

hs.hotkey.bind(hyper, "m", function()
  local win = hs.window.focusedWindow()
  if win then
    win:maximize()
  end
end)

hs.hotkey.bind(hyper, "n", function()
  local win = hs.window.focusedWindow()
  if win and win:screen() then
    win:moveToScreen(win:screen():next())
  end
end)

hs.hotkey.bind(hyper, "i", function()
  hs.application.launchOrFocusByBundleID("com.apple.systempreferences")
end)

hs.hotkey.bind(hyper, "l", function()
  hs.caffeinate.lockScreen()
end)
