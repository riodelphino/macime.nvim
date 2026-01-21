local messages = {
   macime_not_installed = [[
The `macime` command was not found.

Please install it first:
   brew tap riodelphino/tap
   brew install macime
   ]],

   macimed_service_not_running = [[
`opts.service.enabled` is set to `true`, but `macimed` is not running.

Please start `macimed` via:
   - Run `brew services start macime`
   - or start `macimed` manually (for testing)
]],
}

return messages
