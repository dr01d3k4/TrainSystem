wait 1
players = game\GetService "Players"
import insert from table
localSystemScript = game\GetService("ServerStorage").LocalSystem

defaultValuesList = 
	TrainName: {"String", "Unnamed Train"}
	Speed: {"Number", 0}
	TargetSpeed: {"Number", 0}
	AccelerationRate: {"Number", 2}
	BrakeRate: {"Number", 4}
	EmergencyBrakeRate: {"Number", 8}
	MaxSpeed: {"Number", 100}
	EmergencyBrake: {"Bool", false}
	Throttle: {"Number", 0}
	Acceleration: {"Number", 0}


import abs, sqrt from math
signum = (x) -> 0 if x == 0 else x / abs x


weldModel = (model, previous) ->
	for obj in *model\GetChildren!
		if obj\IsA "BasePart"
			if not previous
				previous = obj

			continue if obj == prev

			with Instance.new "Weld"
				.Part0 = previous
				.Part1 = obj
				.C0 = previous.CFrame\inverse!
				.C1 = obj.CFrame\inverse!
				.Parent = previous

			unless obj\IsA("Seat") or obj\IsA("VehicleSeat")
				previous = obj

		elseif obj\IsA "Model"
			weldModel obj, previous


setModelAnchored = (model, anchor) ->
	for obj in *model\GetChildren!
		if obj\IsA "BasePart"
			obj.Anchored = anchor
		elseif obj\IsA "Model"
			setModelAnchored obj, anchor


class Train
	new: (model) =>
		@model = model
		@controlModel = model.Control

	getEngines: (model = @controlModel) =>
		for obj in *model\GetChildren!
			if obj\IsA "Model"
				@getEngines obj
			elseif obj\IsA("BasePart") and obj.Name == "Engine"
				insert @engines, obj

	init: =>
		setModelAnchored @model, true
		@seat = @controlModel.TrainSeat
		@engines = { }
		@getEngines!
		
		for engine in *@engines
			bodyVelocities = { }
			for obj in *engine\GetChildren!
				if obj\IsA "BodyVelocity"
					insert bodyVelocities, obj
					break

			bodyVelocity\Destroy! for bodyVelocity in *bodyVelocities

			with Instance.new "BodyVelocity", engine
				.velocity = Vector3.new 0, 0, 0
				.maxForce = Vector3.new 50000, 50000, 50000
				.P = 50000

		@values = @controlModel\findFirstChild("Values") or with Instance.new "Model", @controlModel do .Name = "Values"

		for valueName, defaultValue in pairs defaultValuesList
			value = @values\findFirstChild valueName
			if not value
				with Instance.new defaultValue[1].."Value", @values
					.Name = valueName
					.Value = defaultValue[2]
			else
				if not value\IsA defaultValue[1].."Value"
					value.Name = value.Name.."_MUST_BE_"..defaultValue[1].."_NOT_"..(value.ClassName\match("^(.-)Value$") or value.ClassName)
					with Instance.new defaultValue[1].."Value", @values
						.Name = valueName
						.Value = defaultValue[2]

		@seat.ChildAdded\connect (obj) ->
			if obj\IsA("Weld")
				torso = obj.Part1
				character = torso.Parent
				@player = players\findFirstChild character.Name
				trainObjectValue = with Instance.new "ObjectValue", @player.PlayerGui
					.Name = "TrainModel"
					.Value = @model
				localSystemScript\Clone!.Parent = @player.PlayerGui
				@values.TargetSpeed.Value = 0
				@values.EmergencyBrake.Value = false
				@values.Throttle.Value = 0


		@seat.ChildRemoved\connect (obj) ->
			pcall ->
				for obj in *@player.PlayerGui\GetChildren!
					if obj.Name == localSystemScript.Name or obj.Name == "TrainGui" or obj.Name == "TrainModel"
						obj\Destroy!
			@player = nil
			@values.TargetSpeed.Value = 0
			@values.EmergencyBrake.Value = true
			@values.Throttle.Value = 0

		weldModel @model
		setModelAnchored @model, false

	run: =>
		coroutine.resume coroutine.create ->
			previousTime = tick!
			deltaTime = 0
			while true
				wait 0.1
				deltaTime = tick! - previousTime
				previousTime = tick!

				targetSpeed = (@values.MaxSpeed.Value / 100) * @values.Throttle.Value
				@values.TargetSpeed.Value = targetSpeed

				vel = @seat.Velocity
				currentSpeed = (vel.x * abs vel.x) + (vel.z * abs vel.z)
				if currentSpeed != 0
					sign = signum currentSpeed
					currentSpeed = sign * sqrt abs currentSpeed


				speedDifference = targetSpeed - currentSpeed

				accel = @values.AccelerationRate.Value
				if abs(speedDifference) < 0.1
					accel = 0

				elseif (currentSpeed > 0.1 and targetSpeed < currentSpeed) or (currentSpeed < 0.1 and targetSpeed > currentSpeed)
					accel = @values.BrakeRate.Value

				elseif @values.EmergencyBrake.Value
					accel = @values.EmergencyBrakeRate.Value
					targetSpeed = 0
					@values.TargetSpeed.Value = targetSpeed
					@values.Throttle.Value = 0

				else
					accelPart = accel * 0.4
					throttleChanges = ((accel - accelPart) / 100) * abs @values.Throttle.Value
					accel = accelPart + throttleChanges

				sig = signum speedDifference
				accel *= sig
				@values.Acceleration.Value = accel

				if abs(speedDifference) > 1
					currentSpeed += accel * deltaTime
				else
					currentSpeed = @values.TargetSpeed.Value

				if abs(currentSpeed) < 0.1
					currentSpeed = 0.1 * signum currentSpeed

				if abs(currentSpeed) > @values.MaxSpeed.Value
					currentSpeed = @values.MaxSpeed.Value * signum currentSpeed

				@values.Speed.Value = currentSpeed
				for engine in *@engines
					engine.BodyVelocity.velocity = engine.CFrame.lookVector * @values.Speed.Value


findAllTrainsIn = (searchIn) ->
	trains = { } 
	for obj in *searchIn\GetChildren!
		if obj\findFirstChild("Control") and obj.Control\findFirstChild("Engine") and obj.Control\findFirstChild("TrainSeat")
			insert trains, Train obj
		elseif obj\IsA "Model"
			findAllTrainsIn obj
	return trains


trains = findAllTrainsIn workspace
for train in *trains
	train\init! 
	train\run!