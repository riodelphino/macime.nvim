# macime.nvim


A wrapper plugin for [macime](https://github.com/riodelphino/macime).  
`macime` is a faster IME switcher for macOS.

`macime.nvim` enables `macime` in nvim without extra codings.


## Version

`macime.nvim` v1.0.0


## Dependencies

- [macime](https://github.com/riodelphino/macime) >= v2.0.0


## Install

for lazy.nvim:
```lua
return {
   "riodelphino/macime.nvim",
   event = "VeryLazy",
   opts = {},
}
```

## Config

defaults:
```lua
local defaults = {
   save_as = {
      global = false, -- true|false: Save prev IME as globaly or per session_id
   },
   ime = {
      default = 'com.apple.keylayout.ABC', -- The default IME set in 'InsertLeave'
   },
   excludes = {
      filetype = {}, -- Exclude specific filetypes (e.g. 'TelescopePrompt', 'snacks_picker_input' )
   },
   ttimeoutlen = nil, -- If set, overwrite `vim.o.ttimeoutlen`. (Recommend: 0 - 50)
}
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md)


## LICENSE

MIT License. See [LICENSE](LICENSE)


## Related

- [im-select](https://github.com/daipeihust/im-select)
- [macism](https://github.com/laishulu/macism)

