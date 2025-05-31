---@class FishingScene: Scene
---@field spawnTimer Timer
---@field hasStarted boolean

local SpriteSet = require "lua.core.render.spriteSet"

local sea = SpriteSet:new()

local FishingScene = {}
FishingScene.__index = FishingScene

---@param sceneManager SceneManager
---@param gameState GameState
function FishingScene:load(sceneManager, gameState)
    sea:load(gameState.drawer, nil, love.graphics.newImage("assets/sprite/sea.png"))
end

---@param dt number The time elapsed since the last frame.
function FishingScene:update(dt)
end

function FishingScene:draw()
    sea:draw(1000, 0, 0)
end

return FishingScene