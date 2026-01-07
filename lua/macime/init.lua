local M = {}

local defaults = {
   save_as = {
      global = false, -- true|false: Save prev IME as globaly or per session_id
   },
   ime = {
      default = 'com.apple.keylayout.ABC', -- The default IME set in 'InsertLeave'
   },
   excludes = {
      filetype = {}, -- Exclude specific filetypes (e.g. 'TelescopePrompt', 'snacks_picker_input' )
   },
   ttimeoutlen = nil, -- If set, overwrite `vim.o.ttimeoutlen`. (Recommend: 0 - 50)
}

local opts = {}

---@param user_config table
function M.setup(user_config)
   opts = vim.tbl_deep_extend('force', defaults, user_config)
   if opts.ttimeoutlen then vim.o.ttimeoutlen = opts.ttimeoutlen end
   M.add_autocmd()
end

---@return string session_id
local function get_session_id()
   local session_id = 'nvim-' .. vim.fn.getpid()
   return session_id
end

---@return table cmd
local function get_save_cmd()
   if opts.save_as.global then
      cmd = { 'macime', 'set', opts.ime.default, '--save' }
   else
      cmd = { 'macime', 'set', opts.ime.default, '--save', '--session-id', get_session_id() }
   end
   return cmd
end

---@return table cmd
local function get_load_cmd()
   if opts.save_as.global then
      cmd = { 'macime', 'load' }
   else
      cmd = { 'macime', 'load', '--session-id', get_session_id() }
   end
   return cmd
end

function M.add_autocmd()
   vim.api.nvim_create_autocmd('InsertLeave', {
      callback = function()
         local cmd = get_save_cmd()
         vim.fn.jobstart(cmd)
      end,
   })
   vim.api.nvim_create_autocmd('InsertEnter', {
      callback = function()
         local is_allowed_filetype = not vim.tbl_contains(opts.excludes.filetype, vim.bo.filetype)
         local cmd = get_load_cmd()
         if is_allowed_filetype then vim.fn.jobstart(cmd) end
      end,
   })
end

return M
