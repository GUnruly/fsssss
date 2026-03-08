-- 1. CLEANUP
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "Rayfield" then v:Destroy() end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. MAIN WINDOW
local Window = Rayfield:CreateWindow({
   Name = "FIAS COMB",
   LoadingTitle = " ", 
   LoadingSubtitle = " ",
   ConfigurationSaving = { Enabled = true, FolderName = "FC Configs", FileName = "MainConfig" }
})

-- ==========================================
-- STATE VARIABLES
-- ==========================================
_G.HitboxEnabled = false
_G.HitboxSize = 5
_G.HitboxTransparency = 0.7

_G.FastmentEnabled = false
_G.PunchSpeedEnabled = false
_G.PunchSpeedValue = 2.5

local GAME_DEFAULT_SPEED = 10
local BOOST_SPEED = 22
local BOOST_DURATION = 0.2

local HitboxConnections = {}
local FastmentInputConn = nil

local punchIDs = {
   --Philly
    ["rbxassetid://18312333191"] = true, ["rbxassetid://18312335714"] = true,
    ["rbxassetid://18312338197"] = true, ["rbxassetid://18312340119"] = true,
    ["rbxassetid://18312344029"] = true, ["rbxassetid://18312346524"] = true,
    ["rbxassetid://18312348771"] = true, ["rbxassetid://18312351760"] = true,
    --Slap Box
    ["rbxassetid://17796387423"] = true,
    ["rbxassetid://17796396059"] = true,
    ["rbxassetid://17796400708"] = true,
    ["rbxassetid://17796403834"] = true -- Das letzte braucht kein Komma, schadet aber auch nicht
}

-- ==========================================
-- SILENT HELPERS
-- ==========================================

local function ClearConsole()
    for i = 1, 100 do print(" ") end
    if rconsoleclear then rconsoleclear() end 
end

local function PanicReset()
    _G.HitboxEnabled = false
    _G.FastmentEnabled = false
    _G.PunchSpeedEnabled = false

    pcall(function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.WalkSpeed = GAME_DEFAULT_SPEED 
            local anim = hum:FindFirstChildOfClass("Animator")
            if anim then
                for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end
            end
        end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end)

    if FastmentInputConn then FastmentInputConn:Disconnect() FastmentInputConn = nil end
    for _, conn in pairs(HitboxConnections) do pcall(function() conn:Disconnect() end) end
    HitboxConnections = {}
    ClearConsole()
end

-- ==========================================
-- PERMANENT RESPAWN LOGIC
-- ==========================================
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        if _G.FastmentEnabled then
            hum.WalkSpeed = GAME_DEFAULT_SPEED
        end
    end
end)

-- ==========================================
-- TAB 1: HBOX
-- ==========================================
local HboxTab = Window:CreateTab("Hbox", 4483362458)

HboxTab:CreateToggle({
   Name = "Enable Hitbox Expander",
   CurrentValue = false,
   Flag = "HboxToggle",
   Callback = function(Value)
      _G.HitboxEnabled = Value
      if Value then
         task.spawn(function()
            while _G.HitboxEnabled do
               pcall(function()
                  for _, p in pairs(game.Players:GetPlayers()) do
                     if p ~= game.Players.LocalPlayer and p.Character then
                        local Root = p.Character:FindFirstChild("HumanoidRootPart")
                        if Root then
                           Root.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                           Root.Transparency = _G.HitboxTransparency
                           Root.CanCollide = false
                        end
                     end
                  end
               end)
               task.wait(2)
            end
         end)
      else
         pcall(function()
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1)
                    p.Character.HumanoidRootPart.Transparency = 1
                end
            end
         end)
      end
   end,
})

HboxTab:CreateSlider({
   Name = "Size", Range = {2, 10}, Increment = 1, CurrentValue = 5, Flag = "HboxSize",
   Callback = function(v) _G.HitboxSize = v end,
})

HboxTab:CreateSlider({
   Name = "Transparency", Range = {0, 1}, Increment = 0.1, CurrentValue = 0.7, Flag = "HboxTrans",
   Callback = function(v) _G.HitboxTransparency = v end,
})

-- ==========================================
-- TAB 2: FAST PUNCH
-- ==========================================
local PunchTab = Window:CreateTab("Fast Punch", 4483362458)

PunchTab:CreateToggle({
   Name = "Enable Fast Punch",
   CurrentValue = false,
   Flag = "PunchToggle",
   Callback = function(Value)
      _G.PunchSpeedEnabled = Value
      if Value then
         task.spawn(function()
            while _G.PunchSpeedEnabled do
               pcall(function()
                  local live = workspace:FindFirstChild("Live")
                  local char = live and live:FindFirstChild(game.Players.LocalPlayer.Name)
                  local hum = char and char:FindFirstChildOfClass("Humanoid")
                  local anim = hum and hum:FindFirstChildOfClass("Animator")
                  if anim then
                     for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                        if punchIDs[tostring(t.Animation.AnimationId):lower()] then
                           t:AdjustSpeed(_G.PunchSpeedValue)
                        end
                     end
                  end
               end)
               task.wait(0.01)
            end
         end)
      else
         pcall(function()
            local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:FindFirstChildOfClass("Animator") then
                for _, t in ipairs(hum.Animator:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end
            end
         end)
      end
   end,
})

PunchTab:CreateSlider({
   Name = "Punch Speed Multiplier", Range = {1, 5}, Increment = 0.1, CurrentValue = 2.5, Flag = "PV",
   Callback = function(v) _G.PunchSpeedValue = v end,
})

-- ==========================================
-- TAB 3: FASTMENT (Clean Dash)
-- ==========================================
local FastTab = Window:CreateTab("Fastment", 4483362458)

FastTab:CreateToggle({
   Name = "Enable Fastment",
   CurrentValue = false,
   Flag = "FastToggle",
   Callback = function(Value)
      _G.FastmentEnabled = Value
      if Value then
         pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = GAME_DEFAULT_SPEED end
         end)

         if not FastmentInputConn then
             FastmentInputConn = game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
                if processed or not _G.FastmentEnabled then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                   pcall(function()
                      local char = game.Players.LocalPlayer.Character
                      -- Only trigger if holding ANY tool
                      if char and char:FindFirstChildOfClass("Tool") then
                          local hum = char:FindFirstChildOfClass("Humanoid")
                          if hum then
                              -- SPEED BOOST
                              hum.WalkSpeed = BOOST_SPEED
                              task.wait(BOOST_DURATION)
                              
                              -- RESET
                              if _G.FastmentEnabled and hum then 
                                  hum.WalkSpeed = GAME_DEFAULT_SPEED 
                              end
                          end
                      end
                   end)
                end
             end)
         end
      else
         if FastmentInputConn then FastmentInputConn:Disconnect() FastmentInputConn = nil end
         pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = GAME_DEFAULT_SPEED end
         end)
      end
   end,
})

-- ==========================================
-- TAB 4: SETTINGS (Panic)
-- ==========================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
   Name = "PANIC: RESET & DESTROY",
   Callback = function() PanicReset() Rayfield:Destroy() end,
})

SettingsTab:CreateKeybind({
   Name = "Panic Keybind",
   CurrentKeybind = "RightShift",
   Flag = "PK",
   Callback = function() PanicReset() Rayfield:Destroy() end,
})