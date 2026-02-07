---macime.Config
---@class macime.Config
---@field vim? macime.Config.Vim
---@field ime? macime.Config.Ime
---@field save? macime.Config.Save
---@field socket? macime.Config.Socket
---@field include? macime.Config.Include
---@field exclude? macime.Config.Exclude

---@class macime.Config.Vim
---@field ttimeoutlen? number

---@class macime.Config.Save
---@field enabled? boolean
---@field scope? "global"|"session"

---@class macime.Config.Socket
---@field enabled? boolean
---@field path? string

---@class macime.Config.Ime
---@field default? string
---@field cjk_refresh? boolean

---@class macime.Config.Include
---@field pattern? string|string[]

---@class macime.Config.Exclude
---@field filetype? string[]

---macime.Context
---@class macime.Context
---@field macime macime.Context.Macime
---@field macimed macime.Context.Macimed
---@field capability macime.Context.Capability

---@class macime.Context.Macime
---@field installed boolean
---@field version string

---@class macime.Context.Macimed
---@field installed boolean
---@field version string
---
---@class macime.Context.Capability
---@field macime_direct boolean -- `macime` >= 3.2.0
---@field macimed_daemon boolean -- `macime` >= 3.2.0
---@field cjk_refresh boolean -- `macime` >= 3.5.0
---@field daemon_socket_api boolean -- `macime` >= 3.6.0

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
---@field capability_daemon? boolean
---@field capability_cjk_refresh? boolean
---@field capability_daemon_socket_api? boolean
---@field service_name? string
---@field service_status? string
---@field service_user? string
---@field service_file? string
---@field service_out? string
---@field service_err? string
---@field service_daemon? string
---@field plist? table<string, any>
