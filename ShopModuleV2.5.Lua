--Models must have a primarypart acting as a root
--Only the root must be anchored

local show = game.Workspace.Show.SurfaceGui.TextLabel
local letterTable = {"A","B","C","D","E","F","G","H","I","J","K","L","M","O","P","Q","R","S","T","U","V","W","X","Y","Z",1,2,3,4,5,6,7}

--Sorting Tables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local frame = script.Parent.ShopUiFrame

local function PredicatorForInstance(a,b)
	return a.Name < b.Name
end

local T = game.Workspace.ShopFolder.ShopItems:GetChildren()
table.sort(T, PredicatorForInstance)

local function SortertableOranizer(tab)
	local t = {}
	for i, v in ipairs(tab) do
		for i, letter in ipairs(script.Parent.ShopUiFrame.DetailsFrame.Items:GetChildren()) do
			if v.Name == letter.Name then
				t[v] = {false, letter}
			end
		end
	end
	return t
end

local ItemTable = SortertableOranizer(T)


print(ItemTable)

local function WeldModelsToRoot(Table)
	for i, Item in ipairs(Table) do
		if Item:IsA("Model") then
			for i, Part in ipairs(Item:GetChildren()) do
				if Part:IsA("BasePart") then
					local weld = Instance.new("WeldConstraint", Part)
					weld.Part0 = Part
					weld.Part1 = Item.PrimaryPart
				end
			end
		end
	end
end

WeldModelsToRoot(T)

--Controllers and Variables

CurrentItem = 1
local tweenTime = .35
local uiT = .2
local bd = true
local db = true
local lighting = game.Lighting
local left = frame.Left
local right = frame.Right
local close = frame.Close
local buy = frame.Buy
local openPrompt = game.Workspace.ShopFolder.Parts.OpenPoint.ProximityPrompt
local Gui = game.Workspace.Show.SurfaceGui.TextLabel
local ReturnPart = game.Workspace.ShopFolder.Parts.ReturnPoint
local ShowcasePoint = game.Workspace.ShopFolder.Parts.ShowCasePoint
local player = game.Players.localPlayer
local character = player.Character
local AnchorPart = character:WaitForChild("RightFoot")
local Camera = workspace.CurrentCamera
local open = game.Workspace.ShopFolder.Parts.OpenPoint
local anchorSurf = game.Workspace.ShopFolder.Parts.AnchorPoint
local weldyboi = Instance.new("WeldConstraint")
weldyboi.Parent = game.Workspace

--Services
local TweenService = game:GetService("TweenService")
local Runservice = game:GetService("RunService")
local BuyEvent = ReplicatedStorage:FindFirstChild("BuyTool")

--misc Functions
local function MoveToParent(obj, space)
	obj.Parent = space
end

local function emittt(ye)
	for i,v in ipairs(ye:GetChildren()) do
		wait()
		v:Emit(2)
	end
end

local function anchorTo(FPart, SPart)
	weldyboi.Part0 = FPart
	weldyboi.Part1 = SPart
end

--Tweens
local tweenToView = TweenService:Create(
	Camera,
	TweenInfo.new(1),
	{CFrame = game.Workspace.ShopFolder.Parts.ViewPoint.CFrame}
)

local function uiTween(Ui, s, e)
	Ui.Transparency = s
	TweenService:Create(Ui, TweenInfo.new(.2), {Transparency = e}):Play()
end
--Functions
--------------------------------------------------------------------------------------------------------------
-- Cometic functions

