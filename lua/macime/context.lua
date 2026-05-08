local M = {}

---@type macime.Context
M.ctx = {
   macime = {
      installed = false,
      version = '',
   },
   macimed = {
      installed = false,
      version = '',
   },
   capability = {
      macime_direct = false,
      macimed_daemon = false,
      cjk_refresh = false,
      cjk_delay = false,
      daemon_socket_api = false,
      log_level = false,
   },
}

function M.create_context()
   local conf = require('macime.config')
   -- Check if socket exists to skip version check
   local has_socket = conf.opts.socket.enabled and vim.fn.empty(vim.fn.glob(conf.opts.socket.path)) ~= 1

   -- Macime
   local m = M.ctx.macime
   m.installed = (vim.fn.executable('macime') == 1)
   if m.installed then
      m.version = vim.trim(vim.fn.system({ 'macime', '--version' }))
   elseif has_socket then
      m.version = '99.0.0'
   else
      m.version = ''
   end
   -- Macimed
   local md = M.ctx.macimed
   md.installed = (vim.fn.executable('macimed') == 1)
   if md.installed then
      md.version = vim.trim(vim.fn.system({ 'macimed', '--version' }))
   elseif has_socket then
      md.version = '99.0.0'
   else
      md.version = ''
   end
   -- Capability
   local c = M.ctx.capability
   c.macime_direct = vim.version.ge(m.version, '3.2.0') -- >= 3.2.0
   c.macimed_daemon = vim.version.ge(m.version, '3.2.0') -- >= 3.2.0
   c.cjk_refresh = vim.version.ge(m.version, '3.5.0') -- >= 3.5.0
   c.cjk_delay = vim.version.ge(m.version, '4.3.0') -- >= 4.3.0
   c.daemon_socket_api = vim.version.ge(m.version, '3.6.0') -- >= 3.6.0
   c.log_level = vim.version.ge(m.version, '4.3.0') -- >= 4.3.0
end

return M
