---@class macime.Config.Save
---@field global? boolean

---@class macime.Config.Ime
---@field default? string

---@class macime.Config.Exclude
---@field filetype? string[]

---@class macime.Config
---@field ttimeoutlen? number
---@field ime? macime.Config.Ime
---@field save? macime.Config.Save
---@field pattern? string|string[]
---@field exclude? macime.Config.Exclude
