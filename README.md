# macime.nvim

![Version](https://img.shields.io/github/v/tag/riodelphino/macime.nvim?style=for-the-badge&cacheSeconds=0)
[![License: MIT](https://img.shields.io/badge/License-MIT-%232196F3.svg?style=for-the-badge)](LICENSE)
[![Lua](https://img.shields.io/badge/Lua-5.x-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.9%2B-%2357A143.svg?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/)
[![Dependency](https://img.shields.io/badge/Dependency-macime(Homebrew)-%23FBB040?style=for-the-badge)](#installation)
[![Platform](https://img.shields.io/badge/Platform-macOS%2010.15%2B-blue?style=for-the-badge)](#)

A wrapper plugin for [macime](https://github.com/riodelphino/macime) cli.  

[macime](https://github.com/riodelphino/macime) cli is a **blazing faster** IME switcher for macOS.  
This plugin integrates [macime](https://github.com/riodelphino/macime) cli into nvim, without extra codings.


## Dependencies

- macOS >= 10.13
- [macime](https://github.com/riodelphino/macime) >= 3.2.0
- [nvim](https://neovim.io/) >= 0.9
- swift >= 5.0 (Required for Homebrew build)


## Breaking Changes

[v2.3.0](https://github.com/riodelphino/macime.nvim/releases/tag/v2.3.0): Adapt to `--cjk-refersh` option in `macime` v3.5.0
[v2.2.3](https://github.com/riodelphino/macime.nvim/releases/tag/v2.2.3): Config structure was changed
[v2.2.2](https://github.com/riodelphino/macime.nvim/releases/tag/v2.2.2): Config structure was changed
[v2.2.2](https://github.com/riodelphino/macime.nvim/releases/tag/v2.2.2): `macime` < v3.2.0 is deprecated


## Install

for lazy.nvim:
```lua
return {
   "riodelphino/macime.nvim",
   event = 'VimEnter', -- Changed from `VeryLazy` (for earlier autocmd registration & execution)
   opts = {},
}
```

## Config

Default config:
```lua
local defaults = {
   vim = {
      ttimeoutlen = nil, -- (number): If set, overwrite `vim.o.ttimeoutlen`. (Recommend: 0 - 50)
   },
   ime = {
      default = 'com.apple.keylayout.ABC', -- (string): The default IME ID (set in 'InsertLeave')
      cjk_refresh = false, -- (boolean): Enable/Disable IME refreshing for CJK input methods (Experimental)
   },
   save = {
      enabled = true, -- (boolean): Enable/Disable save and restore previous IME
      scope = "global", -- ("global"|"session"): Save previous IME per session or globally
   },
   socket = {
      -- Ensure `macime` >= v3.2.0 installed and `macimed` is running directly or via Homebrew service
      enabled = false, -- (bool): True to use launchd service for faster switching
      path = '/tmp/riodelphino.macimed.sock', -- (string): The sock path to listen (Usually no need to change)
   },
   include = {
      pattern = {"*"}, -- (string|[string]): Enable with specific file patterns (e.g. "*" or { "*.h", "*.c" } )
   },
   exclude = {
      filetype = {}, -- (string|[string]): Disable with specific filetypes (e.g. { 'TelescopePrompt', 'snacks_picker_input', 'neo-tree-popup', 'neo-tree-filter' } )
   },
}
```

Recommended setup:
```lua
{
   "riodelphino/macime.nvim",
   event = 'VimEnter',
   ---@type macime.Config
   opts = {
      vim = {
         ttimeoutlen = 0, -- Reduce delay after InsertLeave and InsertEnter
      },
      save = {
         enabled = true,
         scope = "session", -- Save previous IME per nvim pid
      },
      socket = {
         enabled = true, -- Enable `macimed` launchd service for blazing faster switching
      },
      exclude = {
         filetype = { 'TelescopePrompt', 'snacks_picker_input', 'neo-tree-popup', 'neo-tree-filter' }, -- Exclude specific filetypes
      },
   }
}
```

With above recommended settings, ensure followings:
* [macime](https://github.com/riodelphino/macime) >= 3.2.0 (`macimed` is also bundled)
* `macimed` is running manually or via `Homebrew service`

See more details at: [riodelphino/macime](https://github.com/riodelphino/macime)


## Checkhealth

The checkhealth command is available:
```vim
:checkhealth macime
```

It shows diagnostic information and gives useful advices about:
- Command version
- Capability
- Selected Backend
- IME default
- Socket
- Homebrew Service


## Issues

### Shared IME ID

The saved IME ID is shared between nvim's main|floating|split windows. This causes unintended IME restoring when entering to input-mode.  

A solution for now:

Adding these window filetypes to `opts.exclude.filetype`:
```lua
exclude = {
   filetype = {'TelescopePrompt', 'snacks_picker_input', 'neo-tree-popup', 'neo-tree-filter' }, 
}
```

### IME mode unchanged by Karabiner

Rarely it becomes impossible to set the IME mode `ON` by `right_command` key with `karabiner`.

My Karabiner config:
   - `left_command` key sends `japanese_eisuu` key (IME OFF)
   - `right_command` key sends `japanese_kana` key (IME ON)

Same issue was also found in GUI Apps.  
Which is this issue releated to `macime` or `Karabiner`?

Solutions:
   - Set the IME `OFF` once by `left_command` key, then `right_command` key works.
   - Or, open another app window (e.g. `Safari.app`), then return to terminal. `right_command` key works again.


## API

### Send command and recieve message

If `macimed` is running, it is controled by sending command via `send()` API function.

Send comamnd -> Evaluate return values via callback:
```lua
require('macime').send("<method> <subcmd> [args...]", function(ok, data)
   if not ok then
      -- Error operations
   end
   -- Success operations
end)
```

Or, simply send command without return values:
```lua
require('macime').send("<method> <subcmd> [args...]")
```

The command also accepts table:
```lua
require('macime').send({"<method>", "<subcmd>", "<arg>", "<arg>", ...})
```

#### Method: ime

`ime` is a wrapper method to control `macime` command via `macimed`.  
The syntax is same with `macime` command line args. Just insert `ime` at the beginning.

The 
```lua
-- Equals to `macime get`
require('macime').send("ime get")

-- Equals to `macime set com.apple.keylayout.ABC`
require('macime').send("ime set com.apple.keylayout.ABC")

-- Equals to `macime set com.apple.keylayout.ABC --save`
require('macime').send("ime set com.apple.keylayout.ABC --save")

-- Equals to `macime set com.apple.keylayout.ABC --save --session-id nvim-1001`
require('macime').send("ime set com.apple.keylayout.ABC --save --session-id nvim-1001")

require('macime').send("ime load") -- Equals to `macime load`
require('macime').send("ime load") -- Equals to `macime load`
```

#### Method: daemon

`daemon` is a wrapper method to control `macimed`.  
Insert `daemon` at the beginning, then add sub command.

```lua
-- Get status
require('macime').send("daemon status", function(ok, data)
   if ok then
      print("status: " .. data)
   end
)
-- "running"

-- Get all information
require('macime').send("daemon info")

-- Get sock path
require('macime').send("daemon get sock-path", function(ok, data)
   if ok then
      print("sock-path: " .. data)
   end
end)

-- Get macime path
require('macime').send("daemon get macime-path", function(ok, data)
   if ok then
      print("macime-path: " .. data)
   end
end)
```

## TODO

### Save & Load

- [x] Per nvim PID  
  Save as `nvim-{pid}`.  
  Currently working; verifying whether this granularity is sufficient.

- [ ] Per nvim PID + window ID  
  Save as `nvim-{pid}-{winid}`.  
  Intended to solve [this issue](#shared-ime-id), but may generate too many files. Not ideal.

- [ ] Enable in command-line mode  
  Tried once, but benefits were limited and code complexity increased.

### Others

- [ ] Macro compatibility  
  Concern: repeated `macime` execution on `InsertLeave` / `InsertEnter` may slow down macro playback.


## Changelog

See [CHANGELOG.md](CHANGELOG.md)


## LICENSE

MIT License. See [LICENSE](LICENSE)


## Related

- [im-select](https://github.com/daipeihust/im-select)
- [vim-barbaric](https://github.com/rlue/vim-barbaric)
- [macism](https://github.com/laishulu/macism)

