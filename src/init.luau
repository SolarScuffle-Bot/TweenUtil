--!strict

local TweenService = game:GetService 'TweenService'

local Module = {}

local tweens = {}

function Module.cancel(key: Instance)
	local data = tweens[key]
	if not data then
		return
	end

	data.tween:Cancel()
	data.tween:Destroy()
	tweens[key] = nil
end

function Module.new(key: Instance, info: TweenInfo, goal: { [string]: any })
	Module.cancel(key)

	local tween: Tween = TweenService:Create(key, info, goal)

	tween.Completed:Connect(function(playbackState)
		Module.cancel(key)
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

	return Module.new(cframe, info, newGoal), c
end

return Module
