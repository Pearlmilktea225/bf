-- [[ 🧋 珍奶腳本 V10 | Skibx 注射器適配版 ]]

-- 1. Skibx 專用強化加載器
local function GetRaw(url)
    local success, content = pcall(game.HttpGet, game, url)
    if success then return content end
    return nil
end

local UI_Source = GetRaw("https://raw.githubusercontent.com/realredz/RedzLibV5/main/Source.lua")
if not UI_Source then
    UI_Source = GetRaw("https://raw.githubusercontent.com/jensonh02/RedzLib/main/Source.lua")
end

local RedzLib = loadstring(UI_Source)()

-- 2. 全域配置
_G.AutoFarm = false
_G.FastAttack = true
_G.AutoBuso = true
_G.SelectWeapon = "Melee"
_G.FlyHeight = 11

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local VUser = game:GetService("VirtualUser")

-- 3. 極速攻擊系統 (針對 Skibx 優化)
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm and _G.FastAttack then
            pcall(function()
                if _G.AutoBuso and not LP.Character:FindFirstChild("HasBuso") then
                    RS.Remotes.CommF_:InvokeServer("Buso")
                end
                -- 快速攻擊封包
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if tool then
                    RS.Remotes.Sub.Combat:FireServer()
                    -- Skibx 模擬點擊適配
                    if keyclick then
                        VUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    else
                        VUser:CaptureController()
                        VUser:Button1Down(Vector2.new(1280, 672))
                    end
                end
            end)
        end
    end
end)

-- 4. 自動練等核心
local function GetCurrentQuest()
    local lvl = LP.Data.Level.Value
    local QuestData = {
        {Level = 0, Monster = "Bandit", QuestName = "BanditQuest1", QuestID = 1, NPCPos = Vector3.new(1059, 15, 1545)},
        {Level = 10, Monster = "Monkey", QuestName = "JungleQuest", QuestID = 1, NPCPos = Vector3.new(-1602, 36, 153)},
    }
    local q = QuestData[1]
    for _, v in ipairs(QuestData) do if lvl >= v.Level then q = v end end
    return q
end

task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                local q = GetCurrentQuest()
                local gui = LP.PlayerGui.Main.Quest
                
                if not gui.Visible or not string.find(gui.Container.QuestTitle.Title.Text, q.Monster) then
                    LP.Character.HumanoidRootPart.CFrame = CFrame.new(q.NPCPos)
                    task.wait(0.5)
                    RS.Remotes.CommF_:InvokeServer("StartQuest", q.QuestName, q.QuestID)
                else
                    local target = nil
                    for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if v.Name == q.Monster and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v
                            break
                        end
                    end
                    
                    if target then
                        local t = LP.Backpack:FindFirstChild(_G.SelectWeapon) or LP.Character:FindFirstChild(_G.SelectWeapon)
                        if t then LP.Character.Humanoid:EquipTool(t) end
                        LP.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, _G.FlyHeight, 0)
                        LP.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    else
                        LP.Character.HumanoidRootPart.CFrame = CFrame.new(q.NPCPos) * CFrame.new(0, 50, 0)
                    end
                end
            end)
        end
    end
end)

-- 5. 建立 UI
local Win = RedzLib:MakeWindow({
    Title = "🧋 珍奶腳本 | Skibx 專用版",
    SubTitle = "Professional Hub",
    SaveFolder = "MilkTeaSkibx"
})

local Main = Win:CreateTab("主要掛機", "rbxassetid://4483345998")

Main:AddToggle({
    Name = "全自動刷等 (極速)",
    Default = false,
    Callback = function(v) _G.AutoFarm = v end
})

Main:AddToggle({
    Name = "快速攻擊",
    Default = true,
    Callback = function(v) _G.FastAttack = v end
})

Main:AddSlider({
    Name = "懸浮高度",
    Min = 8, Max = 15, Default = 11,
    Callback = function(v) _G.FlyHeight = v end
})

Main:AddDropdown({
    Name = "選擇武器",
    Options = {"Melee", "Sword", "Fruit"},
    Default = "Melee",
    Callback = function(v) _G.SelectWeapon = v end
})

Win:SelectTab(Main)

-- Skibx 提示
print("🧋 珍奶腳本：成功適配 Skibx 注射器！")
