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
      daemon_socket_api = false,
   },
}

function M.create_context()
   -- Macime
   local m = M.ctx.macime
   m.installed = (vim.fn.executable('macime') == 1)
   m.version = vim.trim(vim.fn.system({ 'macime', '--version' }))
   -- Macimed
   local md = M.ctx.macimed
   md.installed = (vim.fn.executable('macimed') == 1)
   md.version = vim.trim(vim.fn.system({ 'macimed', '--version' }))
   -- Capability
   local c = M.ctx.capability
   c.macime_direct = vim.version.ge(m.version, '3.2.0') -- >= 3.2.0
   c.macimed_daemon = vim.version.ge(m.version, '3.2.0') -- >= 3.2.0
   c.cjk_refresh = vim.version.ge(m.version, '3.5.0') -- >= 3.5.0
   c.daemon_socket_api = vim.version.ge(m.version, '3.6.0') -- >= 3.6.0
end

return M
