wait(1)
local players = game:GetService("Players")
local insert
do
  local _obj_0 = table
  insert = _obj_0.insert
end
local localSystemScript = game:GetService("ServerStorage").LocalSystem
local defaultValuesList = {
  TrainName = {
    "String",
    "Unnamed Train"
  },
  Speed = {
    "Number",
    0
  },
  TargetSpeed = {
    "Number",
    0
  },
  AccelerationRate = {
    "Number",
    2
  },
  BrakeRate = {
    "Number",
    4
  },
  EmergencyBrakeRate = {
    "Number",
    8
  },
  MaxSpeed = {
    "Number",
    100
  },
  EmergencyBrake = {
    "Bool",
    false
  },
  Throttle = {
    "Number",
    0
  },
  Acceleration = {
    "Number",
    0
  }
}
local abs, sqrt
do
  local _obj_0 = math
  abs, sqrt = _obj_0.abs, _obj_0.sqrt
end
local signum
signum = function(x)
  if x == 0 then
    return 0
  else
    return x / abs(x)
  end
end
local weldModel
weldModel = function(model, previous)
  local _list_0 = model:GetChildren()
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local obj = _list_0[_index_0]
      if obj:IsA("BasePart") then
        if not previous then
          previous = obj
        end
        if obj == prev then
          _continue_0 = true
          break
        end
        do
          local _with_0 = Instance.new("Weld")
          _with_0.Part0 = previous
          _with_0.Part1 = obj
          _with_0.C0 = previous.CFrame:inverse()
          _with_0.C1 = obj.CFrame:inverse()
          _with_0.Parent = previous
        end
        if not (obj:IsA("Seat") or obj:IsA("VehicleSeat")) then
          previous = obj
        end
      elseif obj:IsA("Model") then
        weldModel(obj, previous)
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end
local setModelAnchored
setModelAnchored = function(model, anchor)
  local _list_0 = model:GetChildren()
  for _index_0 = 1, #_list_0 do
    local obj = _list_0[_index_0]
    if obj:IsA("BasePart") then
      obj.Anchored = anchor
    elseif obj:IsA("Model") then
      setModelAnchored(obj, anchor)
    end
  end
