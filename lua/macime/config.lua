local M = {}

---@type macime.Config
M.defaults = {
   vim = {
      ttimeoutlen = nil,
   },
   ime = {
      default = 'com.apple.keylayout.ABC',
      cjk_refresh = false,
   },
   save = {
      enabled = true,
      scope = 'session',
   },
   socket = {
      enabled = false,
      path = '/tmp/riodelphino.macimed.sock',
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
