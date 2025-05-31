---@meta

---@class Timer
---@field expired boolean
---@field completeCallback function
---@field progressCallback function
---@field time number
---@field startTime number
local Timer = {}
Timer.__index = Timer

function Timer:new(time, completeCallback, progressCallback)
  local newTimer = setmetatable({}, Timer)
  newTimer.expired = false
  newTimer.completeCallback = completeCallback
  newTimer.progressCallback = progressCallback
  newTimer.time = time
  newTimer.startTime = time
  return newTimer
end

function Timer:update(dt)
    if self.time < 0 then
        self.expired = true
        if self.completeCallback then
            self.completeCallback()
        end 
    end
    self.time = self.time - dt
    if self.progressCallback then
        self.progressCallback()
    end 
end

function Timer:isExpired()
   return self.expired
end

return Timer