local health = vim.health
local M = {}

---Check system
---@return macime.Health health
function M.get_health()
   local h = {} ---@type macime.Health
   local opts = require('macime.config').opts
   local ctx = require('macime.context').ctx
   local stdout

   require('macime.context').create_context() -- refresh context

   -- Check macime installed and version
   h.macime_installed = ctx.macime.installed
   if h.macime_installed then h.macime_version = ctx.macime.version end

   if not vim.version.ge(h.macime_version, '3.2.0') then
      -- Avoid UI freezing by `macimed --version` runs `macimed` as daemon
      return h
   end

   -- Check macimed installed and version
   h.macimed_installed = ctx.macimed.installed
   if h.macimed_installed then h.macimed_version = ctx.macimed.version end

   -- Check Capability
   h.capability_direct = ctx.capability.macime_direct
   h.capability_daemon = ctx.capability.macimed_daemon
   h.capability_cjk_refresh = ctx.capability.cjk_refresh
   h.capability_daemon_socket_api = ctx.capability.daemon_socket_api

   -- Check Socket
   h.macimed_status, h.macimed_sock_path, h.macimed_macime_path = '', '', ''
   if ctx.capability.daemon_socket_api then
      -- For `macime` >= v3.6.0
      local pipe = vim.uv.new_pipe(false)
      vim.uv.pipe_connect(pipe, opts.socket.path, function(connect_err)
         if not connect_err then
            h.macimed_status = 'running'
            require('macime').send('daemon info', function(ok, data) -- TODO: [UNSTABLE] Finishing this cb before exiting `get_health()` is not ensured.
               if ok then
                  local info = vim.json.decode(data)
                  if info then
                     h.macimed_sock_path = info['sock-path']
                     h.macimed_macime_path = info['macime-path']
                  end
               else
                  -- TODO: Add error handling
                  h.macimed_sock_path = 'ERROR: Cannot get sock-path'
                  h.macimed_macime_path = 'ERROR: Cannot get macime-path'
               end
            end)
         else
            h.macimed_status = 'stopped'
         end
      end)
   else
      -- For `macime` < v3.6.0 (backward compatibility) -- TODO: Must be removed in later version
      local macimed_info = vim.fn.system({ 'macimed', '--info' })
      for _, line in ipairs(vim.fn.split(macimed_info, '\n', false)) do
         local k, v = unpack(vim.fn.split(line, ':', false))
         k, v = vim.trim(k), vim.trim(v)
         k, v = k:gsub('\n', ''), v:gsub('\n', '')
         if k and v then
            if k == 'status' then
               h.macimed_status = v
            elseif k == 'sock-path' then
               h.macimed_sock_path = v .. ' (Note: `MACIME_SOCK_PATH` is not reflected)'
            elseif k == 'macime-path' then
               h.macimed_macime_path = v .. ' (Note: `MACIME_PATH` is not reflected)'
            end
         end
      end
   end

   -- Check ime.default enabled
   stdout = vim.fn.system(string.format('macime list --select-capable | grep %s', opts.ime.default))
   if vim.trim(stdout) == opts.ime.default then h.ime_default_ok = true end

   if opts.socket.enabled then -- Check only when `socket.enabled` is true
      -- Check Homebrew Service Info
      stdout = vim.fn.system('brew services list | grep macime')
      local fields = vim.split(vim.trim(stdout), '%s+')
      if fields then
         local name, status, user, file = unpack(fields)
         h.service_name = name
         h.service_status = status
         h.service_user = user
         h.service_file = file
      end

      -- Check plist
      if h.service_file then
         plist = M.parse_plist(h.service_file)
         h.service_out = plist.StandardOutPath
         h.service_err = plist.StandardErrorPath
         local daemons = plist.ProgramArguments
         h.service_daemon = #daemons == 1 and daemons[1] or vim.inspect(daemons)
      end
   end

   return h
end

---@param path string
function M.parse_plist(path)
   path = vim.fn.expand(path)
   if not vim.uv.fs_stat(path) then return {} end

   -- plist -> json
   local json = vim.fn.system({
      'plutil',
      '-convert',
      'json',
      '-o',
      '-',
      path,
   })

   return vim.json.decode(json)
