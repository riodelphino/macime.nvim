---macime.Config
---@class macime.Config.Save
---@field global? boolean

---@class macime.Config.Service
---@field enabled? boolean
---@field sock_path? string

---@class macime.Config.Ime
---@field default? string

---@class macime.Config.Exclude
---@field filetype? string[]

---@class macime.Config
---@field ttimeoutlen? number
---@field ime? macime.Config.Ime
---@field save? macime.Config.Save
---@field service? macime.Config.Service
---@field pattern? string|string[]
---@field exclude? macime.Config.Exclude

---macime.Health
---@class macime.Health
---@field ime_default_ok? boolean
---@field macime_installed? boolean
---@field macime_version? string
---@field macimed_installed? boolean
---@field macimed_version? string
---@field macimed_running? boolean
---@field macimed_sock_path? string
---@field macimed_log_path? string
---@field macimed_err_path? string
---@field capability_general? boolean
---@field capability_launchd? boolean
---@field service_name? string
---@field service_status? string
---@field service_user? string
---@field service_file? string
