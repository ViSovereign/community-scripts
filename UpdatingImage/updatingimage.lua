-- Updating Image - Periodically updates an image using a user-provided command line.
--
-- Add in your settings.toml:
-- [widget.updatingimage]
-- script = "~/.config/noctalia/scripts/updatingimage.lua"
-- type = "scripted"

local defaultCommandLine = "magick -size 60x40 canvas:black -color red -draw 'line 0,0 60,40' /tmp/noctalia-updating-image.png"
local defaultImagePath = "/tmp/noctalia-updating-image.png"
local defaultImageWidth = 30
local defaultImageHeight = 20
local defaultUpdateInterval = 1000

barWidget.define({
    label = "Updating Image",
    icon = "image",
    description = "Periodically updates an image using a user-provided command line.",
    settings = {
        {
            key = "command_line",
            type = "string",
            label = "Command line to generate the image",
            description = "The command should generate an image file to be displayed.",
            default = defaultCommandLine,
        },
        {
            key = "image_path",
            type = "string",
            label = "Image path",
            description = "The path to the generated image.",
            default = defaultImagePath,
        },
        {
            key = "image_width",
            type = "integer",
            label = "Image width",
            default = defaultImageWidth,
            min = 1,
        },
        {
            key = "image_height",
            type = "integer",
            label = "Image height",
            default = defaultImageHeight,
            min = 1,
        },
        {
            key = "update_interval",
            type = "integer",
            label = "Update interval (ms)",
            description = "How often to check for updates and run the command line (in milliseconds).",
            default = defaultUpdateInterval,
            min = 100,
        },
        {
            key = "click_action",
            type = "string",
            label = "Click action",
            description = "The command to run when the widget is clicked.",
        }
    }
})

local commandLine = barWidget.getConfig("command_line") or defaultCommandLine
local imageWidth = barWidget.getConfig("image_width") or defaultImageWidth
local imageHeight = barWidget.getConfig("image_height") or defaultImageHeight
local updateInterval = barWidget.getConfig("update_interval") or defaultUpdateInterval
local clickAction = barWidget.getConfig("click_action")
local imagePath = barWidget.getConfig("image_path") or defaultImagePath

barWidget.setGlyph("image")
barWidget.setUpdateInterval(updateInterval)

local imageSet = false

function update()
    noctalia.runAsync(commandLine, function(result)
        if result.exitCode == 0 then
            if not imageSet then
                print("Image generated successfully: " .. imagePath)
                barWidget.setImage(imagePath, true, imageWidth, imageHeight)
                imageSet = true
            end
        else
            print("Error updating image: " .. result.stderr .. " (command: " .. commandLine .. ") " .. "output: " .. result.stdout)
        end
    end)
end

function onClick()
    if not clickAction or clickAction == "" then
        return
    end
    noctalia.runAsync(clickAction, function(result)
        if result.exitCode ~= 0 then
            print("Error executing click action: " .. result.stderr .. " (command: " .. clickAction .. ") " .. "output: " .. result.stdout)
        end
    end)
end
