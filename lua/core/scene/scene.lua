---@class Scene
---@field sceneManager SceneManager
--- Base class for scenes in the game.

local Scene = {}
Scene.__index = Scene

---@param dt number The time elapsed since the last frame.
function Scene:update(dt)
end

function Scene:draw()
end

---@param sceneManager SceneManager pass an instance of scene manager to handle new scenes
function Scene:load(sceneManager)
  self.sceneManager = sceneManager
end

return Scene