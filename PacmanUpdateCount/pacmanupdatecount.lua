-- Pacman Update Count — Tells you how many arch packages need updating.
-- Author - Sovereign (https://github.com/ViSovereign)
--
-- Configure the keyboard device in your bar config:
-- [widget.pacmanupdatecount]
-- script = "~/.config/noctalia/scripts/pacmanupdatecount.lua"
-- type = "scripted"
-- update_interval = 60

barWidget.define({
    label = "Pacman Update Count",
    icon = "packages",
    description = "Tells you how many arch packages need updating.",
    settings = {
        {
            key = "update_interval",
            type = "integer",
            label = "Update check interval (in minutes)",
            default = 60,
            min = 30,
            max = 720,
        },
    }
})

barWidget.setGlyph("packages")
local update_interval = barWidget.getConfig("update_interval", 60) * 60 * 1000
barWidget.setUpdateInterval(update_interval)

local function checkCommandsExists()
    local arr = { "paru", "checkupdates" }

    for i, v in ipairs(arr) do
        if not noctalia.commandExists(v) then
            noctalia.notifyError("Pacman Update Count", v .. " command is not installed, please install.")
            return
        end
    end
end

local function checkForUpdates()
    local cmd = "total_updates=$(( $(paru -Qua | wc -l) + $(checkupdates | wc -l) )) && echo $total_updates"
    noctalia.runAsync(cmd, function(result)
        local updateCount = result.stdout
        if string.match(updateCount, "^%d%d*$") then
            noctalia.log("update total is " .. updateCount)
            barWidget.setText(updateCount)
        else
            noctalia.notifyError("Pacman Update Count", "Command did not return a number: " .. updateCount)
            barWidget.setText("??")
        end
    end)
end

function update()
    barWidget.setText("--")
    checkCommandsExists()
    checkForUpdates()
end

function onClick()
    update()
end

function onIpc(event, payload)
    if event == "refresh" then
        update()
    end
end
