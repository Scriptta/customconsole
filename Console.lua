--[[
©️ 2024 upio

ConsoleUtils.lua, a utility made to help with logging dynamic messages in roblox console.
https://mshub.mstudio45.com/
https://www.upio.dev/

Please do not redistribute or claim the code as your own.
However you may use it anywhere without any credits (but credits are appreciated <3)

]]

if not getgenv()._console_message_counter then
    getgenv()._console_message_counter = 3000
end

local module = {
    Images = { -- scrapped from constants module
		Minimize = "rbxasset://textures/DevConsole/Minimize.png",
		Maximize = "rbxasset://textures/DevConsole/Maximize.png",
		Clear = "rbxasset://textures/DevConsole/Clear.png",
		Close = "rbxasset://textures/DevConsole/Close.png",
		Search = "rbxasset://textures/DevConsole/Search.png",
		Error = "rbxasset://textures/DevConsole/Error.png",
		Warning = "rbxasset://textures/DevConsole/Warning.png",
		Info = "rbxasset://textures/DevConsole/Info.png",
		Check = "rbxasset://textures/ui/LuaChat/icons/ic-check.png",
		FilterUnfilled = "rbxasset://textures/DevConsole/Filter-stroke.png",
		FilterFilled = "rbxasset://textures/DevConsole/Filter-filled.png",
		RightArrow = "rbxasset://textures/DevConsole/Arrow.png",
		DownArrow = "rbxasset://textures/TerrainTools/button_arrow_down.png",
	},

	Colors = {
		Black = Color3.fromRGB(0, 0, 0),
		BaseGray = Color3.fromRGB(30, 30, 30),
		TextBoxGray = Color3.fromRGB(45, 45, 45),
		ErrorRed = Color3.fromRGB(215, 90, 74),
		HighlightBlue = Color3.fromRGB(0, 162, 255),
		WarningYellow = Color3.fromRGB(255, 218, 68),
		SelectedBlue = Color3.fromRGB(50, 181, 255),
		UnselectedGray = Color3.fromRGB(78, 84, 96),
		SelectedGray = Color3.fromRGB(102, 108, 119),
		HoverGreen = Color3.fromRGB(70, 197, 124),
		TabUnselectedGray = Color3.fromRGB(102, 108, 119),
		BorderGray = Color3.fromRGB(184, 184, 184),
		Text = Color3.fromRGB(255, 255, 255),
		ActiveBox = Color3.fromRGB(63, 198, 121),
		InactiveBox = Color3.fromRGB(184, 184, 184),
	}
}

function module.print(msg, img, clr)
    getgenv()._console_message_counter = getgenv()._console_message_counter + 1

    local message_index = -1
    local MSG_GUID = tostring(_console_message_counter)

    local timestamp = ""

    local message = msg
    local image = img or ""
    local color = clr or Color3.fromRGB(255, 255, 255)

    print(MSG_GUID)

    task.delay(0.05, function()
        repeat task.wait(.15)
            for i, data in pairs(game:GetService("LogService"):GetLogHistory()) do
                if tostring(data.message) == tostring(MSG_GUID) then
                    message_index = i+1
                    break
                end
            end
        until message_index ~= -1    
    end)

    local function is_cons_logs_open()
        local console_master = game:GetService("CoreGui"):FindFirstChild("DevConsoleMaster")

        if not console_master then
            return false
        end

        local window = console_master:FindFirstChild("DevConsoleWindow")

        if not window then
            return false
        end

        local dev_console_ui = window:FindFirstChild("DevConsoleUI")

        if not dev_console_ui then
            return false
        end

        return (dev_console_ui:FindFirstChild("MainView") and dev_console_ui.MainView:FindFirstChild("ClientLog"))
    end

    local conn; conn = game:GetService("RunService").RenderStepped:Connect(function()
        local is_console_open = is_cons_logs_open()

        if is_console_open then
            local ConsoleUI = game:GetService("CoreGui").DevConsoleMaster.DevConsoleWindow.DevConsoleUI
            local log = ConsoleUI.MainView.ClientLog:FindFirstChild(tostring(message_index))
            
            if not log then
                return
            end

            local msg = log:FindFirstChild("msg")
            local img = log:FindFirstChild("image")

            if not msg or not img then
                return
            end

            if timestamp == "" then
                timestamp = msg.Text:sub(1, 8)
            end

            msg.Text = timestamp .. " -- " .. message
            msg.TextColor3 = color

            img.Image = image
            img.ImageColor3 = color
        end
    end)

    local log_module = {}

    function log_module.update(_message, _image, _color)
        message = _message or message
        image = _image or image
        color = _color or color
    end

    function log_module.cleanup()
        conn:Disconnect()
    end

    return log_module
end

function module.progressbar(params)
    if typeof(params) == "string" then
        params = {msg = params}
    end

    local msg = params["msg"]
    local clr = params["clr"]
    local img = params["img"]

    local progressbar_length = params["length"] or 10

    local progressbar_char = "█"
    local progressbar_empty = "░"

    local message = module.print(msg, img, clr)
    local progress = 0

    local progressbar_module = {}

    function progressbar_module.update_message(_message, _image, _color)
        message.update_message(_message, _image, _color)
    end

    function progressbar_module.update_progress(_progress)
        progress = _progress
        local progressbar_string = ""

        local normalized_progress = math.floor(progress / progressbar_length * 100)

        for i=1, 10 do
            if i <= progress / progressbar_length * 10 then
                progressbar_string = progressbar_string .. progressbar_char
            else
                progressbar_string = progressbar_string .. progressbar_empty
            end
        end

        message.update_message(msg .. " [" .. progressbar_string .. "] " .. normalized_progress .. "%", img, clr)
    end

    function progressbar_module.update_message_with_progress(_message,_progress)
        _progress = _progress or progress

        msg = _message
        progressbar_module.update_progress(_progress)
    end

    function progressbar_module.cleanup()
        message.cleanup()
    end

    return progressbar_module
end

return module
