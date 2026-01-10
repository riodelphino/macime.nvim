require('macime.types')

local M = {}

---@type macime.Config
local defaults = {
   ttimeoutlen = nil,
   ime = {
      default = 'com.apple.keylayout.ABC',
   },
   save = {
      global = false,
   },
   pattern = nil,
   exclude = {
      filetype = {},
   },
}

---@type macime.Config
local opts = {}

---@return string session_id
local function get_session_id()
   local session_id = 'nvim-' .. vim.fn.getpid()
   return session_id
end

---@return table args
local function get_save_args()
   if opts.save.global then
      args = { 'set', opts.ime.default, '--save' }
   else
      args = { 'set', opts.ime.default, '--save', '--session-id', get_session_id() }
   end
   return args
end

---@return table args
local function get_load_args()
   if opts.save.global then
      args = { 'load' }
   else
      args = { 'load', '--session-id', get_session_id() }
   end
   return args
end

---@param filetype string
---@return boolean allowed
local function is_excluded_filetype(filetype)
   local is_excluded = vim.tbl_contains(opts.exclude.filetype, filetype)
   return is_excluded
end

local function add_autocmd()
   local augroup = vim.api.nvim_create_augroup('MacIME', {})

   vim.api.nvim_create_autocmd('InsertLeave', {
      group = augroup,
      pattern = opts.pattern,
      desc = 'macime.nvim - Save current IME & switch to the `default` IME',
      callback = function()
         local buf_allowed = not is_excluded_filetype(vim.bo.filetype)
         if buf_allowed then vim.loop.spawn('macime', {
            args = get_save_args(),
            stdio = { nil, nil, nil },
            detach = true,
         }) end
      end,
   })
   vim.api.nvim_create_autocmd('InsertEnter', {
      group = augroup,
      desc = 'macime.nvim - Restore previous IME',
      pattern = opts.pattern,
      callback = function()
         local buf_allowed = not is_excluded_filetype(vim.bo.filetype)
         if buf_allowed then vim.loop.spawn('macime', {
            args = get_load_args(),
            stdio = { nil, nil, nil },
            detach = true,
         }) end
      end,
   })
end

---@param user_config macime.Config
function M.setup(user_config)
   local macime_exists = (vim.fn.executable('macime') == 1)
   if not macime_exists then
      local msg = '\n\nThe `macime` command was not found.\n\nPlease install it first:\n   brew tap riodelphino/tap\n   brew install riodelphino/tap/macime'
      error(msg, vim.log.levels.ERROR)
   end
   opts = vim.tbl_deep_extend('force', defaults, user_config)
   if opts.ttimeoutlen then vim.o.ttimeoutlen = opts.ttimeoutlen end
   add_autocmd()
end

return M
