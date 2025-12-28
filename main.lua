-- [[ 🧋 珍奶腳本 V11 | 絕對啟動版 ]]
-- [[ 自動適配：Solara, Skibx, Delta, Fluxus, Hydrogen, Wave ]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

-- [[ 1. 強制環境修復 (針對爛注射器) ]]
if not game:IsLoaded() then game.Loaded:Wait() end

-- 檢測 HTTP 請求函數
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not request then
    -- 如果注射器太爛連 request 都沒有，嘗試用 game:HttpGet
    getgenv().request = function(args)
        return {Body = game:HttpGet(args.Url)}
    end
end

-- [[ 2. 多重線路 UI 加載器 (保證 UI 出現) ]]
local RedzLib
local success, result = pcall(function()
    -- 線路 1: 官方源
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/RedzLibV5/main/Source.lua"))()
end)

if success then
    RedzLib = result
else
    -- 線路 2: 備用源 (如果線路 1 失敗)
    warn("主線路失敗，正在切換備用線路...")
    local success2, result2 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonh02/RedzLib/main/Source.lua"))()
    end)
    if success2 then
        RedzLib = result2
    else
        -- 線路 3: 最終備用 (Orion) - 防止完全沒畫面
        warn("RedzLib 失敗，切換至 Orion...")
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
        return -- 終止 Redz 邏輯，改用 Orion (極少發生)
    end
end

-- [[ 3. 腳本全域設定 ]]
getgenv().Config = {
    AutoFarm = false,
    FastAttack = true,
    AutoBuso = true,
    SelectWeapon = "Melee",
    FlyHeight = 11
}

-- [[ 4. 極速攻擊系統 (適配所有設備) ]]
task.spawn(function()
    while task.wait() do
        if getgenv().Config.AutoFarm and getgenv().Config.FastAttack then
            pcall(function()
                -- 自動霸氣
                if getgenv().Config.AutoBuso and not LP.Character:FindFirstChild("HasBuso") then
                    RS.Remotes.CommF_:InvokeServer("Buso")
                end
                
                -- 攻擊封包
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if tool then
                    RS.Remotes.Sub.Combat:FireServer()
                    -- 雙重模擬點擊 (確保手機與PC都能揮刀)
                    VUser:CaptureController()
                    VUser:Button1Down(Vector2.new(1280, 672)) 
                    VUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
        end
    end
end)

-- [[ 5. 智能練等邏輯 ]]
local function GetCurrentQuest()
    local lvl = LP.Data.Level.Value
    -- 這裡只列出部分，可自行擴充
    local QuestData = {
        {Level = 0, Monster = "Bandit", QuestName = "BanditQuest1", QuestID = 1, NPCPos = Vector3.new(1059, 15, 1545)},
        {Level = 10, Monster = "Monkey", QuestName = "JungleQuest", QuestID = 1, NPCPos = Vector3.new(-1602, 36, 153)},
        {Level = 30, Monster = "Gorilla", QuestName = "JungleQuest", QuestID = 2, NPCPos = Vector3.new(-1602, 36, 153)},
        {Level = 60, Monster = "Snowman", QuestName = "SnowQuest", QuestID = 2, NPCPos = Vector3.new(1385, 87, -1297)},
    }
    local q = QuestData[1]
    for _, v in ipairs(QuestData) do if lvl >= v.Level then q = v end end
    return q
end

task.spawn(function()
    while task.wait() do
        if getgenv().Config.AutoFarm then
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
                        local t = LP.Backpack:FindFirstChild(getgenv().Config.SelectWeapon) or LP.Character:FindFirstChild(getgenv().Config.SelectWeapon)
                        if t then LP.Character.Humanoid:EquipTool(t) end
                        
                        -- 懸浮鎖定 (CFrame)
                        LP.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Config.FlyHeight, 0)
                        LP.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    else
                        LP.Character.HumanoidRootPart.CFrame = CFrame.new(q.NPCPos) * CFrame.new(0, 50, 0)
                    end
                end
            end)
        end
    end
end)

-- [[ 6. 建立 UI (Redz Style) ]]
if RedzLib then
    local Win = RedzLib:MakeWindow({
        Title = "🧋 珍奶腳本 | 萬能修復版",
        SubTitle = "Universal Fix V11",
        SaveFolder = "MilkTeaFixed"
    })

    local Main = Win:CreateTab("自動掛機", "rbxassetid://4483345998")

    Main:AddToggle({
        Name = "開啟全自動刷等",
        Default = false,
        Callback = function(v) getgenv().Config.AutoFarm = v end
    })

    Main:AddToggle({
        Name = "極速攻擊 (Fast Attack)",
        Default = true,
        Callback = function(v) getgenv().Config.FastAttack = v end
    })

    Main:AddSlider({
        Name = "懸浮高度",
        Min = 8, Max = 15, Default = 11,
        Callback = function(v) getgenv().Config.FlyHeight = v end
    })

    Main:AddDropdown({
        Name = "武器選擇",
        Options = {"Melee", "Sword", "Fruit"},
        Default = "Melee",
        Callback = function(v) getgenv().Config.SelectWeapon = v end
    })
    
    Win:SelectTab(Main)
    
    -- 發送成功通知
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "珍奶腳本",
        Text = "載入成功！",
        Duration = 5
    })
end
