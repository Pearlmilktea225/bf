local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- [[ 全域設定 ]]
_G.AutoFarm = false
_G.AutoStats = false
_G.SelectWeapon = "Melee"
_G.StatType = "Melee"
_G.FlyHeight = 11

-- [[ 1. 一海完整任務數據庫 ]]
local QuestData = {
    {Level = 0, Monster = "Bandit", QuestName = "BanditQuest1", QuestID = 1, NPCPos = Vector3.new(1059, 15, 1545), MonsterPos = Vector3.new(1145, 15, 1580)},
    {Level = 10, Monster = "Monkey", QuestName = "JungleQuest", QuestID = 1, NPCPos = Vector3.new(-1602, 36, 153), MonsterPos = Vector3.new(-1610, 36, 147)},
    {Level = 30, Monster = "Gorilla", QuestName = "JungleQuest", QuestID = 2, NPCPos = Vector3.new(-1602, 36, 153), MonsterPos = Vector3.new(-1200, 36, -500)},
    {Level = 60, Monster = "Snowman", QuestName = "SnowQuest", QuestID = 2, NPCPos = Vector3.new(1385, 87, -1297), MonsterPos = Vector3.new(1289, 105, -1342)},
    {Level = 120, Monster = "Chief Petty Officer", QuestName = "MarineQuest2", QuestID = 1, NPCPos = Vector3.new(-4839, 21, 4359), MonsterPos = Vector3.new(-4840, 21, 4500)},
    {Level = 210, Monster = "Shaman", QuestName = "SkyQuest", QuestID = 2, NPCPos = Vector3.new(-4839, 717, -2618), MonsterPos = Vector3.new(-4900, 717, -2600)},
    {Level = 350, Monster = "Magma Village", QuestName = "MagmaQuest", QuestID = 1, NPCPos = Vector3.new(-5313, 12, 8515), MonsterPos = Vector3.new(-5300, 12, 8600)},
    {Level = 500, Monster = "Underwater Guard", QuestName = "FishmanQuest", QuestID = 1, NPCPos = Vector3.new(61122, 18, 1568), MonsterPos = Vector3.new(61100, 18, 1650)},
    {Level = 625, Monster = "Galley Pirate", QuestName = "FountainQuest", QuestID = 1, NPCPos = Vector3.new(5259, 38, 4050), MonsterPos = Vector3.new(5300, 38, 4100)}
}

-- [[ 2. 核心功能函數 ]]
local function GetCurrentQuest()
    local myLevel = LP.Data.Level.Value
    local best = QuestData[1]
    for _, v in ipairs(QuestData) do
        if myLevel >= v.Level then best = v end
    end
    return best
end

local function EquipWeapon()
    pcall(function()
        local tool = LP.Backpack:FindFirstChild(_G.SelectWeapon) or LP.Character:FindFirstChild(_G.SelectWeapon)
        if tool and not LP.Character:FindFirstChild(tool.Name) then
            LP.Character.Humanoid:EquipTool(tool)
        end
    end)
end

-- 專業級移動：移動時角色透明且無碰撞
local function BetterTween(targetCFrame)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.p).Magnitude
    
    if dist < 20 then root.CFrame = targetCFrame return end
    
    local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(dist/300, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
    
    tween:Play()
    tween.Completed:Wait()
end

-- [[ 3. 主循環：全自動任務練等 ]]
task.spawn(function()
    while true do
        if _G.AutoFarm then
            pcall(function()
                local q = GetCurrentQuest()
                local questUI = LP.PlayerGui.Main.Quest
                
                -- 如果沒任務
                if not questUI.Visible or not string.find(questUI.Container.QuestTitle.Title.Text, q.Monster) then
                    -- 飛去 NPC 接任務
                    BetterTween(CFrame.new(q.NPCPos))
                    task.wait(0.5)
                    RS.Remotes.CommF_:InvokeServer("StartQuest", q.QuestName, q.QuestID)
                else
                    -- 有任務，飛去刷怪
                    local targetMonster = nil
                    for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if v.Name == q.Monster and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMonster = v
                            break
                        end
                    end
                    
                    if targetMonster then
                        EquipWeapon()
                        LP.Character.HumanoidRootPart.CFrame = targetMonster.HumanoidRootPart.CFrame * CFrame.new(0, _G.FlyHeight, 0)
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                    else
                        -- 怪沒了，飛回怪點中心等怪
                        BetterTween(CFrame.new(q.MonsterPos))
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- [[ 4. UI 介面設定 ]]
local Window = OrionLib:MakeWindow({Name = "🧋 珍奶腳本 | 一海畢業版", HidePremium = false, SaveConfig = true, ConfigFolder = "MilkTeaV6"})

local Tab1 = Window:MakeTab({Name = "自動掛機", Icon = "rbxassetid://4483345998"})
Tab1:AddToggle({
    Name = "開啟一海全自動練等",
    Default = false,
    Callback = function(v) _G.AutoFarm = v end
})
Tab1:AddSlider({
    Name = "懸浮高度",
    Min = 8, Max = 15, Default = 11,
    Callback = function(v) _G.FlyHeight = v end
})
Tab1:AddDropdown({
    Name = "使用武器",
    Default = "Melee",
    Options = {"Melee", "Sword", "Fruit", "Gun"},
    Callback = function(v) _G.SelectWeapon = v end
})

local Tab2 = Window:MakeTab({Name = "自動加點", Icon = "rbxassetid://4483345998"})
Tab2:AddToggle({Name = "自動加點開關", Default = false, Callback = function(v) _G.AutoStats = v end})
Tab2:AddDropdown({
    Name = "加點類型",
    Default = "Melee",
    Options = {"Melee", "Defense", "Sword", "Fruit", "Gun"},
    Callback = function(v) _G.StatType = v end
})

-- 自動加點循環
task.spawn(function()
    while true do
        if _G.AutoStats then
            local p = LP.Data.StatsPoints.Value
            if p > 0 then RS.Remotes.CommF_:InvokeServer("AddPoint", _G.StatType, p) end
        end
        task.wait(1)
    end
end)

OrionLib:Init()
