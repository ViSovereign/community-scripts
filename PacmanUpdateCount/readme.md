# Pacman Update Check

Shows the number of updates available using 'checkupdates' and 'paru' commands. 

## Requires

- paru
- checkupdates

## Install

1. Save this script to a directory.
2. Add this scripted-widget into your noctalia settings.toml.
3. It should now be a selectable widget.

### Add this scripted-widget to settings.toml

Usually located '~/.local/state/noctalia/settings.toml'

```
[widget.pacmanupdatecount]
hot_reload = true
script = "/path/to/script/pacmanupdatecount.lua"
type = "scripted"
update_interval = 60
```

## IPC

- Refresh with `noctalia msg scripted-widget updatecount all refresh`
