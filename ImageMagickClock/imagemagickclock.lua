-- ImageMagick Clock - Draw a custom clock using ImageMagick (or any command-line drawing program)
--
-- Add in your settings.toml:
-- [widget.imagemagickclock]
-- script = "~/.config/noctalia/scripts/imagemagickclock.lua"
-- type = "scripted"

local defaultCommandLine = "magick -size 300x110 canvas:black -draw 'rectangle 0,0 300,110' -pointsize 128 -fill '#FF2400' -draw 'text 0,104 \"%H\"' -fill white -pointsize 84 -draw 'text 116,104 \":%M\"' -fill '#FF2400' -stroke '#FF2400' -strokewidth 5 -draw 'line 220,0 220,110' -strokewidth 0 -stroke none -fill white -pointsize 32 -draw 'text 230, 30 \"%d\"' -draw 'text 230, 64 \"%b\"' -draw 'text 230, 100 \"%Y\"' '%output_file'"
local defaultImageWidth = 60
local defaultImageHeight = 22

barWidget.define({
    label = "ImageMagick Clock",
    icon = "clock",
    description = "Draws a custom clock using ImageMagick.",
    settings = {
        {
            key = "command_line",
            type = "string",
            label = "Command line to draw the clock",
            description = "The command should generate an image file to be displayed as the clock. \"%output_file\" will be replaced with the path to the output file. Then \"%H\", \"%M\", etc. will be replaced with the current time values. See \"man strftime\" for more formatting options.",
            default = defaultCommandLine,
        },
        {
            key = "image_width",
            type = "integer",
            label = "Clock image width",
            default = defaultImageWidth,
            min = 1,
            max = 1000,
        },
        {
            key = "image_height",
            type = "integer",
            label = "Clock image height",
            default = defaultImageHeight,
            min = 1,
            max = 1000,
        },
    }
})

local commandLineTemplate = barWidget.getConfig("command_line") or defaultCommandLine
local imageWidth = barWidget.getConfig("image_width") or defaultImageWidth
local imageHeight = barWidget.getConfig("image_height") or defaultImageHeight

barWidget.setGlyph("clock")
barWidget.setUpdateInterval(100) -- 0.1s precision to updating the clock face as close to the minute change as possible.

local currentClockFacePath = nil
local nextClockFacePath = nil
local nextClockFaceTimestamp = nil
local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR") or "/tmp"
local outputDir = runtimeDir .. "/imagemagickclock"
local generatingClockFace = false

function drawClockFace(timestamp)
    if generatingClockFace then
        return
    end

    generatingClockFace = true

    local outputFilePath = outputDir .. "/" .. os.date("%Y%m%d-%H%M%S", timestamp) .. ".png"

    local commandLine = string.gsub(commandLineTemplate, "%%output_file", outputFilePath)
    commandLine = os.date(commandLine, timestamp)
    commandLine = "mkdir -p '" .. outputDir .. "' && " .. commandLine
    -- print("Running command: " .. commandLine)

    noctalia.runAsync(commandLine, function(result)
        if result.exitCode == 0 then
            if nextClockFacePath then
                noctalia.runAsync("rm '" .. nextClockFacePath .. "'", function(result)
                    if result.exitCode ~= 0 then
                        print("Error removing existing clock face: " .. result.stderr .. " (command: rm '" .. nextClockFacePath .. "') " .. "output: " .. result.stdout)
                    end
                end)
            end
            nextClockFacePath = outputFilePath
        else
            print("Error generating clock face: " .. result.stderr .. " (command: " .. commandLine .. ") " .. "output: " .. result.stdout)
            nextClockFacePath = nil
        end
        nextClockFaceTimestamp = timestamp
        generatingClockFace = false
    end)
end

function update()
    if generatingClockFace or nextClockFaceTimestamp and os.time() < nextClockFaceTimestamp then
        return
    end

    if currentClockFacePath then
        noctalia.runAsync("rm '" .. currentClockFacePath .. "'", function(result)
            if result.exitCode ~= 0 then
                print("Error removing old clock face: " .. result.stderr .. " (command: rm " .. currentClockFacePath .. ") " .. "output: " .. result.stdout)
            end
        end)
        currentClockFacePath = nil
    end

    if nextClockFacePath then
        currentClockFacePath = nextClockFacePath
        nextClockFacePath = nil
        nextClockFaceTimestamp = nil
        barWidget.setImage(currentClockFacePath, false, imageWidth, imageHeight)
    end

    local timestamp = os.time()
    local time = os.date("*t", timestamp)
    local nextTimestamp = timestamp - time.sec + 60
    -- print("Drawing next clock face at " .. os.date("%H:%M:%S", nextTimestamp))
    drawClockFace(nextTimestamp)
end

function onClick()
    noctalia.runAsync("noctalia msg panel-toggle control-center calendar", function(result)
        if result.exitCode ~= 0 then
            print("Error opening URL: " .. result.stderr .. " (command: noctalia msg panel-toggle control-center calendar) " .. "output: " .. result.stdout)
        end
    end)
end

drawClockFace(os.time())
