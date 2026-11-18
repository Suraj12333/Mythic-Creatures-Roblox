-- BossChaseOptimization.lua
-- Additive helper module for the existing BossCombatService.
-- It centralizes target scans and path recomputation throttling; wire these helpers
-- into the existing boss controller rather than running a second movement controller.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Optimizer = {}
Optimizer.SCAN_INTERVAL = 0.45       -- one target scan per boss at most every 0.45s
Optimizer.REPATH_INTERVAL = 1.10     -- avoid recalculating paths every frame
Optimizer.REPATH_DISTANCE = 10       -- repath if target moved at least this far
Optimizer.MAX_TARGET_DISTANCE = 260  -- studs; tune to your biome scale
Optimizer._nextScan = setmetatable({}, {__mode = "k"})
Optimizer._nextPath = setmetatable({}, {__mode = "k"})
Optimizer._lastTargetPosition = setmetatable({}, {__mode = "k"})
Optimizer._targetCache = setmetatable({}, {__mode = "k"})

local function getCharacterRoot(player)
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then return nil end
    return root
end

function Optimizer.GetTarget(boss, origin, now)
    now = now or os.clock()
    if now < (Optimizer._nextScan[boss] or 0) then
        return Optimizer._targetCache[boss]
    end
    Optimizer._nextScan[boss] = now + Optimizer.SCAN_INTERVAL

    local bestPlayer, bestRoot, bestDistance = nil, nil, Optimizer.MAX_TARGET_DISTANCE
    for _, player in ipairs(Players:GetPlayers()) do
        local root = getCharacterRoot(player)
        if root then
            local distance = (root.Position - origin).Magnitude
            if distance < bestDistance then
                bestPlayer, bestRoot, bestDistance = player, root, distance
            end
        end
    end
    Optimizer._targetCache[boss] = bestPlayer and {Player = bestPlayer, Root = bestRoot, Distance = bestDistance} or nil
    return Optimizer._targetCache[boss]
end

function Optimizer.ShouldRepath(boss, targetPosition, now)
    now = now or os.clock()
    local previous = Optimizer._lastTargetPosition[boss]
    if now < (Optimizer._nextPath[boss] or 0) then
        return false
    end
    if previous and (targetPosition - previous).Magnitude < Optimizer.REPATH_DISTANCE then
        return false
    end
    Optimizer._nextPath[boss] = now + Optimizer.REPATH_INTERVAL
    Optimizer._lastTargetPosition[boss] = targetPosition
    return true
end

function Optimizer.Forget(boss)
    Optimizer._nextScan[boss] = nil
    Optimizer._nextPath[boss] = nil
    Optimizer._lastTargetPosition[boss] = nil
    Optimizer._targetCache[boss] = nil
end

return Optimizer
