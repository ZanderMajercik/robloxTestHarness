-- Helpers to allow global modification of HTTP settings.
local HTTPSettings = {}

HTTPSettings.baseURLAndPort = "http://localhost:5000/"
HTTPSettings.secondsPerHTTPRequest = 60 / 500

return HTTPSettings
