_G.IS_SERVER = IsDuplicityVersion()

_G.LANGUAGE = require('config/shared/language')
_G.PRISON_CONFIG = require('config/shared/prison')
_G.GENERAL_CONFIG = require('config/shared/general')
_G.LEGISLATION_CONFIG = require('config/shared/legislation')
_G.ORGANIZATIONS_CONFIG = require('config/shared/organizations')

if IS_SERVER then
    -- _G.SERVER_CONFIG = require('config/server/config')
else
    -- _G.CLIENT_CONFIG = require('config/client/config')
end