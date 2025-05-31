local Sprite = require "lua.core.render.sprite"

---@class SpriteSet
---@field sprites Sprite[] arrays of Sprites
---@field currentSprite number
---@field shader love.Shader
local SpriteSet = {}
SpriteSet.__index = SpriteSet

---@return SpriteSet
function SpriteSet:new()
  local newSS = {}
  setmetatable(newSS, SpriteSet)
  newSS.__index = SpriteSet

  newSS.sprites = {}
  for key, value in pairs(self.sprites or {}) do
    newSS.sprites[key] = value:new()
  end

  newSS.currentSprite = self.currentSprite
  newSS.shader = self.shader

  return newSS
end

---comment
---@param drawer Drawer
---@param shader? love.Shader
---@param ... love.Image images
function SpriteSet:load(drawer, shader, ...)
  local varargs = {...} -- Collect varargs into a table
  local numVarargs = #varargs -- Get the number of varargs

  if shader ~= nil then
    self.shader = shader
  end

  self.sprites = {}
  for i = 1, numVarargs do
    self.sprites[i] = Sprite:new()
    self.sprites[i]:load(drawer, varargs[i])
  end
  self.currentSprite = 1
end

---@param h number
---@param x number
---@param y number
---@param sx? number
---@param sy? number
function SpriteSet:draw(h, x, y, sx, sy)
  self:getSprite():draw(h, x, y, sx, sy)
end

---comment
---@return Sprite
function SpriteSet:getSprite()
  return self.sprites[self.currentSprite]
end

return SpriteSet