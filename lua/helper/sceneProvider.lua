local FishingScene = require "lua.scenes.fishingScene"

---@class SceneProvider
---@field storeScene StoreScene
---@field pcScene PcScene
---@field fishingScene FishingScene

local SceneProvider = {}

SceneProvider.fishingScene = FishingScene

return SceneProvider