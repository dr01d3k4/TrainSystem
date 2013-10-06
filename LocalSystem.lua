wait(1)
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local trainModel = playerGui.TrainModel.Value
local controlModel = trainModel.Control
local values = controlModel.Values
local rgbToColor3
rgbToColor3 = function(r, g, b)
  return Color3.new(r / 255, g / 255, b / 255)
end
local units = "mph"
local buildGui
buildGui = function()
  local backgroundWidth = 0.3
  local backgroundHeight = 0.45
  local screen
  do
    local _with_0 = Instance.new("ScreenGui")
    _with_0.Name = "TrainGui"
    screen = _with_0
  end
  local background
  do
    local _with_0 = Instance.new("Frame", screen)
    _with_0.Name = "BackgroundFrame"
    _with_0.Position = UDim2.new(1 - backgroundWidth, 0, 1 - backgroundHeight, 0)
    _with_0.Size = UDim2.new(backgroundWidth, 0, backgroundHeight, 0)
    _with_0.BackgroundTransparency = 0.4
    _with_0.BackgroundColor3 = rgbToColor3(64, 64, 64)
    background = _with_0
  end
  local titleHeight = 0.15
  local titleLabel
  do
    local _with_0 = Instance.new("TextLabel", background)
    _with_0.Name = "TitleLabel"
    _with_0.BackgroundTransparency = 1
    _with_0.Position = UDim2.new(0, 0, 0, 0)
    _with_0.Size = UDim2.new(1, 0, titleHeight, 0)
    _with_0.Font = "SourceSansBold"
    _with_0.FontSize = "Size48"
    _with_0.Text = values.TrainName.Value
    _with_0.TextColor3 = rgbToColor3(255, 255, 255)
    _with_0.TextScaled = true
    titleLabel = _with_0
  end
  local inset = 0.01
  local textHeight = 0.1
  local speedLabel
  do
    local _with_0 = Instance.new("TextLabel", background)
    _with_0.Name = "SpeedLabel"
    _with_0.BackgroundTransparency = 1
    _with_0.Position = UDim2.new(inset, 0, titleHeight, 0)
    _with_0.Size = UDim2.new(0.5 - (inset * 2), 0, textHeight, 0)
    _with_0.Font = "SourceSansBold"
    _with_0.FontSize = "Size48"
    _with_0.Text = "Speed: 0 " .. units .. "^-1"
    _with_0.TextColor3 = rgbToColor3(255, 255, 255)
    _with_0.TextScaled = true
    _with_0.TextXAlignment = "Left"
    speedLabel = _with_0
  end
  local throttleLabel
  do
    local _with_0 = speedLabel:Clone()
    _with_0.Parent = background
    _with_0.Name = "ThrottleLabel"
    _with_0.Position = UDim2.new(inset, 0, titleHeight + textHeight, 0)
    _with_0.Text = "Throttle: 0%"
    throttleLabel = _with_0
  end
  local accelerationLabel
  do
    local _with_0 = speedLabel:Clone()
    _with_0.Parent = background
    _with_0.Name = "AccelerationLabel"
    _with_0.Position = UDim2.new(inset, 0, titleHeight + (2 * textHeight), 0)
    _with_0.Text = "Accel: 0 " .. units .. "^-2"
    accelerationLabel = _with_0
  end
  return screen
end
local gui = buildGui()
gui.Parent = playerGui
local mouse = player:GetMouse()
local keyStates = {
  throttleUp = false,
  throttleDown = false
}
local keyButtons = {
  throttleUp = {
    119,
    17
  },
  throttleDown = {
    115,
    18
  }
}
local setKey
setKey = function(keyCode, bool)
  for buttonName, codes in pairs(keyButtons) do
    for _index_0 = 1, #codes do
      local code = codes[_index_0]
      if code == keyCode then
        keyStates[buttonName] = bool
        return 
      end
    end
  end
end
mouse.KeyDown:connect(function(key)
  return setKey(key:byte(), true)
end)
mouse.KeyUp:connect(function(key)
  return setKey(key:byte(), false)
end)
local previousTime = tick()
local cumulativeTime = 0
local keyRepeatDelay = 0.08
while true do
  wait(0.1)
  local deltaTime = tick() - previousTime
  previousTime = tick()
  cumulativeTime = cumulativeTime + deltaTime
  while cumulativeTime >= keyRepeatDelay do
    local newThrottle = values.Throttle.Value
    if keyStates.throttleUp then
      newThrottle = newThrottle + 1
    end
    if keyStates.throttleDown then
      newThrottle = newThrottle - 1
    end
    if newThrottle < -100 then
      newThrottle = -100
    end
    if newThrottle > 100 then
      newThrottle = 100
    end
    values.Throttle.Value = newThrottle
    cumulativeTime = cumulativeTime - keyRepeatDelay
  end
  do
    local _with_0 = gui.BackgroundFrame
    _with_0.SpeedLabel.Text = ("Speed: %i %s^-1"):format(values.Speed.Value, units)
    _with_0.ThrottleLabel.Text = ("Throttle: %i%%"):format(values.Throttle.Value)
    _with_0.AccelerationLabel.Text = ("Accel: %.2f %s^-2"):format(values.Acceleration.Value, units)
  end
end
