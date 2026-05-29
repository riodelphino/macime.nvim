local M = {}

---@type macime.Config
M.defaults = {
   vim = {
      ttimeoutlen = nil,
   },
   ime = {
      default = 'com.apple.keylayout.ABC',
      cjk_refresh = false,
      cjk_delay = nil,
   },
   save = {
      enabled = true,
      scope = 'session',
      exclusive = {
         filetype = {},
      },
   },
   socket = {
      enabled = false,
      path = '/tmp/riodelphino.macimed.sock',
      log_level = 'info',
   },
   include = {
      pattern = nil,
   },
   exclude = {
      filetype = {},
   },
}

---@type macime.Config
M.opts = {}

return M
