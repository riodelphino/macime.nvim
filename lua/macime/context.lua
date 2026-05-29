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

---@param opts macime.Config
function M.create_context(opts)
   -- Macime
   local m = M.ctx.macime
   local md = M.ctx.macimed
   local c = M.ctx.capability

   if not opts.socket.forwarded then
      m.installed = (vim.fn.executable('macime') == 1)
      m.version = vim.trim(vim.fn.system({ 'macime', '--version' }))
      -- Macimed
      md.installed = (vim.fn.executable('macimed') == 1)
      md.version = vim.trim(vim.fn.system({ 'macimed', '--version' }))
      -- Capability
      c.macime_direct = vim.version.ge(m.version, '3.2.0') -- >= 3.2.0
      c.macimed_daemon = vim.version.ge(m.version, '3.2.0') -- >= 3.2.0
      c.cjk_refresh = vim.version.ge(m.version, '3.5.0') -- >= 3.5.0
      c.cjk_delay = vim.version.ge(m.version, '4.3.0') -- >= 4.3.0
      c.daemon_socket_api = vim.version.ge(m.version, '3.6.0') -- >= 3.6.0
      c.log_level = vim.version.ge(m.version, '4.3.0') -- >= 4.3.0
   else
      -- Skip checkes when using SSH socket forwarding
   end
end

return M
