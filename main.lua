-- [[ 🧋 珍奶腳本 V6 | 一海畢業全自動版 ]]
-- [[ 功能：自動等級判定、自動接任務、空戰模式、自動加點 ]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- [[ 全域變數初始化 ]]
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

-- 獲取角色
local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end

-- 獲取當前任務
local function GetCurrentQuest()
    local myLevel = LP.Data.Level.Value
    local best = QuestData[1]
    for _, v in ipairs(QuestData) do
        if myLevel >= v.Level then best = v end
    end
    return best
end

-- 自動裝備武器
local function EquipWeapon()
    pcall(function()
        local tool = LP.Backpack:FindFirstChild(_G.SelectWeapon) or GetChar():FindFirstChild(_G.SelectWeapon)
        if tool and not GetChar():FindFirstChild(tool.Name) then
            GetChar().Humanoid:EquipTool(tool)
        end
    end)
end

-- 專業級 Tween 移動 (防踢模式)
local function BetterTween(targetCFrame)
    local root = GetChar():WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.p).Magnitude
    if dist < 15 then root.CFrame = targetCFrame return end
    
    local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(dist/300, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    
    -- 移動中關閉碰撞
    for _, v in pairs(GetChar():GetChildren()) do
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
                
                -- 檢測是否已有任務
                if not questUI.Visible or not string.find(questUI.Container.QuestTitle.Title.Text, q.Monster) then
                    -- 沒任務或任務不符 -> 飛去接任務
                    BetterTween(CFrame.new(q.NPCPos))
                    task.wait(0.5)
                    RS.Remotes.CommF_:InvokeServer("StartQuest", q.QuestName, q.QuestID)
                else
                    -- 有任務 -> 找怪
                    local targetMonster = nil
                    for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if v.Name == q.Monster and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMonster = v
                            break
                        end
                    end
                    
                    if targetMonster then
                        EquipWeapon()
                        -- 空戰懸浮鎖定
                        GetChar().HumanoidRootPart.CFrame = targetMonster.HumanoidRootPart.CFrame * CFrame.new(0, _G.FlyHeight, 0)
                        -- 自動攻擊
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                    else
                        -- 沒怪時飛到出生點等
                        BetterTween(CFrame.new(q.MonsterPos))
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- [[ 4. UI 介面設定 ]]
local Window = OrionLib:MakeWindow({
    Name = "🧋 珍奶腳本 | 一海畢業版", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "MilkTeaV6",
    IntroText = "珍奶腳本調配中..."
})

-- 自動掛機分頁
local Tab1 = Window:MakeTab({Name = "全自動掛機", Icon = "rbxassetid://4483345998"})

Tab1:AddToggle({
    Name = "開啟一海全自動練等",
    Default = false,
    Callback = function(v) _G.AutoFarm = v end
})

Tab1:AddSlider({
    Name = "空戰高度 (防怪打)",
    Min = 8, Max = 15, Default = 11,
    Callback = function(v) _G.FlyHeight = v end
})

Tab1:AddDropdown({
    Name = "使用武器類型",
    Default = "近戰 (Melee)",
    Options = {"近戰 (Melee)", "劍 (Sword)", "惡魔果實 (Fruit)", "槍 (Gun)"},
    Callback = function(Value)
        local map = {["近戰 (Melee)"]="Melee", ["劍 (Sword)"]="Sword", ["惡魔果實 (Fruit)"]="Fruit", ["槍 (Gun)"]="Gun"}
        _G.SelectWeapon = map[Value]
    end
})

-- 自動加點分頁
local Tab2 = Window:MakeTab({Name = "自動加點", Icon = "rbxassetid://4483345998"})

Tab2:AddToggle({
    Name = "開啟自動加點",
    Default = false,
    Callback = function(v) _G.AutoStats = v end
})

Tab2:AddDropdown({
    Name = "加點項目",
    Default = "近戰 (Melee)",
    Options = {"近戰 (Melee)", "防禦 (Defense)", "劍 (Sword)", "惡魔果實 (Fruit)", "槍 (Gun)"},
    Callback = function(Value)
        local map = {["近戰 (Melee)"]="Melee", ["防禦 (Defense)"]="Defense", ["劍 (Sword)"]="Sword", ["惡魔果實 (Fruit)"]="Fruit", ["槍 (Gun)"]="Gun"}
        _G.StatType = map[Value]
    end
})

-- 加點循環邏輯
task.spawn(function()
    while true do
        if _G.AutoStats then
            pcall(function()
                local p = LP.Data.StatsPoints.Value
                if p > 0 then RS.Remotes.CommF_:InvokeServer("AddPoint", _G.StatType, p) end
            end)
        end
        task.wait(1)
    end
end)

-- 工具分頁
local Tab3 = Window:MakeTab({Name = "輔助工具", Icon = "rbxassetid://4483345998"})
Tab3:AddButton({
    Name = "移除材質 (提升效能)",
    Callback = function()
        for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        end
    end
})
Tab3:AddButton({
    Name = "銷毀腳本",
    Callback = function() OrionLib:Destroy() end
})

OrionLib:Init()
