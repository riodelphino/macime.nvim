# macime.nvim


A wrapper plugin for [macime](https://github.com/riodelphino/macime) cli.  

`macime` cli is a faster IME switcher for macOS.
`macime.nvim` integrate `macime` into nvim, without extra codings.


## Version

`macime.nvim` v1.0.2


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

## Known Issues

### Shared IME ID

The saved IME ID is shared between main|floating|split windows. This causes unintended IME restoring when entering to input-mode.  

A solution for now is adding these window filetypes to `opts.exclude.filetype`:
```lua
exclude = {
   filetype = {'TelescopePrompt', 'snacks_picker_input', 'neo-tree-popup', 'neo-tree-filter' }, 
}
```


## TODO

- [-] saving & loading
   - [x] per-process-id
   - [ ] per-window-id ?


## Changelog

See [CHANGELOG.md](CHANGELOG.md)


## LICENSE

MIT License. See [LICENSE](LICENSE)


## Related

- [im-select](https://github.com/daipeihust/im-select)
- [macism](https://github.com/laishulu/macism)

