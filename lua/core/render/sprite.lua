---@meta

---@class Sprite
---@field width number
---@field height number
---@field image love.Image
---@field drawer Drawer
---@field new function(): Sprite
---@field load function(image: love.Image): nil
---@field draw function(drawer: Drawer, priority: number, x: number, y: number, sx?: number, sy?: number): nil
---@field drawAlso function(drawer: Drawer, priority: number, x: number, y: number): nil callback to draw on top of this sprite
---@field shader? love.Shader
---@field shaderParams? table
local Sprite = {}
Sprite.__index = Sprite

function Sprite:new()
  local newSprite = setmetatable({}, Sprite)
  newSprite.drawer = self.drawer
  newSprite.image = self.image
  newSprite.height = self.height
  newSprite.width = self.width
  newSprite.shader = self.shader
  return newSprite
end

---@param drawer Drawer
---@param image love.Image
function Sprite:load(drawer, image)
    self.image = image
    self.width = image:getWidth()
    self.height = image:getHeight()
    self.drawer = drawer
end

---@param h number
---@param x number
---@param y number
---@param sx? number
---@param sy? number
function Sprite:draw(h, x, y, sx, sy)
  self.drawer.add(h, self.image, x, y, sx, sy, self.shader, self.shaderParams)
  if self.drawAlso ~= nil then
    self:drawAlso(h, x, y, sx, sy)
  end
end

---@param shader? love.Shader
---@param shaderParams? table
function Sprite:applyShader(shader, shaderParams)
  self.shader = shader
  self.shaderParams = shaderParams
end

return Sprite