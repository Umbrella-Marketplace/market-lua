local Config = require("config")
local Placeholder = require("libs.placeholder")

local tab = Menu.Create(Config.UI.TabName, Config.UI.ScriptTab, Config.UI.ScriptName)
tab:Icon(Config.UI.Icons.Main)

local UI = {}

local authTab = tab:Create("Authorization")
local console = Menu.Find("SettingsHidden", "", "", "", "Main", "Log Window")

local inputBox


function UI.CreateAuthorizedMenu(jwtData)
end

function UI.CreatePendingConfirmationMenu(jwtData)
    local group = authTab:Create("Ожидание подтверждения")
    group:Label("Подтвердите вход в аккаунт через бота")
end

--#region Unauthorized
function UI.CreateUnauthorizedMenu(jwtData)
    local group = authTab:Create("Unauthorized Access")
    inputBox = group:Input("Token", "Loading...")
    inputBox:Set(jwtData.tempKey)

    local labelText = Placeholder.Replace(
        "Отправьте этот токен в бота {BOT_USERNAME} для авторизации.",
        { BOT_USERNAME = Config.Server.BOT_USERNAME }
    )
    
    group:Label(labelText)
    group:Button("Открыть/Закрыть консоль", function()
        if console then
            console:Set(not console:Get())
        end
    end)
end

function UI.UpdateTempKeyDisplay(key)
    print(key)
    if inputBox then
        inputBox:Set(key)
    end
end
--#endregion

return UI