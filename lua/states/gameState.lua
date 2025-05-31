---@class GameState megaclass for game state
---@field sceneManager SceneManager
---@field drawer Drawer

local GameState = {}
GameState.__index = GameState

function GameState:init(drawer, sceneManager)
    self.drawer = drawer
    self.sceneManager = sceneManager
end

return GameState