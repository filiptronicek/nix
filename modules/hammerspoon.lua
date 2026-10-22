-- Caps Lock is mapped to these modifiers by Karabiner.
local hyper = { "cmd", "alt", "ctrl", "shift" }

hs.menuIcon(false)
hs.window.animationDuration = 0

-- Physical Czech number-row keys (2–0), independent of layout key names.
local uppercaseAccents = {
  [19] = "Ě", [20] = "Š", [21] = "Č",
  [23] = "Ř", [22] = "Ž", [26] = "Ý",
  [28] = "Á", [25] = "Í", [29] = "É",
}
for keycode, character in pairs(uppercaseAccents) do
  hs.hotkey.bind(hyper, keycode, function()
    hs.eventtap.keyStrokes(character)
  end)
end

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

hs.hotkey.bind(hyper, "r", function()
  hs.urlevent.openURL("cleanshot://capture-previous-area")
end)

hs.hotkey.bind(hyper, "s", function()
  hs.urlevent.openURL("cleanshot://capture-area")
end)