end

function M.check()
   local h = M.get_health()
   local opts = require('macime.config').opts

   vim.health.start('Command version')
   if h.macime_installed then
      if h.capability_direct then
         health.ok(string.format('`macime` : %s (>= 3.2.0)', h.macime_version))
      else
         health.error(string.format('`macime` : %s (>= 3.2.0)', h.macime_version), { 'Upgrade `macime` via: `brew update; brew upgrade macime`' })
         return
      end
   else
      health.error('`macime` command not installed.', { 'Install `macime` via: `brew tap riodelphino/tap; brew install macime`' })
      return
   end
   if not h.macimed_installed then -- Show only when `macimed` not found
      health.error('`macimed` not installed.', { '`macimed` is bundled with `macime`.', 'Try: `brew reinstall macime`' })
   end
   if h.macimed_version ~= h.macime_version then -- Show only when version mismatch
      health.error(string.format('Version mismatch: `macime` %s / `macimed` %s', h.macime_version, h.macimed_version), { 'Try: `brew reinstall macime`' })
   end

   vim.health.start('Capability')
   if h.capability_direct then
      health.ok('`macime`  (direct) : Available (`macime` >= 3.2.0)')
   else
      health.error('`macime`  (direct) : Not Available', { 'Available for `macime` >= 3.2.0', 'Try: `brew update; brew upgrade macime' })
   end
   if h.capability_daemon then
      health.ok('`macimed` (socket) : Available (`macime` >= 3.2.0)')
   else
      health.warn('`macimed` (socket) : Not Available', { 'Available for `macime` >= 3.2.0', 'Try: `brew update; brew upgrade macime' })
   end
   if h.capability_cjk_refresh then
      health.ok('cjk_refresh : Available (`macime` >= 3.5.0)')
   else
      health.warn('cjk_refresh : Not Available', { 'Available for `macime` >= 3.5.0', 'Try: `brew update; brew upgrade macime' })
   end

   vim.health.start('Selected Backend')
   health.info(opts.socket.enabled and '`macimed` (socket)' or '`macime` (direct)')

   vim.health.start('IME default')
   if h.ime_default_ok then
      health.ok(string.format('%s : Valid', opts.ime.default))
   else
      health.error(string.format('%s : Invalid', opts.ime.default), 'Get the valid IME ID via `macime list --select-capable` or `macime get` command.')
   end

   if opts.socket.enabled then
      vim.health.start('Socket')
      if h.macimed_installed then
         if h.macimed_status == 'running' then
            health.ok(string.format('`macimed` : %s', h.macimed_status))
            if h.macimed_sock_path or h.macimed_macime_path then -- `macimed --info` is available for `macimed` >= v3.3.0
               health.info(string.format('sock-path   : %s', h.macimed_sock_path))
               health.info(string.format('macime-path : %s', h.macimed_macime_path))
            end
         elseif h.macimed_status == 'stopped' then
            if opts.socket.enabled then
               health.error(string.format('`macimed` : %s', h.macimed_status), {
                  '`macimed` is not started while `opts.service.enabled` is true.',
                  'Try: `brew services start macime` or `macimed`(for debugging)',

                  'Or : set `opts.service.enabled` to false',
               })
            else
               health.ok(string.format('`macimed` : %s', h.macimed_status))
            end
         end
      end

      vim.health.start('Homebrew Service')
      if h.macimed_installed then
         if h.service_status == 'started' then
            health.ok('Service is started')
            health.info(string.format('name   : %s', h.service_name))
            health.info(string.format('status : %s', h.service_status))
            health.info(string.format('user   : %s', h.service_user))
            health.info(string.format('file   : %s', h.service_file))
            health.info(string.format('stdout : %s', h.service_out))
            health.info(string.format('stderr : %s', h.service_err))
            health.info(string.format('daemon : %s', h.service_daemon))
         elseif h.service_status == 'none' then
            if h.macimed_status == 'running' then
               health.warn('Service not started', { 'Try: `brew services start macime`', 'Or : set `opts.service.enabled` to false' })
            else
               health.error('Service not started', { 'Try: `brew services start macime`', 'Or : set `opts.service.enabled` to false' })
            end
         end
      end
   end
end

return M
