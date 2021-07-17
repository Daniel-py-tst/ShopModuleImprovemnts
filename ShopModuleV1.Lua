--services
local TweenService = game:GetService("TweenService")

--instances
local weld = Instance.new("WeldConstraint")
weld.Parent = game.Workspace
local RunService = game:GetService("RunService")
--local depth = game.Lighting.DepthOfField
local frame = script.Parent.ShopUiFrame
local player = game.Players.localPlayer
local character = player.Character
local AnchorPart = character:WaitForChild("RightFoot")
local Camera = workspace.CurrentCamera
local Debounce = true
local sideDBL = true
local sideDBR = true
local functdb = true
local openPrompt = game.Workspace.Shop.Open.ProximityPrompt
local returnP = game.Workspace.Shop.ReturnPoint
local ShowCase = game.Workspace.Shop.ShowCasePoint

--data structures
viewNum = 1
local minim = 1

local items = game.Workspace.Shop.ShopItems:GetChildren()
table.sort(items ,function(a, b) return a.Name < b.Name end)

local function w()
	local tab  = {}
	for i, v in pairs(items) do
		for i, bom in pairs(frame.DetailsFrame.Items:GetChildren()) do
			if bom.Name == v.Name then
				tab[v] = {false, bom}
			end
		end
	end
	return tab
end

local Viewing = w()

--Tweens
local tweenToView = TweenService:Create(
	Camera,
	TweenInfo.new(1),
	{CFrame = game.Workspace.Shop.LookPoint.CFrame}
)




--functions
local function UniversalTween(focusPart)
	local CFrameofPrim = focusPart.PrimaryPart
	local TweenForward = TweenService:Create(focusPart, TweenInfo.new(.35), {CFrame = CFrameofPrim:GetPrimaryPartCFrame() * ShowCase.CFrame})
	TweenForward:Play()
	--TweenForward.Completed:Wait()
	Viewing[focusPart] = true
		local c c = RunService.Heartbeat:Connect(function()
		if Viewing[focusPart] == true then
			if Viewing[focusPart]:IsA("BasePart") then
				focusPart.CFrame *= CFrame.Angles(0,.05,0.01)
			else
				focusPart:SetPrimaryPartCFrame(focusPart:GetPrimaryPartCFrame() * CFrame.Angles(0,.05,0.01))
			end
		else
			c:Disconnect()
		end
	end)
end



local function onOpenedShop(plr)
	if Debounce then 
		openPrompt.Enabled = false
		viewNum = 1
		wait(.3)
		weld.Part0 = game.Workspace.Shop.AnchorPoint
		weld.Part1 = AnchorPart
		Camera.CameraType = Enum.CameraType.Scriptable 
		tweenToView:Play()
		tweenToView.Completed:Wait()
		frame.Visible = true
		--depth.Enabled = true
		UniversalTween(items[viewNum])
	end
end




local function onClickedRight(plr)
		if viewNum >= #items then
	elseif frame.Right.Visible then
		frame.Right.Visible = false
		local TweenBack = TweenService:Create(items[viewNum], TweenInfo.new(.35), {CFrame = returnP.CFrame})
		TweenBack:Play()
		TweenBack.Completed:Wait()
		Viewing[items[viewNum]] = false
		viewNum += 1
		Viewing[items[viewNum]] = true
			wait(.1)
		returnP.CFrame = items[viewNum].CFrame
		local loadcoro_R = coroutine.wrap(function() wait(.5)print("Clickable!")frame.Right.Visible = true end)
		loadcoro_R()
		UniversalTween(items[viewNum])
		end
end




local function onClickedLeft(plr)
	if viewNum <= minim then
	elseif frame.Left.Visible then
		frame.Left.Visible = false
		local TweenBack = TweenService:Create(items[viewNum], TweenInfo.new(.35), {CFrame = returnP.CFrame})
		TweenBack:Play()
		TweenBack.Completed:Wait()
	Viewing[items[viewNum]] = false
	viewNum -= 1
		Viewing[items[viewNum]] = true
	wait(.1)
		returnP.CFrame = items[viewNum].CFrame
		local loadcoro_L = coroutine.wrap(function()
			wait(.5)
			print("Clickable!")
			frame.Left.Visible = true
		end)
		loadcoro_L()
		UniversalTween(items[viewNum])
		end
end




local function onClosedShop(plr)
	local TweenBack = TweenService:Create(items[viewNum], TweenInfo.new(.35), {CFrame = returnP.CFrame})
	TweenBack:Play()
	TweenBack.Completed:Wait()
	Viewing[items[viewNum]] = false
	viewNum = 1
	frame.Visible = false
	wait(.3)
	weld.Part1 = nil
	returnP.CFrame = items[viewNum].CFrame
	Camera.CameraType = Enum.CameraType.Custom
	Debounce = false
	--depth.Enabled = false
	wait(1)
	Debounce = true
	openPrompt.Enabled = true
end



openPrompt.Triggered:Connect(onOpenedShop)

frame.Left.MouseButton1Down:Connect(onClickedLeft)

frame.Right.MouseButton1Down:Connect(onClickedRight)
frame.Close.MouseButton1Down:Connect(onClosedShop)


--make guis pretty
