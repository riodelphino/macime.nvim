local health = vim.health
local M = {}

---Check system
---@return macime.Health health
function M.get_health()
   local h = {} ---@type macime.Health
   local opts = require('macime').opts
   local stdout

   -- Check macime installed
   h.macime_installed = (vim.fn.executable('macime') == 1)

   -- Check macime version
   if h.macime_installed then h.macime_version = vim.trim(vim.fn.system({ 'macime', '--version' })) end

   -- Check macimed installed
   h.macimed_installed = (vim.fn.executable('macimed') == 1)

   -- Check macimed version
   if h.macimed_installed then h.macimed_version = vim.trim(vim.fn.system({ 'macimed', '--version' })) end

   -- Check capability
   h.capability_direct = vim.version.ge(h.macime_version, '2.0.0')
   h.capability_socket = vim.version.ge(h.macime_version, '3.1.1')

   -- Check sock_path
   stdout = vim.fn.system({ 'macimed', '--info' })
   for _, line in ipairs(vim.fn.split(stdout, '\n')) do
      local k, v = unpack(vim.fn.split(line, ':'))
      if k and v then
         if k == 'sock' then
            h.macimed_sock_path = vim.trim(v)
         elseif k == 'macime' then
            h.macimed_macime_path = vim.trim(v) -- TODO: This should be shown here too?
         end
      end
   end

   -- Check macimed service running
   -- require('macime').send({ 'get' }, function(ok, _) -- (Async is not proper here...)
   --    h.macimed_running = ok
   -- end)
   local ok = vim.fn.system({
      'sh',
      '-c',
      string.format('nc -U %q < /dev/null >/dev/null 2>&1; echo $?', opts.service.sock_path), --DEBUG: idealy `macimed --status` returns `sock_path`, `listening`
   })
   h.macimed_running = ok:match('^0')
   h.macimed_sock_path = opts.service.sock_path

   -- Check ime.default enaled
   stdout = vim.fn.system(string.format('macime list --select-capable | grep %s', opts.ime.default))
   if vim.trim(stdout) == opts.ime.default then h.ime_default_ok = true end

   -- local stdout = vim.fn.system({ 'brew', 'services', 'list', '|', 'grep', 'macime' })

   stdout = vim.fn.system('brew services list | grep macime')
   local fields = vim.split(vim.trim(stdout), '%s+')
   if fields then
      local name, status, user, file = unpack(fields)
      h.service_name = name
      h.service_status = status
      h.service_user = user
      h.service_file = file
   end
   if h.service_file then
      local plist = M.getpl(h.service_file)
      h.plist_keepalive = plist.keepalive
      h.plist_runatload = plist.runatload
      h.plist_cmd = plist.cmd
      h.plist_macime = plist.macime
      h.plist_stderr = plist.stderr
      h.plist_stdlog = plist.stdout
   end

   return h
end

---@param path string
function M.getpl(path)
   local plist = vim.fn.expand(path)

   -- plist -> json
   local json = vim.fn.system({
      'plutil',
      '-convert',
      'json',
      '-o',
      '-',
      plist,
   })

   local data = vim.json.decode(json)

   return {
      macime = data.EnvironmentVariables.MACIME_PATH,
      keepalive = data.KeepAlive,
      runatload = data.RunAtLoad,
      cmd = data.ProgramArguments and table.concat(data.ProgramArguments, ' ') or nil,
      stderr = data.StandardErrorPath,
      stdout = data.StandardOutPath,
   }
end

function M.check()
   local h = M.get_health()
   local opts = require('macime').opts

   vim.health.start('Command version')
   if h.macime_installed then
      if h.capability_direct then
         health.ok(string.format('`macime` : %s (>= 2.0.0)', h.macime_version))
      else
         health.error(string.format('`macime` : %s (>= 2.0.0)'), { 'Upgrade `macime` via: `brew update; brew upgrade macime`' })
      end
   else
      health.error('`macime` command not installed.', { 'Install `macime` via: `brew tap riodelphino/tap; brew install macime`' })
   end
   if not h.macimed_installed then -- Show only when `macimed` not found
      health.error(string.format('`macimed` not installed.'), { '`macimed` is bundled with `macime`.", "Try: `brew reinstall macime`' })
   end

   vim.health.start('Capability')
   if h.capability_direct then
      health.ok('`macime`  (direct) : Available (`macime` >= 2.0.0)')
   else
      health.error('`macime`  (direct) : Not Available', { 'Available for `macime` >= 2.0.0', 'Try: `brew update; brew upgrade macime' })
   end
   if h.capability_socket then
      health.ok('`macimed` (socket) : Available (`macime` >= 3.1.1)')
   else
      health.warn('`macimed` (socket) : Not Available', { 'Available for `macime` >= 3.1.1', 'Try: `brew update; brew upgrade macime' })
   end

   vim.health.start('Selected Backend')
   health.info(opts.service.enabled and '`macimed` (socket)' or '`macime` (direct)')

   vim.health.start('IME default')
   if h.ime_default_ok then
      health.ok(string.format('%s : Available', opts.ime.default))
   else
      health.error(string.format('%s : Not Available', opts.ime.default), 'Please check the IME ID via `macime list --select-capable` or `macime get` command.')
   end

   if opts.service.enabled then
      vim.health.start('Socket')
      if h.macimed_installed then
         if h.macimed_running then
            health.ok('`macimed` : running')
            if h.macimed_sock_path or h.macimed_macime_path then -- `macimed --info` is available for `macimed` >= v3.3.0
               health.info(string.format('sock_path   : %s (Fixed value)', h.macimed_sock_path))
               health.info(string.format('macime_path : %s (from `MACIME_PATH` set by Homebrew)', h.macimed_macime_path))
            end
         else
            if opts.service.enabled then
               health.error(
                  '`macimed` : Not running (While `opts.service.enabled` is true)',
                  { 'Try: `brew services start macime` or `macimed`(for debugging)', 'Or : set `opts.service.enabled` to false' }
               )
            else
               health.ok('`macimed` : Not running')
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
         elseif h.service_status == 'none' then
            if opts.service.enabled then
               if h.macimed_running then
                  health.warn('Service not started', { 'Try: `brew services start macime`', 'Or : set `opts.service.enabled` to false' })
               else
                  health.error('Service not started', { 'Try: `brew services start macime`', 'Or : set `opts.service.enabled` to false' })
               end
            else
               health.warn('Service not started', { '`macimed` is not running via Homebrew.', 'Try: `brew services start macime`' })
            end
         else
            health.warn('`macimed` not registered as brew service', { 'Try: `brew reinstall macime`' })
         end
      end
      vim.health.start('plist')
      if h.service_status == 'started' then
         health.ok('plist exists')
         health.info(string.format('KeepAlive            : %s', h.plist_keepalive))
         health.info(string.format('RunAtLoad            : %s', h.plist_runatload))
         health.info(string.format('macime (MACIME_PATH) : %s', h.plist_macime))
         health.info(string.format('ProgramArguments     : %s', h.plist_cmd))
         health.info(string.format('StandardErrorPath    : %s', h.plist_stderr))
         health.info(string.format('StandardOutPath      : %s', h.plist_stdlog))
      elseif h.service_status == 'none' then
         if h.macimed_running then
            health.warn('plist: Not found')
         else
            health.error('plist: Not found')
         end
      end
   end
end
return M
