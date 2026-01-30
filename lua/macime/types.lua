---macime.Config
---@class macime.Config.Vim
---@field ttimeoutlen? number

---@class macime.Config.Save
---@field global? boolean

---@class macime.Config.Socket
---@field enabled? boolean
---@field path? string

---@class macime.Config.Ime
---@field default? string

---@class macime.Config.Include
---@field pattern? string|string[]

---@class macime.Config.Exclude
---@field filetype? string[]

---@class macime.Config
---@field vim? macime.Config.Vim
---@field ime? macime.Config.Ime
---@field save? macime.Config.Save
---@field socket? macime.Config.Socket
---@field include? macime.Config.Include
---@field exclude? macime.Config.Exclude

---macime.Health
---@class macime.Health
---@field ime_default_ok? boolean
---@field macime_installed? boolean
---@field macime_version? string
---@field macimed_installed? boolean
---@field macimed_version? string
---@field macimed_status? string
---@field macimed_sock_path? string
---@field macimed_macime_path? string
---@field capability_direct? boolean
---@field capability_socket? boolean
---@field service_name? string
---@field service_status? string
---@field service_user? string
---@field service_file? string
---@field plist_keepalive? boolean
---@field plist_runatload? boolean
---@field plist_macime? string
---@field plist_cmd? string
---@field plist_stderr? string
---@field plist_stdlog? string
