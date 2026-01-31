require('macime.types')
local msgs = require('macime.messages')
local conf = require('macime.config')

local M = {}

---@type macime.Config

---Send a sub command and options to `macimed` launchd service
---@param args table|string
---@param cb fun(ok: boolean, data: string?)?
function M.send(args, cb)
   local pipe = vim.uv.new_pipe(false)

   if type(args) == 'table' then args = table.concat(args, ' ') end

   vim.uv.pipe_connect(pipe, conf.opts.socket.path, function(connect_err)
      if connect_err then
         local msg = string.format('Connect failed: %s\n\n%s', connect_err, msgs.pipe.connect_failed)
         vim.notify(msg, vim.log.levels.ERROR, { title = 'macime.nvim' })
         pipe:close()
         if type(cb) == 'function' then cb(false, msg) end
         return
      end

      -- Send command
      pipe:write(args .. '\n', function(write_err)
         if write_err then
            local msg = string.format('Write failed: %s\n\n%s', write_err, msgs.pipe.write_failed)
            vim.notify(msg, vim.log.levels.ERROR, { title = 'macime.nvim' })
            pipe:close()
            if type(cb) == 'function' then cb(false, msg) end
            return
         end

         -- Recieve response
         local chunks = {}
         pipe:read_start(function(read_err, data)
            if read_err then
               local msg = string.format('Read failed: %s\n\n%s', read_err, msgs.pipe.read_failed)
               vim.notify(msg, vim.log.levels.ERROR, { title = 'macime.nvim' })
               pipe:close()
               if type(cb) == 'function' then cb(false, msg) end
               return
            elseif data then
               table.insert(chunks, data)
            else
               pipe:close()
               if type(cb) == 'function' then cb(true, table.concat(chunks)) end
            end
         end)
      end)
   end)
end

---@return string session_id
local function get_session_id()
   local session_id = 'nvim-' .. vim.fn.getpid()
   return session_id
end

---@return table args
local function get_leave_args()
   if conf.opts.save.enabled then
      if conf.opts.save.scope == 'global' then
         args = { 'set', conf.opts.ime.default, '--save' }
      elseif conf.opts.save.scope == 'session' then
         args = { 'set', conf.opts.ime.default, '--save', '--session-id', get_session_id() }
      end
   else
      args = { 'set', conf.opts.ime.default }
   end
   if conf.opts.socket.enabled then table.insert(args, '--launchd') end
   return args
end

---@return table args
local function get_enter_args()
   if conf.opts.save.enabled then
      if conf.opts.save.scope == 'global' then
         args = { 'load' }
      elseif conf.opts.save.scope == 'session' then
         args = { 'load', '--session-id', get_session_id() }
      end
   else -- no save / no load
      args = {}
   end
   if conf.opts.socket.enabled then table.insert(args, '--launchd') end
   return args
end

---@param filetype string
---@return boolean allowed
local function is_excluded_filetype(filetype)
   local is_excluded = vim.tbl_contains(conf.opts.exclude.filetype, filetype)
   return is_excluded
end

local function add_autocmd()
   local augroup = vim.api.nvim_create_augroup('MacIME', {})

   vim.api.nvim_create_autocmd('InsertLeave', {
      group = augroup,
      pattern = conf.opts.include.pattern,
      desc = 'macime.nvim - Save current IME & switch to the `default` IME',
      callback = function()
         local buf_allowed = not is_excluded_filetype(vim.bo.filetype)
         if buf_allowed then
            local args = get_leave_args()
            if conf.opts.socket.enabled then
               M.send(args) -- macimed service
            else
               vim.loop.spawn('macime', {
                  args = args,
                  stdio = { nil, nil, nil },
                  detach = true,
               })
            end
         end
      end,
   })
   vim.api.nvim_create_autocmd('InsertEnter', {
      group = augroup,
      desc = 'macime.nvim - Restore previous IME',
      pattern = conf.opts.include.pattern,
      callback = function()
         if not conf.opts.save.enabled then
            return -- Not set or load
         end
         local buf_allowed = not is_excluded_filetype(vim.bo.filetype)
         if buf_allowed then
            local args = get_enter_args()
            if conf.opts.socket.enabled then
               M.send(args) -- macimed service
            else
               vim.loop.spawn('macime', {
                  args = args,
                  stdio = { nil, nil, nil },
                  detach = true,
               })
            end
         end
      end,
   })
end

function check_version()
   local is_installed = (vim.fn.executable('macime') == 1)
   if not is_installed then
      local msg = '`macime` is not installed.\nSee `:checkhealth macime`'
      error(msg)
   end
   local version = vim.trim(vim.fn.system({ 'macime', '--version' }))
   if not vim.version.ge(version, '3.2.0') then
      local msg = '`macime` version must be >= 3.2.0\nSee `:checkhealth macime`'
      error(msg)
   end
end

---Setup
---@param user_config macime.Config
function M.setup(user_config)
   conf.opts = vim.tbl_deep_extend('force', conf.defaults, user_config)
   if conf.opts.vim.ttimeoutlen then vim.o.ttimeoutlen = conf.opts.vim.ttimeoutlen end
   check_version()
   add_autocmd()
end

return M
