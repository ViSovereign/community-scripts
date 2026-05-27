# Updating Image

Displays an image created by periodically running a command line.


## Install

1. Save this script to a directory.
2. Add this scripted-widget to your noctalia settings.toml.
3. It should now be a selectable widget.

### Add this scripted-widget to settings.toml

Usually located '~/.config/noctalia/settings.toml'

```toml
[widget.updatingimage]
script = "/path/to/script/updatingimage.lua"
type = "scripted"
```

## Configuration

You need to configure both the command line and the image path.
