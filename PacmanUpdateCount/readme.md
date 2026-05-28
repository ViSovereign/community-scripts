# Pacman Update Check

Shows the number of updates from pacman and the AUR 

## Requires

- paru or yay
- checkupdates

## Install

1. Save this script to a directory.
2. Add this scripted-widget into your noctalia settings.toml.
3. It should now be a selectable widget.

### Add this scripted-widget to settings.toml

Usually located '~/.local/state/noctalia/settings.toml'

```
[widget.pacmanupdatecount]
script = "/path/to/scripts/pacmanupdatecount.lua"
type = "scripted"
update_interval = 60
glyph = "packages"
aur_helper = "paru"
color_bool = false
color_count = 100
color_is = "error"
```
## Click Buttons

Left click will refresh the update count
Middle click will open a terminal showing the package versions.
Right click will 

## IPC

- Refresh with `noctalia msg scripted-widget updatecount all refresh`
