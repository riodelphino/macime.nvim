# macime.nvim


A wrapper plugin for [macime](https://github.com/riodelphino/macime) cli.  

[macime](https://github.com/riodelphino/macime) cli is a blazing faster IME switcher for macOS.
This plugin integrates [macime](https://github.com/riodelphino/macime) cli into nvim, without extra codings.

Noticiably faster than other similar tools, low latency.


## Dependencies

- [macime](https://github.com/riodelphino/macime)

| Version  | launchd | Speed | Note               |
| -------- | :-----: | :---: | ------------------ |
| macime >= 3.0.1 |    o    |   o   | Faster / Recommend |
| macime >= 2.0.0 |    -    |   △   | Also works         |


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

defaults:
```lua
---@type macime.Config
local defaults = {
   ttimeoutlen = nil, -- (number): If set, overwrite `vim.o.ttimeoutlen`. (Recommend: 0 - 50)
   ime = {
      default = 'com.apple.keylayout.ABC', -- (string): The default IME ID (set in 'InsertLeave')
   },
   save = {
      global = false, -- (bool): Save prev IME as globaly or per session_id
   },
   service = {
      -- Ensure macime >= v3.0.1 and the service started
      enabled = false, -- (bool): True to use launchd service for faster switching
   },
   pattern = nil, -- (string|[string]): Enabled file patterns (e.g. "*" or { "*.h", "*.c" } )
   exclude = {
      filetype = {}, -- Exclude specific filetypes (e.g. { 'TelescopePrompt', 'snacks_picker_input', 'neo-tree-popup', 'neo-tree-filter' } )
   },
}
```

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

Same issue was found in GUI Apps.  
Which is this issue releated to `macime` or `Karabiner`?

Solutions:
   - Set the IME `OFF` once by `left_command` key, then `right_command` key works.
   - Or, open another app window (e.g. `Safari.app`), then return to terminal. `right_command` key works again.


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

