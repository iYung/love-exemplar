local SceneManager = require("core/lua/scene_manager")
local GameScene    = require("game/scenes/game_scene")

local manager = SceneManager.new()

function love.load()
    love.window.setMode(1280, 720)
    love.window.setTitle("Love Exemplar")
    manager:switch(GameScene.new())
end

function love.update(dt)
    manager:update(dt)
end

function love.draw()
    manager:draw()
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
