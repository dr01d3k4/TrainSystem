wait 1
player = game.Players.LocalPlayer
playerGui = player.PlayerGui
trainModel = playerGui.TrainModel.Value
controlModel = trainModel.Control
values = controlModel.Values

rgbToColor3 = (r, g, b) -> Color3.new r / 255, g / 255, b / 255

units = "mph"

buildGui = ->
	backgroundWidth = 0.3
	backgroundHeight = 0.45

	screen = with Instance.new "ScreenGui"
		.Name = "TrainGui"

	background = with Instance.new "Frame", screen
		.Name = "BackgroundFrame"
		.Position = UDim2.new 1 - backgroundWidth, 0, 1 - backgroundHeight, 0
		.Size = UDim2.new backgroundWidth, 0, backgroundHeight, 0
		.BackgroundTransparency = 0.4
		.BackgroundColor3 = rgbToColor3 64, 64, 64

	titleHeight = 0.15
	titleLabel = with Instance.new "TextLabel", background
		.Name = "TitleLabel"
		.BackgroundTransparency = 1
		.Position = UDim2.new 0, 0, 0, 0
		.Size = UDim2.new 1, 0, titleHeight, 0
		.Font = "SourceSansBold"
		.FontSize = "Size48"
		.Text = values.TrainName.Value
		.TextColor3 = rgbToColor3 255, 255, 255
		.TextScaled = true

	inset = 0.01
	textHeight = 0.1

	speedLabel = with Instance.new "TextLabel", background
		.Name = "SpeedLabel"
		.BackgroundTransparency = 1
		.Position = UDim2.new inset, 0, titleHeight, 0
		.Size = UDim2.new 0.5 - (inset * 2), 0, textHeight, 0
		.Font = "SourceSansBold"
		.FontSize = "Size48"
		.Text = "Speed: 0 "..units.."^-1"
		.TextColor3 = rgbToColor3 255, 255, 255
		.TextScaled = true
		.TextXAlignment = "Left"

	throttleLabel = with speedLabel\Clone!
		.Parent = background
		.Name = "ThrottleLabel"
		.Position = UDim2.new inset, 0, titleHeight + textHeight, 0
		.Text = "Throttle: 0%"

	accelerationLabel = with speedLabel\Clone!
		.Parent = background
		.Name = "AccelerationLabel"
		.Position = UDim2.new inset, 0, titleHeight + (2 * textHeight), 0
		.Text = "Accel: 0 "..units.."^-2"

	return screen


gui = buildGui!
gui.Parent = playerGui

mouse = player\GetMouse!

keyStates =
	throttleUp: false
	throttleDown: false

keyButtons =
	throttleUp: {119, 17} -- w, up arrow
	throttleDown: {115, 18} -- s, down arrow

setKey = (keyCode, bool) ->
	for buttonName, codes in pairs keyButtons
		for code in *codes
			if code == keyCode
				keyStates[buttonName] = bool
				return

mouse.KeyDown\connect (key) ->
	setKey key\byte!, true

mouse.KeyUp\connect (key) ->
	setKey key\byte!, false

previousTime = tick!
cumulativeTime = 0
keyRepeatDelay = 0.08

while true
	wait 0.1
	deltaTime = tick! - previousTime
	previousTime = tick!
	cumulativeTime += deltaTime

	while cumulativeTime >= keyRepeatDelay
		newThrottle = values.Throttle.Value
		if keyStates.throttleUp
			newThrottle += 1
		if keyStates.throttleDown
			newThrottle -= 1

		if newThrottle < -100
			newThrottle = -100
		if newThrottle > 100
			newThrottle = 100

		values.Throttle.Value = newThrottle
		cumulativeTime -= keyRepeatDelay

	with gui.BackgroundFrame
		.SpeedLabel.Text = "Speed: %i %s^-1"\format values.Speed.Value, units
		.ThrottleLabel.Text = "Throttle: %i%%"\format values.Throttle.Value
		.AccelerationLabel.Text = "Accel: %.2f %s^-2"\format values.Acceleration.Value, units