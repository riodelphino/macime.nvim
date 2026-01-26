local health = vim.health
local M = {}

---Check system
---@return macime.Health health
function M.check_health()
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
   h.capability_general = vim.version.ge(h.macime_version, '2.0.0')
   h.capability_launchd = vim.version.ge(h.macime_version, '3.1.1')

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
   h.macimed_log_path = '(TODO: fetched via `macimed --status`?)'
   h.macimed_err_path = '(TODO: fetched via `macimed --status`?)'

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

   return h
end

function M.check()
   local h = M.check_health()
   local opts = require('macime').opts

   vim.health.start('Command version')
   if h.macime_installed then
      if h.capability_general then
         health.ok(string.format('`macime` : %s (>= 2.0.0)', h.macime_version))
      else
         health.error(string.format('`macime` : %s (>= 2.0.0)'), { 'Upgrade `macime` via:', '  brew update', '  brew upgrade macime' })
      end
   else
      health.error('`macime` command not installed.', { 'Install `macime` via:', '  brew tap riodelphino/tap', '  brew install macime' })
   end
   if not h.macimed_installed then -- Show only when `macimed` not found
      health.error(string.format('`macimed` not installed.'), { '`macimed` is bundled with `macime`.", "Reinstall `macime` via:', '  brew reinstall macime' })
   end

   vim.health.start('Capability')
   if h.capability_general then
      health.ok('`macime` directly : Available (`macime` >= 2.0.0)')
   else
      health.error('`macime` directly : Not Available (`macime` >= 2.0.0)')
   end
   if h.capability_launchd then
      health.ok('`macimed` socket  : Available (`macime` >= 3.1.1)')
   else
      health.warn('`macimed` socket  : Not Available (`macime` >= 3.1.1)')
   end

   vim.health.start('Selected Backend')
   health.ok(opts.service.enabled and '`macimed` socket' or '`macime` directly')

   vim.health.start('Ime default')
   if h.ime_default_ok then
      health.ok(string.format('%s : Available', opts.ime.default))
   else
      health.error(string.format('%s : Not Available', opts.ime.default), 'Please check the IME ID via `macime list --select-capable` or `macime get` command.')
   end

   vim.health.start('Socket')
   if h.macimed_installed then
      if h.macimed_running then
         health.ok('`macimed` is running.')
         health.ok(string.format('sock_path : %s', h.macimed_sock_path))
         health.ok(string.format('log_path  : %s', h.macimed_log_path))
         health.ok(string.format('err_path  : %s', h.macimed_err_path))
      else
         if opts.service.enabled then
            health.error(
               'Although `opts.service.enabled` is true, `macimed` is not running.',
               { 'Please start it via `brew services start macime` or `macimed`(for debug)', 'Or, set `opts.service.enabled` to false' }
            )
         else
            health.warn('`macimed` is not running.', { 'To start it, please run `brew services start macime` or `macimed`(for debug)' })
         end
      end
   end

   vim.health.start('Homebrew Service')
   if h.macimed_installed then
      if h.service_status == 'started' then
         health.ok(string.format('name   : %s', h.service_name))
         health.ok(string.format('status : %s', h.service_status))
         health.ok(string.format('user   : %s', h.service_user))
         health.ok(string.format('file   : %s', h.service_file))
      elseif h.service_status == 'none' then
         if opts.service.enabled then
            health.error(string.format('name   : %s', h.service_name))
            health.error(
               string.format('status : %s', h.service_status),
               { 'Although `opts.service.enable` is true, `macimed` is not running via Homebrew.', 'Please start it via: `brew services start macime`', 'Or, set `opts.service.enabled` to false' }
            )
         else
            health.warn(string.format('name   : %s', h.service_name))
            health.warn(string.format('status : %s', h.service_status), { '`macimed` is not running via Homebrew.', 'To start it, please run: `brew services start macime`' })
         end
      else
         health.warn('`macimed` not registered as brew service', { 'To enable it, please run: `brew reinstall macime`' })
      end
   end
end
return M