end
local Train
do
  local _base_0 = {
    getEngines = function(self, model)
      if model == nil then
        model = self.controlModel
      end
      local _list_0 = model:GetChildren()
      for _index_0 = 1, #_list_0 do
        local obj = _list_0[_index_0]
        if obj:IsA("Model") then
          self:getEngines(obj)
        elseif obj:IsA("BasePart") and obj.Name == "Engine" then
          insert(self.engines, obj)
        end
      end
    end,
    init = function(self)
      setModelAnchored(self.model, true)
      self.seat = self.controlModel.TrainSeat
      self.engines = { }
      self:getEngines()
      local _list_0 = self.engines
      for _index_0 = 1, #_list_0 do
        local engine = _list_0[_index_0]
        local bodyVelocities = { }
        local _list_1 = engine:GetChildren()
        for _index_1 = 1, #_list_1 do
          local obj = _list_1[_index_1]
          if obj:IsA("BodyVelocity") then
            insert(bodyVelocities, obj)
            break
          end
        end
        for _index_1 = 1, #bodyVelocities do
          local bodyVelocity = bodyVelocities[_index_1]
          bodyVelocity:Destroy()
        end
        do
          local _with_0 = Instance.new("BodyVelocity", engine)
          _with_0.velocity = Vector3.new(0, 0, 0)
          _with_0.maxForce = Vector3.new(50000, 50000, 50000)
          _with_0.P = 50000
        end
      end
      self.values = self.controlModel:findFirstChild("Values") or (function()
        do
          local _with_0 = Instance.new("Model", self.controlModel)
          _with_0.Name = "Values"
          return _with_0
        end
      end)()
      for valueName, defaultValue in pairs(defaultValuesList) do
        local value = self.values:findFirstChild(valueName)
        if not value then
          do
            local _with_0 = Instance.new(defaultValue[1] .. "Value", self.values)
            _with_0.Name = valueName
            _with_0.Value = defaultValue[2]
          end
        else
          if not value:IsA(defaultValue[1] .. "Value") then
            value.Name = value.Name .. "_MUST_BE_" .. defaultValue[1] .. "_NOT_" .. (value.ClassName:match("^(.-)Value$") or value.ClassName)
            do
              local _with_0 = Instance.new(defaultValue[1] .. "Value", self.values)
              _with_0.Name = valueName
              _with_0.Value = defaultValue[2]
            end
          end
        end
      end
      self.seat.ChildAdded:connect(function(obj)
        if obj:IsA("Weld") then
          local torso = obj.Part1
          local character = torso.Parent
          self.player = players:findFirstChild(character.Name)
          local trainObjectValue
          do
            local _with_0 = Instance.new("ObjectValue", self.player.PlayerGui)
            _with_0.Name = "TrainModel"
            _with_0.Value = self.model
            trainObjectValue = _with_0
          end
          localSystemScript:Clone().Parent = self.player.PlayerGui
          self.values.TargetSpeed.Value = 0
          self.values.EmergencyBrake.Value = false
          self.values.Throttle.Value = 0
        end
      end)
      self.seat.ChildRemoved:connect(function(obj)
        pcall(function()
          local _list_1 = self.player.PlayerGui:GetChildren()
          for _index_0 = 1, #_list_1 do
            obj = _list_1[_index_0]
            if obj.Name == localSystemScript.Name or obj.Name == "TrainGui" or obj.Name == "TrainModel" then
              obj:Destroy()
            end
          end
        end)
        self.player = nil
        self.values.TargetSpeed.Value = 0
        self.values.EmergencyBrake.Value = true
        self.values.Throttle.Value = 0
      end)
      weldModel(self.model)
      return setModelAnchored(self.model, false)
    end,
    run = function(self)
      return coroutine.resume(coroutine.create(function()
        local previousTime = tick()
        local deltaTime = 0
        while true do
          wait(0.1)
          deltaTime = tick() - previousTime
          previousTime = tick()
          local targetSpeed = (self.values.MaxSpeed.Value / 100) * self.values.Throttle.Value
          self.values.TargetSpeed.Value = targetSpeed
          local vel = self.seat.Velocity
          local currentSpeed = (vel.x * abs(vel.x)) + (vel.z * abs(vel.z))
          if currentSpeed ~= 0 then
            local sign = signum(currentSpeed)
            currentSpeed = sign * sqrt(abs(currentSpeed))
          end
          local speedDifference = targetSpeed - currentSpeed
          local accel = self.values.AccelerationRate.Value
          if abs(speedDifference) < 0.1 then
            accel = 0
          elseif (currentSpeed > 0.1 and targetSpeed < currentSpeed) or (currentSpeed < 0.1 and targetSpeed > currentSpeed) then
            accel = self.values.BrakeRate.Value
          elseif self.values.EmergencyBrake.Value then
            accel = self.values.EmergencyBrakeRate.Value
            targetSpeed = 0
            self.values.TargetSpeed.Value = targetSpeed
            self.values.Throttle.Value = 0
          else
            local accelPart = accel * 0.4
            local throttleChanges = ((accel - accelPart) / 100) * abs(self.values.Throttle.Value)
            accel = accelPart + throttleChanges
          end
          local sig = signum(speedDifference)
          accel = accel * sig
          self.values.Acceleration.Value = accel
          if abs(speedDifference) > 1 then
            currentSpeed = currentSpeed + (accel * deltaTime)
          else
            currentSpeed = self.values.TargetSpeed.Value
          end
          if abs(currentSpeed) < 0.1 then
            currentSpeed = 0.1 * signum(currentSpeed)
          end
          if abs(currentSpeed) > self.values.MaxSpeed.Value then
            currentSpeed = self.values.MaxSpeed.Value * signum(currentSpeed)
          end
          self.values.Speed.Value = currentSpeed
          local _list_0 = self.engines
          for _index_0 = 1, #_list_0 do
            local engine = _list_0[_index_0]
            engine.BodyVelocity.velocity = engine.CFrame.lookVector * self.values.Speed.Value
          end
        end
      end))
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, model)
      self.model = model
      self.controlModel = model.Control
    end,
    __base = _base_0,
    __name = "Train"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Train = _class_0
end
local findAllTrainsIn
findAllTrainsIn = function(searchIn)
  local trains = { }
  local _list_0 = searchIn:GetChildren()
  for _index_0 = 1, #_list_0 do
    local obj = _list_0[_index_0]
    if obj:findFirstChild("Control") and obj.Control:findFirstChild("Engine") and obj.Control:findFirstChild("TrainSeat") then
      insert(trains, Train(obj))
    elseif obj:IsA("Model") then
      findAllTrainsIn(obj)
    end
  end
  return trains
end
local trains = findAllTrainsIn(workspace)
for _index_0 = 1, #trains do
  local train = trains[_index_0]
  train:init()
  train:run()
end
