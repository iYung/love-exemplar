---@meta
---@class Camera
---@field x number
---@field y number

---@class Drawer
---@field camera Camera
local Drawer = {}

Drawer.jobs = {}

Drawer.camera = { x = 0, y = 0 }

function Drawer.clear()
    Drawer.jobs = {}
end

---@param height number
---@param sprite love.Image
---@param x number
---@param y number
---@param sx? number
---@param sy? number
---@param shader? love.Shader
---@param shaderParams? table
function Drawer:add(height, sprite, x, y, sx, sy, shader, shaderParams)
    if Drawer.jobs[height] == nil then
        Drawer.jobs[height] = {}
    end
    local scaleX = sx or 1
    local scaleY = sy or 1.0
    table.insert(Drawer.jobs[height], {
        sprite = sprite,
        x = x - self.camera.x,
        y = y - self.camera.y,
        sx = scaleX,
        sy = scaleY,
        shader = shader,
        shaderParams = shaderParams
    })
end

---@param height number
---@param text love.Text
---@param x number
---@param y number
---@param color? table
function Drawer:addText(height, text, x, y, color, sx, sy)
    if Drawer.jobs[height] == nil then
        Drawer.jobs[height] = {}
    end
    table.insert(Drawer.jobs[height], {
        text = text,
        x = x,
        y = y,
        sx = sx or 1,
        sy = sy or 1,
        color = color
    })
end

function Drawer:draw()
    local keys = {}
    for k, _ in pairs(Drawer.jobs) do  -- _ is used to discard the value
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b) return a > b end)
    for _, key in ipairs(keys) do
        for _, job in ipairs(Drawer.jobs[key]) do
            if job.sprite ~= nil then
                if job.shader ~= nil then
                    love.graphics.setShader(job.shader)
                    if job.shaderParams ~= nil then
                        for key, value in pairs(job.shaderParams) do
                            job.shader:send(key, value)
                        end         
                    end
                end
                love.graphics.setDefaultFilter("nearest", "nearest")
                love.graphics.draw(job.sprite, job.x, job.y, 0, job.sx, job.sy)
                if job.shader ~= nil then
                    love.graphics.setShader()
                end
            end
            if job.text ~= nil then
                local r, g, b
                if job.color ~= nil then
                    r, g, b = love.graphics.getColor()
                    love.graphics.setColor(job.color.r, job.color.g, job.color.b)
                end
                love.graphics.draw(job.text, job.x, job.y, 0, job.sx, job.sy)
                -- debug box
                -- love.graphics.rectangle("line", job.x, job.y, job.text:getWidth() * job.sx,job.text:getHeight() * job.sy)
                if job.color ~= nil then
                    love.graphics.setColor(r, g, b)
                end
            end
          end
    end
    Drawer.clear()
end

return Drawer