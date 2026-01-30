local M = {}

---@type macime.Config
M.defaults = {
   ttimeoutlen = nil,
   ime = {
      default = 'com.apple.keylayout.ABC',
   },
   save = {
      global = false,
   },
   service = {
      enabled = false,
      sock_path = '/tmp/riodelphino.macimed.sock',
   },
   pattern = nil,
   exclude = {
      filetype = {},
   },
}

---@type macime.Config
M.opts = {}

return M
