# macime.nvim


A wrapper plugin for [macime](https://github.com/riodelphino/macime) cli.  

`macime` cli is a faster IME switcher for macOS.
`macime.nvim` integrate `macime` into nvim, without extra codings.


## Version

`macime.nvim` v1.0.4


## Dependencies

- [macime](https://github.com/riodelphino/macime) >= v2.0.0


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
      default = 'com.apple.keylayout.ABC', -- (strign): The default IME ID (set in 'InsertLeave')
   },
   save = {
      global = false, -- (bool): Save prev IME as globaly or per session_id
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

Which is this issue releated to `macime` or `Karabiner`?

Solutions:
   - Set the IME `OFF` once by `left_command` key, then `right_command` key works.
   - Or, open another app window (e.g. `Safari.app`), then return to terminal. `right_command` key works again.


## TODO

- [-] saving & loading
   - [x] per-process-id
   - [ ] per-winid saving? (e.g. `nvim-{pid}-{winid}`)
       - To solve the above [issure](#shared-ime-id).
       - (This make `macime` cli generate too many stored files... Not ideal.)
   - [ ] in cmdline-mode too?
       - (Already tried it, but it wasn't really necessary. It also complicates the code.)
- [ ] Does it slow down the macro which repeats `Insert{Leave|Enter}`?


## Changelog

See [CHANGELOG.md](CHANGELOG.md)


## LICENSE

MIT License. See [LICENSE](LICENSE)


## Related

- [im-select](https://github.com/daipeihust/im-select)
- [vim-barbaric](https://github.com/rlue/vim-barbaric)
- [macism](https://github.com/laishulu/macism)

