local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AssetService = game:GetService("AssetService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local data = require(ReplicatedStorage:WaitForChild("VideoData"))

local W = assert(data.Width, "VideoData.Width missing")
local H = assert(data.Height, "VideoData.Height missing")
local FPS = assert(data.FPS, "VideoData.FPS missing")
local P = assert(data.P, "VideoData.P missing")
P = P:gsub("%s+", "")

assert(W > 0 and H > 0 and FPS > 0, "Invalid VideoData dimensions or FPS")

local MAX_IMAGE = 1024
local OUT_W = math.min(W, MAX_IMAGE)
local OUT_H = math.min(H, MAX_IMAGE)
local GRID = W * H
local OUT_CELLS = OUT_W * OUT_H

local gui = Instance.new("ScreenGui")
gui.Name = "RobloxVideoPlayer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function stroke(parent, color, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Transparency = transparency or 0
	s.Thickness = 1
	s.Parent = parent
	return s
end

local function label(parent, text, size, font, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = size
	l.Font = font
	l.TextColor3 = color
	l.Parent = parent
	return l
end

local window = Instance.new("Frame")
window.Name = "VideoWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.new(0.72, 0, 0.68, 0)
window.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
window.BorderSizePixel = 0
window.ClipsDescendants = true
window.Parent = gui
corner(window, 14)
stroke(window, Color3.fromRGB(60, 64, 78), 0.25)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(420, 300)
sizeConstraint.MaxSize = Vector2.new(1100, 760)
sizeConstraint.Parent = window

local top = Instance.new("Frame")
top.Name = "TitleBar"
top.Size = UDim2.new(1, 0, 0, 44)
top.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
top.BorderSizePixel = 0
top.Active = true
top.Parent = window

local title = label(top, "Roblox Video", 14, Enum.Font.GothamBold, Color3.fromRGB(245, 246, 250))
title.Position = UDim2.fromOffset(16, 0)
title.Size = UDim2.new(1, -150, 1, 0)
title.TextXAlignment = Enum.TextXAlignment.Left

local resolution = label(top, string.format("%dx%d  •  %d FPS", W, H, FPS), 11, Enum.Font.Gotham, Color3.fromRGB(145, 151, 165))
resolution.Position = UDim2.new(0, 16, 0, 24)
resolution.Size = UDim2.new(1, -150, 0, 16)
resolution.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -8, 0.5, 0)
closeButton.Size = UDim2.fromOffset(32, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(55, 24, 31)
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamMedium
closeButton.TextColor3 = Color3.fromRGB(255, 150, 160)
closeButton.Parent = top
corner(closeButton, 7)

local minButton = Instance.new("TextButton")
minButton.Name = "Minimize"
minButton.AnchorPoint = Vector2.new(1, 0.5)
minButton.Position = UDim2.new(1, -46, 0.5, 0)
minButton.Size = UDim2.fromOffset(32, 30)
minButton.BackgroundColor3 = Color3.fromRGB(34, 36, 46)
minButton.BorderSizePixel = 0
minButton.Text = "−"
minButton.TextSize = 20
minButton.Font = Enum.Font.GothamMedium
minButton.TextColor3 = Color3.fromRGB(225, 227, 235)
minButton.Parent = top
corner(minButton, 7)

local video = Instance.new("Frame")
video.Name = "Video"
video.Position = UDim2.new(0, 10, 0, 54)
video.Size = UDim2.new(1, -20, 1, -122)
video.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
video.BorderSizePixel = 0
video.ClipsDescendants = true
video.Parent = window
corner(video, 10)

local image = Instance.new("ImageLabel")
image.Name = "Image"
image.Size = UDim2.fromScale(1, 1)
image.BackgroundTransparency = 1
image.BorderSizePixel = 0
image.ScaleType = Enum.ScaleType.Fit
image.ResampleMode = Enum.ResamplerMode.Pixelated
image.Parent = video

local controls = Instance.new("Frame")
controls.Name = "Controls"
controls.AnchorPoint = Vector2.new(0, 1)
controls.Position = UDim2.new(0, 10, 1, -10)
controls.Size = UDim2.new(1, -20, 0, 58)
controls.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
controls.BorderSizePixel = 0
controls.Parent = window
corner(controls, 10)

local function button(name, text, position, width)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = UDim2.fromOffset(position, 9)
	b.Size = UDim2.fromOffset(width, 40)
	b.BackgroundColor3 = Color3.fromRGB(31, 34, 43)
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Text = text
	b.TextSize = 13
	b.Font = Enum.Font.GothamMedium
	b.TextColor3 = Color3.fromRGB(240, 242, 247)
	b.Parent = controls
	corner(b, 8)
	stroke(b, Color3.fromRGB(65, 69, 82), 0.35)
	return b
end

local back = button("Back5", "⏪ 5s", 8, 66)
local play = button("PlayPause", "Ⅱ  Pause", 82, 86)
local forward = button("Forward5", "5s ⏩", 176, 66)

local timeText = label(controls, "00:00 / 00:00", 13, Enum.Font.GothamMedium, Color3.fromRGB(164, 170, 184))
timeText.Position = UDim2.new(0, 252, 0, 0)
timeText.Size = UDim2.new(1, -262, 1, 0)
timeText.TextXAlignment = Enum.TextXAlignment.Right

local popup = Instance.new("TextButton")
popup.Name = "OpenVideo"
popup.AnchorPoint = Vector2.new(0, 1)
popup.Position = UDim2.new(0, 18, 1, -18)
popup.Size = UDim2.fromOffset(150, 42)
popup.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
popup.BorderSizePixel = 0
popup.Text = "▶  Open Video"
popup.TextSize = 13
popup.Font = Enum.Font.GothamBold
popup.TextColor3 = Color3.fromRGB(240, 242, 247)
popup.Visible = false
popup.Parent = gui
corner(popup, 10)
stroke(popup, Color3.fromRGB(70, 74, 90), 0.25)

local minimized = false
local closed = false

local function pause()
	playing = false
	play.Text = "▶  Play"
end

local function showWindow()
	closed = false
	minimized = false
	window.Visible = true
	popup.Visible = false
	play.Text = playing and "Ⅱ  Pause" or "▶  Play"
end

local function hideWindow()
	closed = true
	playing = false
	play.Text = "▶  Play"
	window.Visible = false
	popup.Visible = true
end

local function minimizeWindow()
	minimized = true
	playing = false
	play.Text = "▶  Play"
	window.Visible = false
	popup.Visible = true
end

closeButton.Activated:Connect(hideWindow)
minButton.Activated:Connect(minimizeWindow)
popup.Activated:Connect(showWindow)

local dragging = false
local dragStart
local startPosition

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = window.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local delta = input.Position - dragStart
	window.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64VAL = {}
for i = 1, #B64 do
	B64VAL[B64:sub(i, i)] = i - 1
end
B64VAL["="] = 0

local function base64ToBuffer(s)
	local n = #s
	local padding = 0
	if n > 0 and s:sub(n, n) == "=" then padding += 1 end
	if n > 1 and s:sub(n - 1, n - 1) == "=" then padding += 1 end

	local length = math.floor(n / 4) * 3 - padding
	local out = buffer.create(length)
	local op = 0

	for i = 1, n, 4 do
		local a = B64VAL[s:sub(i, i)] or 0
		local b = B64VAL[s:sub(i + 1, i + 1)] or 0
		local c = B64VAL[s:sub(i + 2, i + 2)] or 0
		local d = B64VAL[s:sub(i + 3, i + 3)] or 0
		local v = a * 262144 + b * 4096 + c * 64 + d

		if op < length then
			buffer.writeu8(out, op, math.floor(v / 65536) % 256)
			op += 1
		end
		if op < length then
			buffer.writeu8(out, op, math.floor(v / 256) % 256)
			op += 1
		end
		if op < length then
			buffer.writeu8(out, op, v % 256)
			op += 1
		end
	end

	return out
end

local bs = base64ToBuffer(P)
local pos = 0

local function readU8()
	local v = buffer.readu8(bs, pos)
	pos += 1
	return v
end

local function readVarint()
	local value = 0
	local shift = 0
	while true do
		local b = readU8()
		value += (b % 128) * 2 ^ shift
		if b < 128 then return value end
		shift += 7
	end
end

local packedBytes = math.ceil(GRID / 2) * 3
local cur = buffer.create(GRID * 2)
local editableImage = nil
local pixels = buffer.create(OUT_CELLS * 4)

local function decodeFull()
	local out = buffer.create(GRID * 2)
	local index = 0

	for _ = 1, math.ceil(GRID / 2) do
		local v = readU8() * 65536 + readU8() * 256 + readU8()
		buffer.writeu16(out, index * 2, math.floor(v / 4096))
		index += 1
		if index < GRID then
			buffer.writeu16(out, index * 2, v % 4096)
			index += 1
		end
	end

	return out
end

local function decodeDelta()
	local count = readVarint()
	local indices = buffer.create(count * 4)
	local index = -1

	for i = 0, count - 1 do
		index += readVarint() + 1
		buffer.writeu32(indices, i * 4, index)
	end

	for i = 0, count - 1, 2 do
		local v = readU8() * 65536 + readU8() * 256 + readU8()
		local c1 = math.floor(v / 4096)
		local c2 = v % 4096
		local a = buffer.readu32(indices, i * 4)
		buffer.writeu16(cur, a * 2, c1)

		if i + 1 < count then
			local b = buffer.readu32(indices, (i + 1) * 4)
			buffer.writeu16(cur, b * 2, c2)
		end
	end
end

local numFrames = readVarint()
local totalFrames = readVarint()

assert(numFrames > 0, "VideoData contains no frames")

local targets = table.create(numFrames)
local kinds = table.create(numFrames)
local offsets = table.create(numFrames)

local timeline = 0

for i = 1, numFrames do
	local step = readVarint()
	local kind = readU8()

	timeline += step
	targets[i] = timeline
	kinds[i] = kind
	offsets[i] = pos

	if kind == 0 then
		pos += packedBytes
	else
		local count = readVarint()
		for _ = 1, count do
			readVarint()
		end
		pos += math.ceil(count / 2) * 3
	end
end

local function lowerBound(value)
	local lo = 1
	local hi = numFrames
	local answer = numFrames + 1

	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		if targets[mid] > value then
			answer = mid
			hi = mid - 1
		else
			lo = mid + 1
		end
	end

	return answer - 1
end

local function decodeFrame(index)
	pos = offsets[index]

	if kinds[index] == 0 then
		local full = decodeFull()
		buffer.copy(cur, 0, full, 0, GRID * 2)
	else
		decodeDelta()
	end
end

local function render()
	local n = math.min(GRID, OUT_CELLS)

	for i = 0, n - 1 do
		local c = buffer.readu16(cur, i * 2)
		local r = math.floor(c / 256) % 16 * 17
		local g = math.floor(c / 16) % 16 * 17
		local b = c % 16 * 17
		buffer.writeu32(pixels, i * 4, r + g * 256 + b * 65536 + 4278190080)
	end

	local editable = editableImage
	if editable then
		editable:WritePixelsBuffer(Vector2.zero, Vector2.new(OUT_W, OUT_H), pixels)
	end
end

editableImage = AssetService:CreateEditableImage({
	Size = Vector2.new(OUT_W, OUT_H)
})

image.ImageContent = Content.fromObject(editableImage)

local currentFrame = 0
local nextIndex = 1
local playing = true
local accumulator = 0
local frameTime = 1 / FPS

local function formatTime(frame)
	local seconds = math.max(0, math.floor(frame / FPS))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function updateTime()
	timeText.Text = formatTime(currentFrame) .. " / " .. formatTime(totalFrames)
end

local function seekTo(frame)
	frame = math.clamp(math.floor(frame), 0, totalFrames)

	local index = lowerBound(frame)

	local fullIndex = 1
	local lo = 1
	local hi = math.max(1, index)

	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		if kinds[mid] == 0 and targets[mid] <= frame then
			fullIndex = mid
			lo = mid + 1
		else
			hi = mid - 1
		end
	end

	buffer.fill(cur, 0, 0, GRID * 2)

	for i = fullIndex, index do
		decodeFrame(i)
	end

	currentFrame = index >= 1 and targets[index] or 0
	nextIndex = index + 1
	render()
	updateTime()
	accumulator = 0
end

local function setPlaying(value)
	playing = value
	play.Text = value and "Ⅱ  Pause" or "▶  Play"
end

play.Activated:Connect(function()
	setPlaying(not playing)
end)

back.Activated:Connect(function()
	seekTo(currentFrame - FPS * 5)
end)

forward.Activated:Connect(function()
	seekTo(currentFrame + FPS * 5)
end)

decodeFrame(1)
currentFrame = targets[1]
nextIndex = 2
render()
updateTime()

RunService.RenderStepped:Connect(function(dt)
	if not playing or closed or minimized then
		return
	end

	accumulator += dt

	if accumulator > 0.25 then
		accumulator = 0.25
	end

	while accumulator >= frameTime do
		accumulator -= frameTime

		if nextIndex > numFrames then
			if currentFrame >= totalFrames then
				seekTo(0)
				continue
			end
			currentFrame += 1
		else
			currentFrame += 1
			while nextIndex <= numFrames and targets[nextIndex] <= currentFrame do
				decodeFrame(nextIndex)
				nextIndex += 1
			end
		end

		render()
	end

	updateTime()
end)

updateTime()
print(string.format("Local video ready: %dx%d @ %d FPS, %d stored frames, %d total frames", W, H, FPS, numFrames, totalFrames))
