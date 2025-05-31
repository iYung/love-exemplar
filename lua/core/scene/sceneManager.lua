---@class SceneManager
---@field scene Scene
local SceneManager = {}
SceneManager.__index = SceneManager

---@param scene Scene
function SceneManager:load(scene, ...)
    self.scene = scene
    self.scene:load(self, ...)
end

function SceneManager:update(dt)
    self.scene:update(dt)
end

function SceneManager:draw()
    self.scene:draw()
end

return SceneManager