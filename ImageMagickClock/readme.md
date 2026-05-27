# ImageMagick Clock

Displays a custom clock drawn using ImageMagick.

## Requires

- ImageMagick

## Install

1. Save this script to a directory.
2. Add this scripted-widget to your noctalia settings.toml.
3. It should now be a selectable widget.

### Add this scripted-widget to settings.toml

Usually located '~/.config/noctalia/settings.toml'

```toml
[widget.imagemagickclock]
script = "/path/to/script/imagemagickclock.lua"
type = "scripted"
```

## Customize the command line

The default command line is:

```bash
magick -size 300x110 canvas:black -draw 'rectangle 0,0 300,110' -pointsize 128 -fill '#FF2400' -draw 'text 0,104 \"%H\"' -fill white -pointsize 84 -draw 'text 116,104 \":%M\"' -fill '#FF2400' -stroke '#FF2400' -strokewidth 5 -draw 'line 220,0 220,110' -strokewidth 0 -stroke none -fill white -pointsize 32 -draw 'text 230, 30 \"%d\"' -draw 'text 230, 64 \"%b\"' -draw 'text 230, 100 \"%Y\"' %output_file
```

You can customize the command line in the widget's configuration to change how the clock looks. The "%output_file" will be replaced with the path to the file where the clock image should be saved. Other placeholders like "%H", "%M", "%S" will be replaced with the hour, minute, and second etc. See `man strftime` for more placeholders you can use in the command line.

You might want to install the "7-Segment" font to get a classic digital clock look. Add `-font '7-Segment'` to the command line after `magick` to use it.

You can use any command-line drawing tool, not just ImageMagick, as long as it outputs an image file to the specified output path.