local function ShowObj(SortedTable, ObjectStateTable)
	
	--Tweening to Showcase
	
	if SortedTable[CurrentItem]:IsA("Model") then
		local t1 = TweenService:Create(SortedTable[CurrentItem].PrimaryPart,TweenInfo.new(tweenTime),{CFrame = ShowcasePoint.CFrame})
		t1:Play()
		t1.Completed:Wait()
	else
		local t2 = TweenService:Create(SortedTable[CurrentItem],TweenInfo.new(tweenTime),{CFrame = ShowcasePoint.CFrame})
		t2:Play()
		t2.Completed:Wait()
	end
	
	--Ensure current item spins
	ObjectStateTable[T[CurrentItem]][1] = true
	ObjectStateTable[T[CurrentItem]][2].Visible = true
	--spin event
	local c c = Runservice.Heartbeat:Connect(function()
		if ObjectStateTable[T[CurrentItem]][1] == true then
			--show.Text = "Current Part: "..ObjectStateTable[T[CurrentItem]][2].N.Text
			frame.Buy.TextLabel.Text = "$"..ObjectStateTable[T[CurrentItem]][2].Price.Value
			if T[CurrentItem]:IsA("Model") then
				T[CurrentItem]:SetPrimaryPartCFrame(T[CurrentItem]:GetPrimaryPartCFrame() * CFrame.Angles(0,.05,0.01))
			else
				T[CurrentItem].CFrame *= CFrame.Angles(0,.05,0.01)
			end
		else
			print("disconnected")
			c:Disconnect()
			local d d = Runservice.Heartbeat:Connect(function()
				if ObjectStateTable[T[CurrentItem]][1] == true then
					print("disconnected 1")
					d:Disconnect()
				else
					show.Text = "Current Part: "..letterTable[ math.random(1,#letterTable)]..letterTable[ math.random(1,#letterTable)]..letterTable[ math.random(1,#letterTable)]..letterTable[ math.random(1,#letterTable)]..letterTable[ math.random(1,#letterTable)]..letterTable[ math.random(1,#letterTable)]..letterTable[ math.random(1,#letterTable)]
				end
			end)
		end 
	end)
end


local function TweenBackCurrobj(obj, returnp, SortedTable)
	if SortedTable[CurrentItem]:IsA("Model") then
		local t1 = TweenService:Create(obj.PrimaryPart,TweenInfo.new(tweenTime),{CFrame = returnp.CFrame})
		t1:Play()
		t1.Completed:Wait()
	else
		local t2 = TweenService:Create(obj,TweenInfo.new(tweenTime),{CFrame = returnp.CFrame})
		t2:Play()
		t2.Completed:Wait()
	end
end



--LogicFunctions
--------------------------------------------------------------------------------------------------------------
--Moves the return part to the current obj
local function SetReturnPart(Tab)
	if Tab[CurrentItem]:IsA("Model") then
		ReturnPart.CFrame = Tab[CurrentItem]:GetPrimaryPartCFrame()
	else
		ReturnPart.Position = T[CurrentItem].Position
	end
end

local function ye()
	game.Workspace.Sounds.click2down:Play()
	BuyEvent:FireServer(ItemTable[T[CurrentItem]][2].Name)
	if player.leaderstats.Cash.Value >= ItemTable[T[CurrentItem]][2].Price.Value then
		game.Workspace.Sounds.purchase:Play()
		emittt(ShowcasePoint.Attachment)
		frame.Parent.BuyFrame.Visible = false
		uiTween(frame.DetailsFrame, 1, uiT)
		frame.Visible = true
	else
		frame.Parent.BuyFrame.SureFrame.Visible = false
		uiTween(frame.Parent.BuyFrame.NotEnoughFrame, 1, uiT)
		frame.Parent.BuyFrame.NotEnoughFrame.Visible = true
	end
	
end

local function na()
	game.Workspace.Sounds.click2down:Play()
	frame.Parent.BuyFrame.Visible = false
	uiTween(frame.DetailsFrame, 1, uiT)
	frame.Visible = true
end

local function Buy()
	game.Workspace.Sounds.click2down:Play()
	frame.Visible = false
	
	frame.Parent.BuyFrame.SureFrame.SureCheck.Text = "Are you sure you want to buy "..string.lower(ItemTable[T[CurrentItem]][2].N.Text).."?"
	frame.Parent.BuyFrame.Visible = true
	uiTween(frame.Parent.BuyFrame.SureFrame, 1, uiT)
	frame.Parent.BuyFrame.SureFrame.Visible = true
end


local function Open()
	print(ItemTable)
	game.Workspace.Sounds.click2down:Play()
	frame.Buy.TextLabel.Text = "..."
	MoveToParent(open, lighting)
	anchorTo(AnchorPart, anchorSurf)
	Camera.CameraType = Enum.CameraType.Scriptable 
	tweenToView:Play()
	tweenToView.Completed:Wait()
	uiTween(frame.DetailsFrame, 1, uiT)
	frame.Visible = true
	ShowObj(T, ItemTable)
end

--RightButton
local function Next()
	if db == true then
		db = false
		game.Workspace.Sounds.click2down:Play()
		--causes the current spining item to stop
		ItemTable[T[CurrentItem]][1] = false
		ItemTable[T[CurrentItem]][2].Visible = false
		frame.Buy.TextLabel.Text = "..."
		TweenBackCurrobj(T[CurrentItem], ReturnPart, T)
		--value changer of item
		if CurrentItem >= #T then
			CurrentItem = 1
		else
			-- moves right
			CurrentItem += 1
		end
		SetReturnPart(T)
		--runs the function which causes the new current item to spin, if next is clicked again, it'll change its state to false.
		ShowObj(T, ItemTable)
		db = true
	end
end

--LeftButton
local function Prev()
	if bd == true then
		bd = false
		game.Workspace.Sounds.click2down:Play()
		--Checks table end
		ItemTable[T[CurrentItem]][1] = false
		ItemTable[T[CurrentItem]][2].Visible = false
		frame.Buy.TextLabel.Text = "..."
		TweenBackCurrobj(T[CurrentItem], ReturnPart, T)
		if CurrentItem <= 1 then
			CurrentItem = #T
		else
			-- moves left
			CurrentItem -= 1
		end
		SetReturnPart(T)

		ShowObj(T, ItemTable)
		bd = true
	end

end

local function Close()
	game.Workspace.Sounds.click2down:Play()
	TweenBackCurrobj(T[CurrentItem], ReturnPart, T)
	ItemTable[T[CurrentItem]][1] = false
	ItemTable[T[CurrentItem]][2].Visible = false
	CurrentItem = 1
	SetReturnPart(T)
	weldyboi.Part1 = nil
	uiTween(frame.DetailsFrame, uiT, 1)
	Camera.CameraType = Enum.CameraType.Custom
	frame.Visible = false
	MoveToParent(open, game.Workspace)
end

close.MouseButton1Down:Connect(Close)
openPrompt.Triggered:Connect(Open)
right.MouseButton1Down:Connect(Next)
left.MouseButton1Down:Connect(Prev)
buy.MouseButton1Down:Connect(Buy)
frame.Parent.BuyFrame.SureFrame.Ye.MouseButton1Down:Connect(ye)
frame.Parent.BuyFrame.SureFrame.Na.MouseButton1Down:Connect(na)
frame.Parent.BuyFrame.NotEnoughFrame.Cancel.MouseButton1Down:Connect(function()
	game.Workspace.Sounds.click2down:Play()
	frame.Parent.BuyFrame.NotEnoughFrame.Visible = false
	uiTween(frame.DetailsFrame, 1, uiT)
	frame.Visible = true
end)
