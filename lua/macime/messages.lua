local messages = {
   setup = {
      macime = {
         not_installed = [[
The `macime` command not found.

Please install it with:
   brew tap riodelphino/tap
   brew install macime
         ]],
         version_incompatible = [[
The `macime` version incompatible.

>=v 3.1.1 for launchd service (Faster/Recommended)
>=v 2.0.0 also works (Slower/launchd not supported)

Please upgrade it with:
   brew update
   brew upgrade macime
         ]],
      },
      macimed = {
         not_installed = [[
The `macimed` command not found.

Please install it first:
   brew tap riodelphino/tap
   brew install macime
         ]],
         service_not_running = [[
`opts.service.enabled` is set to `true`, but `macimed` is not running.

Please start `macimed` via:
   - Run `brew services start macime`
   - or start `macimed` manually (for testing)
         ]],
      },
   },
   pipe = {
      connect_failed = [[
Please check the followings:
   1. Run `brew services list` and confirm that `macime` is marked as `started`.
   2. If not, start the service: `brew services start macime`
   3. If you recently upgraded `macime`, restart the service: `brew services restart macime`
   4. For testing, you can run `macimed` manually to see the logs.
      ]],
      write_failed = [[
Please check the followings:
   1. The service (`macimed`) terminated immediately after the connection was established.
   2. The socket file exists, but no process is listening. (stale socket)
   3. Insufficient permissions to write to the socket.
   4. The peer closed the connection before or during the write.
      ]],
      read_failed = [[
Please check the followings:
   1. The service (`macimed`) crashed or exited unexpectedly after connecting
   2. The socket was removed while communication was in progress
   3. The connection was closed due to a protocol or communication error
      ]],
   },
}
return messages
