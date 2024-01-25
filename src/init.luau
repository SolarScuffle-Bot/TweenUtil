--!strict

local TweenService = game:GetService 'TweenService'

local Module = {}

local tweens = {}

local function cancel(key: Instance)
	local data = tweens[key]
	if not data then
		return
	end

	data.tween:Cancel()
	data.tween:Destroy()
	tweens[key] = nil
end
Module.cancel = cancel

function Module.cancelDescendants(key: Instance, className: string?)
	for _, child in key:GetDescendants() do
		if not className or child:IsA(className) then
			cancel(child)
		end
	end
end

local function new(key: Instance, info: TweenInfo, goal: { [string]: any })
	cancel(key)

	local tween: Tween = TweenService:Create(key, info, goal)

	tween.Completed:Connect(function(playbackState)
		cancel(key)
	end)

	local data = {
		goal = goal,
		info = info,
		tween = tween,
		started = os.clock(),
	}

	tweens[key] = data

	tween:Play()

	return data
end
Module.new = new

function Module.newDescendants(key: Instance, info: TweenInfo, goal: { [string]: any }, className: string?)
	for _, child in key:GetDescendants() do
		if not className or child:IsA(className) then
			new(key, info, goal)
		end
	end
end

function Module.get(key)
	return tweens[key]
end

function Module.newModel(key: Model, info: TweenInfo, goal: { Pivot: CFrame, [string]: any })
	local cframe = Instance.new 'CFrameValue'
	cframe.Value = key:GetPivot()

	local c = cframe.Changed:Connect(function(new)
		key:PivotTo(new)
	end)

	local newGoal = table.clone(goal) :: { [string]: any }
	newGoal.Value = goal.Pivot
	newGoal.Pivot = nil

	return new(cframe, info, newGoal), c
end

return Module
