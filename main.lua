local AuthManager = require("auth")

AuthManager.Start()

return {
    OnUpdateEx = function()
        AuthManager.Update()
    end
}