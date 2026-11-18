-- Mythic Boss Integration Installer
-- Run once from Roblox Studio's Command Bar after importing the 12 FBX rigs as Models.
-- Required setup:
--   ServerStorage/MythicBossAssets/<ModelName> (12 imported rigs)
--   Workspace/BiomeBossAnchors/<BiomeName> (one invisible Part at the desired end of each biome)
-- This is additive: it does not delete or replace the existing BossConfig/BossCombatService.

local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local ASSET_FOLDER_NAME = "MythicBossAssets"
local ANCHOR_FOLDER_NAME = "BiomeBossAnchors"
local OUTPUT_FOLDER_NAME = "IntegratedMythicBosses"
local BOSS_OFFSET = CFrame.new(0, 0, 0)
local RAISE_OWNER_MARKERS_BY = 5 -- studs above the current marker offset

-- Suggested biome distribution based on the names/themes of the supplied rigs.
-- Change a biome name here if your place uses a different exact name.
local BOSS_ASSIGNMENTS = {
    {model = "Blossom_Wolf", biome = "ThornwoodJungle"},
    {model = "Thorn_Rhino", biome = "ThornwoodJungle"},
    {model = "Crystal_Turtle", biome = "CrystalCaverns"},
    {model = "Celestial_Mantis", biome = "CrystalCaverns"},
    {model = "Abyss_Serpent", biome = "CrystalCaverns"},
    {model = "Ember_Lion", biome = "Volcano"},
    {model = "Magma_Golem", biome = "Volcano"},
    {model = "Solar_Phoenix", biome = "Volcano"},
    {model = "Glacier_Stag", biome = "Ice"},
    {model = "Lunar_Fox", biome = "Ice"},
    {model = "Royal_Griffin", biome = "Desert"},
    {model = "Storm_Dragon", biome = "Desert"},
}

local assets = ServerStorage:FindFirstChild(ASSET_FOLDER_NAME)
assert(assets, "Create ServerStorage/" .. ASSET_FOLDER_NAME .. " and put the imported rig Models inside it.")
local anchors = Workspace:FindFirstChild(ANCHOR_FOLDER_NAME)
assert(anchors, "Create Workspace/" .. ANCHOR_FOLDER_NAME .. " with one Part at the far end of each biome.")

local output = Workspace:FindFirstChild(OUTPUT_FOLDER_NAME)
if not output then
    output = Instance.new("Folder")
    output.Name = OUTPUT_FOLDER_NAME
    output.Parent = Workspace
end

local function findRoot(model)
    if model.PrimaryPart then return model.PrimaryPart end
    local root = model:FindFirstChild("HumanoidRootPart", true)
        or model:FindFirstChild("Root", true)
        or model:FindFirstChildWhichIsA("BasePart", true)
    if root and root:IsA("BasePart") then
        model.PrimaryPart = root
        return root
    end
    return nil
end

local function raiseOwnerMarkers()
    local count = 0
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("BillboardGui") then
            local n = string.lower(item.Name)
            if string.find(n, "owner") or string.find(n, "marker") then
                local old = item.StudsOffset
                item.StudsOffset = Vector3.new(old.X, old.Y + RAISE_OWNER_MARKERS_BY, old.Z)
                count += 1
            end
        end
    end
    return count
end

local placed, skipped = {}, {}
for _, spec in ipairs(BOSS_ASSIGNMENTS) do
    local source = assets:FindFirstChild(spec.model)
    local anchor = anchors:FindFirstChild(spec.biome)
    if not source or not source:IsA("Model") then
        table.insert(skipped, spec.model .. " (missing imported Model)")
    elseif not anchor or not anchor:IsA("BasePart") then
        table.insert(skipped, spec.model .. " (missing anchor Part: " .. spec.biome .. ")")
    else
        local existing = output:FindFirstChild(spec.model)
        if existing then existing:Destroy() end
        local boss = source:Clone()
        boss.Name = spec.model
        boss:SetAttribute("IntegratedMythicBoss", true)
        boss:SetAttribute("BiomeName", spec.biome)
        boss:SetAttribute("BossRole", "BiomeBoss")
        local root = findRoot(boss)
        boss.Parent = output
        boss:PivotTo(anchor.CFrame * BOSS_OFFSET)
        table.insert(placed, spec.model .. " -> " .. spec.biome)
        if not root then
            warn("[MythicBossInstaller] " .. spec.model .. " has no BasePart root; verify its FBX import before enabling chase.")
        end
    end
end

local markerCount = raiseOwnerMarkers()
print("[MythicBossInstaller] Installed " .. #placed .. " bosses; raised " .. markerCount .. " owner/marker BillboardGui(s) by " .. RAISE_OWNER_MARKERS_BY .. " studs.")
for _, line in ipairs(placed) do print("  + " .. line) end
for _, line in ipairs(skipped) do warn("  - " .. line) end
print("[MythicBossInstaller] Existing BossCombatService was left untouched to avoid running two competing chase controllers.")
