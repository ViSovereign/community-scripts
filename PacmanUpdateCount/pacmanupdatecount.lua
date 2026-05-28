-- Pacman Update Count — Arch update checker (Pacman + AUR)
-- Author - Sovereign, Mathew-D
--
-- Configure the keyboard device in your bar config:
-- [widget.pacmanupdatecount]
-- script = "/path/to/scripts/pacmanupdatecount.lua"
-- type = "scripted"
-- glyph = "packages"
-- update_interval = 60
-- aur_helper = "paru"
-- color_bool = false
-- color_count = 100
-- color_is = "error"

barWidget.define({
    label = "Pacman Update Count",
    icon = "packages",
    description = "Tells you how many arch packages need updating.",
    settings = {
        { key = "glyph", type = "glyph", label = "Glyph", default = "packages" },
        {
            key = "update_interval",
            type = "integer",
            label = "Update check interval (in minutes)",
            default = 60,
            min = 30,
            max = 720,
        },
        {
            key = "aur_helper",
            type = "select",
            label = "AUR Helper",
            default = "paru",
            options = {
                { label = "Paru", value = "paru" },
                { label = "Yay",  value = "yay" },
            }
        },
        {
            key = "color_bool",
            type = "bool",
            label = "Enable color change based on update count",
            default = false,
        },
        {
            key = "color_count",
            type = "integer",
            label = "Warn on update count greater than",
            default = 100,
            min = 1,
            max = 500,
            visible_when = { key = "color_bool", values = { "true" } }
        },
        {
            key = "color_is",
            type = "color",
            label = "Warn color",
            default = "error",
            visible_when = { key = "color_bool", values = { "true" } }
        },
    }
})



local glyph = barWidget.getConfig("glyph", "packages")
local aur_helper = barWidget.getConfig("aur_helper", "paru")
local color_bool = barWidget.getConfig("color_bool", false)
local color_count = barWidget.getConfig("color_count", 100)
local color_is = barWidget.getConfig("color_is", "error")
local update_interval = barWidget.getConfig("update_interval", 60) * 60 * 1000

barWidget.setGlyph(glyph)
barWidget.setUpdateInterval(update_interval)

local function checkCommandsExists()
    local arr = { aur_helper, "checkupdates" }

    for _, v in ipairs(arr) do
        if not noctalia.commandExists(v) then
            noctalia.notifyError(
                "Pacman Update Count",
                v .. " is not installed."
            )
            return false
        end
    end
    return true
end

local function checkForUpdates()
    local cmd = string.format(
        "r=$(checkupdates 2>/dev/null | wc -l); a=$(%s -Qua 2>/dev/null | wc -l); echo " ..
        '"' .. "$r,$a,$((r+a))" .. '"',
        aur_helper
    )
    noctalia.runAsync(cmd, function(result)
        local updateCount = (result.stdout or ""):gsub("%s+", "")

        local updateCounts = {}
        for value in string.gmatch(updateCount, "([^,]+)") do
            table.insert(updateCounts, value)
        end

        setTooltip(updateCounts[1], updateCounts[2])
        if updateCounts[3]:match("^%d+$") then
            updateColor(updateCounts[3])
            barWidget.setText(updateCounts[3])
        else
            noctalia.notifyError(
                "Pacman Update Count",
                "Invalid output: " .. updateCounts
            )
            barWidget.setText("??")
        end
    end)
end

function updateColor(total)
    if not color_bool then return end

    local num = tonumber(total)
    if num > color_count then
        barWidget.setColor(color_is, "script")
        barWidget.setGlyphColor(color_is, "script")
    end
end

local function echoStringCreation()
    local echoString =
    "echo \"Noctailia Pacman Update Count\" && echo \"Updating system...\" && echo \"=================\""
    return echoString
end

local function pauseStringCreation()
    local echoString = "read -n 1 -s -r -p \"Press any key to close.\""
    return echoString
end

function setTooltip(pacman, aur)
    local options = {
        { key = "Left click",   value = "Refresh" },
        { key = "Middle click", value = "View" },
        { key = "Right click",  value = "Update" },
        { key = "pacman",       value = pacman },
        { key = aur_helper,     value = aur },
    }
    barWidget.setTooltip(options)
end

function update()
    barWidget.setText("--")
    setTooltip()

    if not checkCommandsExists() then return end

    checkForUpdates()
end

function onClick()
    update()
end

function onMiddleClick()
    local middleCommand = string.format(
        "checkupdates | column -t && %s -Qua | column -t" .. " && " .. pauseStringCreation(),
        aur_helper
    )
    noctalia.runInTerminal(middleCommand)
end

function onRightClick()
    local rightCommand = echoStringCreation() .. " && " .. "sudo pacman -Syu" .. " && " .. pauseStringCreation()
    noctalia.runInTerminal(rightCommand)
end

function onIpc(event, payload)
    if event == "refresh" then
        update()
    end
end
