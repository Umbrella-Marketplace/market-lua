local TimerManager = require("libs.timer")
local JSON = require("assets.JSON")
local Config = require("config")
local UI = require("ui")

local AuthManager = {}

local AUTH_STATUS = {
    AUTHORIZED = 1,
    UNAUTHORIZED = 0,
    PENDING_CONFIRMATION = -1
}

local jwtData = {
    jwtToken = "",
    isAuthorized = false,
    tempKey = "",
    message = ""
}

local wasUnauthorizedBefore = true
local isUiInitialized = false
local isAuthInProgress = false

local authRequest = {
    id = user_info.user_id,
    name = user_info.username
}

local headers = {
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
    ["User-Agent"] = "MarketClient/1.0"
}

local function initializeUI()
    if jwtData.isAuthorized == AUTH_STATUS.AUTHORIZED then
        UI.CreateAuthorizedMenu(jwtData)
    elseif jwtData.isAuthorized == AUTH_STATUS.UNAUTHORIZED then
        UI.CreateUnauthorizedMenu(jwtData)
    elseif jwtData.isAuthorized == AUTH_STATUS.PENDING_CONFIRMATION then
        UI.CreatePendingConfirmationMenu(jwtData)
    end
    isUiInitialized = true
end

local function handleAuthResponse(json)
    jwtData.isAuthorized = json.isAuthorized
    print(jwtData.isAuthorized)
    if jwtData.isAuthorized == AUTH_STATUS.AUTHORIZED then
        jwtData.jwtToken = json.jwt or ""
        if wasUnauthorizedBefore then
            Engine.ReloadScriptSystem()
        end
    elseif jwtData.isAuthorized == AUTH_STATUS.UNAUTHORIZED then
        jwtData.tempKey = json.tempKey or ""
        print(json)
        UI.UpdateTempKeyDisplay(jwtData.tempKey)
        TimerManager:stop("RetryAuth")
        local retryTime = tonumber(json.validUntil) or 0
        TimerManager:start("RetryAuth", retryTime + 1, authLoop)
    elseif jwtData.isAuthorized == AUTH_STATUS.PENDING_CONFIRMATION then
        jwtData.jwtToken = ""
    end
    if not isUiInitialized then
        initializeUI()
    end
    wasUnauthorizedBefore = (
        jwtData.isAuthorized == AUTH_STATUS.UNAUTHORIZED or
        jwtData.isAuthorized == AUTH_STATUS.PENDING_CONFIRMATION
    )
end

local function authLoop()
    if isAuthInProgress then return end
    isAuthInProgress = true
    HTTP.Request("POST", Config.Server.BASE_URL .. "/auth", {
        headers = headers,
        data = JSON:encode(authRequest)
    }, function(response)
        isAuthInProgress = false
        local ok, json = pcall(JSON.decode, JSON, response.response)
        if not ok or type(json) ~= "table" then
            return
        end
        handleAuthResponse(json)
    end, "auth_request")
end

function AuthManager.Start()
    authLoop()
end

function AuthManager.Update()
    TimerManager:update()
end

return AuthManager