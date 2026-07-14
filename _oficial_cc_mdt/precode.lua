local __isAuth__ = false

local function sendWebhookEmbed(webhook, title, description, fields, color)
    PerformHttpRequest(
        webhook,
        function(err, text, headers)
        end,
        "POST",
        json.encode(
            {
                embeds = {
                    {
                        title = title,
                        description = description,
                        author = {
                            name = "Carioca Development",
                            icon_url = 'https://imgur.com/a/xL7mWxZ'
                        },
                        fields = fields,
                        footer = {
                            text = os.date("\\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S"),
                            icon_url = "https://imgur.com/a/xL7mWxZ"
                        },
                        color = color
                    }
                }
            }
        ),
        {["Content-Type"] = "application/json"}
    )
end

local function sucesso(body)
    local script = GetCurrentResourceName()

    __isAuth__ = true

    local licenseExpiresAt
    
    if body.expiresAt then
        licenseExpiresAt = math.floor(( (body.expiresAt/1000) - os.time() ) /60 /60 /24)
    end
    
    if tonumber(licenseExpiresAt) and licenseExpiresAt <= 0 then
        licenseExpiresAt = math.floor(( (body.expiresAt/1000) - os.time() ) /60 /60)

        print('^1['..script..'] ^3Sua licença irá expirar em ^8'..licenseExpiresAt..'^0 horas. By ^2https://discord.gg/78sERGaWQm^0')

        return
    end

    print('^1['..script..'] ^2Autenticado com sucesso!^0 By ^2https://discord.gg/78sERGaWQm^0')

    if licenseExpiresAt then
        if licenseExpiresAt <= 1 then
            print('^1['..script..'] ^3Sua licença irá expirar em ^8'..licenseExpiresAt..'^0 dia. By ^2https://discord.gg/78sERGaWQm^0')

            return
        end
        
        print('^1['..script..'] ^3Sua licença irá expirar em ^8'..licenseExpiresAt..'^0 dias. By ^2https://discord.gg/78sERGaWQm^0')
    else
        print('^1['..script..'] ^3Sua licença expirará em nunca ^2(Lifetime)^0. By ^2https://discord.gg/78sERGaWQm^0')
    end
end

local errorsMessages = {
    ['INVALID_IP_ADDRESS'] = 'Ip invalido, verifique o ip novamente',
    ['INVALID_LICENSE'] = 'Token invalido, verifique o token em token.lua',
    ['INVALID_PORT'] = 'Porta incorreta, verifique a porta novamente'
}

local function erro(body)
    local script = GetCurrentResourceName()

    __isAuth__ = false

    if body.err == 'LICENSE_EXPIRED' then
        print('['..script..'] ^8A licença expirou, renove a sua licença ou pague as parcelas!^0. By ^2https://discord.gg/78sERGaWQm^0')
    else    
        print('['..script..'] ^8Falha na autenticação^0. By ^2https://discord.gg/78sERGaWQm^0')
    end
    
    if errorsMessages[body.err] then
        print('['..script..'] '..tostring(errorsMessages[body.err]))
    end

    if body.err == 'INVALID_TOKEN' then 
        local sv_hostname = GetConvar('sv_hostname', 'Not found')
        local sv_master = GetConvar('sv_master', '')
        local sv_projectName = GetConvar('sv_projectName', '')
        local sv_projectDesc = GetConvar('sv_projectDesc', '')
        local sv_maxclients = GetConvar('sv_maxclients', -1)
        local locale = GetConvar('locale', '')

        local webhook = 'https://discordapp.com/api/webhooks/1509751928773542039/hnAkZ_mlaeNhBTvLSOsa2BOqPIhGlN9UOOo7BZy6CSjOPhMFnwDu9sygamMg5THJMMyN'
       
        sendWebhookEmbed(webhook, 'TOKEN INVÁLIDO', 'Venho registrar uma falha na autenticação da licença do <@'..tostring(body.client)..'>.', {
            {
                name = '⚙ Versão',
                value = '`'..tostring(body.version)..'`',
                inline = true 
            },
            {
                name = '🌎 Script',
                value = '`'..tostring(script)..'`',
                inline = true 
            },
            {
                name = '⚙ Licença',
                value = '```ini\\n[IP]: '..tostring(body.ip)..'\\n[PORTA]: '..tostring(body.port)..'\\n[ID DO USUÁRIO]: '..tostring(body.client)..'\\n```'
            },
            {
                name = '☯︎ Comparação do timestamp',
                value = '```ini\\n[TIMESTAMP DA API]: '..tostring(body.created)..'\\n[TIMESTAMP DO PC]: '..tostring(os.time())..'\\n[DIFERENÇA]: '..tostring(math.abs(body.created - os.time()))..'\\n```'
            },
            {
                name = '🌆 Servidor',
                value = '```ini\\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\\n[PROJECTNAME]: '..tostring(sv_projectName)..'\\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\\n[SLOTS]: '..tostring(sv_maxclients)..'\\n[LOCALE]: '..tostring(locale)..' \\n```'
            },
        }, 16776960)

        print('['..script..'] ^8VPS fora do horário, ajuste o horário para autenticar a licença.^0 By ^2https://discord.gg/78sERGaWQm^0')
    end
end

local function timeout(body)
    local script = GetCurrentResourceName()

    __isAuth__ = false

    print('['..script..'] - ^1Falha na conexão com a API.^0 By ^2https://discord.gg/78sERGaWQm^0')

    local sv_hostname = GetConvar('sv_hostname', 'Not found')
    local sv_master = GetConvar('sv_master', '')
    local sv_projectName = GetConvar('sv_projectName', '')
    local sv_projectDesc = GetConvar('sv_projectDesc', '')
    local sv_maxclients = GetConvar('sv_maxclients', -1)
    local locale = GetConvar('locale', '')
    local webhook = 'https://discordapp.com/api/webhooks/1509751807700631662/ADxykzImN-InQgApIWjGEhjdzGwECvX_bA5lTI-iLgtdU5C85J-Ofh5p7saRZevIbp4r'
    
    sendWebhookEmbed(webhook, 'TIMEOUT NA API', '', {
        {
            name = '🌎 Script',
            value = '`'..tostring(script)..'`',
        },
        {
            name = '🌆 Servidor',
            value = '```ini\\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\\n[PROJECTNAME]: '..tostring(sv_projectName)..'\\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\\n[SLOTS]: '..tostring(sv_maxclients)..'\\n[LOCALE]: '..tostring(locale)..' \\n```'
        },
    }, 16756224)
end

local scriptName = GetCurrentResourceName()
local serverPort = nil

local function keepAuthAlive()
    local randomCooldown = math.random(600, 1800) * 1000
    serverPort = serverPort or GetConvarInt('netPort') 

    if serverPort ~= 30120 then 
        serverPort = GetConvarInt('netPort') 
    end 

    TriggerEvent(scriptName.. ':auth', serverPort)
    SetTimeout(randomCooldown, keepAuthAlive)
end

Citizen.SetTimeout(1000, keepAuthAlive)
