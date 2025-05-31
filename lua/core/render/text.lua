---@class Text
---@field text love.Text
---@field drawer Drawer
---@field width number
---@field height number
---@field color? table
---@field size? number
local Text = {}
Text.__index = Text

function Text:new()
  local newText = setmetatable({}, Text)
  newText.drawer = self.drawer
  newText.width = self.width
  newText.height = self.height
  newText.color = self.color
  newText.text = self.text
  return newText
end

---@param drawer Drawer
---@param text string
---@param color? table
---@param size? number
function Text:load(drawer, text, color, size)
    self:updateText(text)
    self.drawer = drawer
    self.color = color
    self.size = size or 25
end

function Text:updateText(text)
  self.text = love.graphics.newText(love.graphics.getFont(), text)
  self.width = self.text:getWidth()
  self.height = self.text:getHeight()
end

---@param h number
---@param x number
---@param y number
function Text:draw(h, x, y)
  self.drawer.addText(h, self.text, x, y, self.color, self.size / 25, self.size / 25)
end

return Text