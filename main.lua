local push = require "lua.libs.push"
local Consts = require "lua.enums.constants"
local windowWidth, windowHeight = love.window.getDesktopDimensions()

local SceneManager = require "lua.core.scene.sceneManager"

local drawer = require "lua.core.render.drawer"

local gameState = require "lua.states.gameState"

SceneProvider = require "lua.helper.sceneProvider"

local newFont = love.graphics.newFont("assets/fonts/MouldyCheeseRegular-WyMWG.ttf", Consts.DEFAULT_FONT_SIZE)
newFont:setFilter("nearest", "nearest")
love.graphics.setFont(newFont)

love.graphics.setDefaultFilter("nearest")

push:setupScreen(Consts.GAME_WIDTH, Consts.GAME_HEIGHT, windowWidth/2, windowHeight/2, {fullscreen = false})

function love.conf(t)
  t.console = true  -- Enable the console
end

function love.load()
  love.window.setTitle("My Awesome Game") -- Sets window title

  gameState:init(drawer, SceneManager)

  SceneManager:load(SceneProvider.fishingScene, gameState)
end

function love.update(dt)
  SceneManager:update(dt)
end

function love.draw()
  push:start()
  love.graphics.clear(0.5, 0.5, 0.5) -- light gray

  SceneManager:draw()
  drawer.draw()
  push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end