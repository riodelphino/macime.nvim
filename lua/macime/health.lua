local health = vim.health
local M = {}

---Check system
---@return macime.Health health
function M.get_health()
   local h = {} ---@type macime.Health
   local opts = require('macime.config').opts
   local stdout

   -- Check macime installed and version
   h.macime_installed = (vim.fn.executable('macime') == 1)
   if h.macime_installed then h.macime_version = vim.trim(vim.fn.system({ 'macime', '--version' })) end

   if not vim.version.ge(h.macime_version, '3.2.0') then
      -- Avoid UI freezing by `macimed --version` runs `macimed` as daemon
      return h
   end

   -- Check macimed installed and version
   h.macimed_installed = (vim.fn.executable('macimed') == 1)
   if h.macimed_installed then h.macimed_version = vim.trim(vim.fn.system({ 'macimed', '--version' })) end

   -- Check Capability
   h.capability_direct = vim.version.ge(h.macime_version, '3.2.0')
   h.capability_socket = vim.version.ge(h.macime_version, '3.2.0')
   h.capability_cjk_refresh = vim.version.ge(h.macime_version, '3.5.0')

   -- Check Sock
   stdout = vim.fn.system({ 'macimed', '--info' })
   for _, line in ipairs(vim.fn.split(stdout, '\n', false)) do
      local k, v = unpack(vim.fn.split(line, ':', false))
      k, v = vim.trim(k), vim.trim(v)
      k, v = k:gsub('\n', ''), v:gsub('\n', '')
      if k and v then
         if k == 'sockPath' then
            h.macimed_sock_path = v
         elseif k == 'status' then
            h.macimed_status = v
         elseif k == 'macimePath' then
            h.macimed_macime_path = v
         end
      end
   end
   -- (Fallback) Check macimed status in older macime,macimed
   if vim.version.lt(h.macime_version, '3.3.1') then -- if macime, macimed < 3.3.1 (`status` is implemented in 3.3.1)
      local ok = vim.fn.system({
         'sh',
         '-c',
         string.format('nc -U %q < /dev/null >/dev/null 2>&1; echo $?', opts.socket.path),
      })
      h.macimed_status = ok:match('^0') and 'running' or 'stopped'
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
      health.error(string.format('`macimed` not installed.'), { '`macimed` is bundled with `macime`.", "Try: `brew reinstall macime`' })
   end

   vim.health.start('Capability')
   if h.capability_direct then
      health.ok('`macime`  (direct) : Available (`macime` >= 3.2.0)')
   else
      health.error('`macime`  (direct) : Not Available', { 'Available for `macime` >= 3.2.0', 'Try: `brew update; brew upgrade macime' })
   end
   if h.capability_socket then
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
      health.ok(string.format('%s : Available', opts.ime.default))
   else
      health.error(string.format('%s : Not Available', opts.ime.default), 'Check the IME ID via `macime list --select-capable` or `macime get` command.')
   end

   if opts.socket.enabled then
      vim.health.start('Socket')
      if h.macimed_installed then
         if h.macimed_status == 'running' then
            health.ok(string.format('`macimed` : %s', h.macimed_status))
            if h.macimed_sock_path or h.macimed_macime_path then -- `macimed --info` is available for `macimed` >= v3.3.0
               health.info(string.format('sock_path   : %s (Fixed value)', h.macimed_sock_path))
               health.info(string.format('macime_path : %s', h.macimed_macime_path))
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
            health.info(string.format('out    : %s', h.service_out))
            health.info(string.format('err    : %s', h.service_err))
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
