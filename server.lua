RegisterCommand('riscattacodice', function(source, args)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        print("APRO IL PANNELLO PER RISCATTARE IL CODICE")
        TriggerClientEvent('Christian:Pannel', source)
    end    
end)

RegisterCommand('generaCodice', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local idDiscord = tonumber(args[1])
    local utilizzato = false
    
    local rewards = {}
    for i = 2, #args, 2 do
        local reward = tostring(args[i])
        local quantity = tonumber(args[i + 1])
        if reward and quantity then
            table.insert(rewards, { reward = reward, quantity = quantity })
        end
    end
    
    if xPlayer then
        for _, v in pairs(Config.AllowGroup) do 
            if xPlayer.getGroup() == v then
                local file = LoadResourceFile(GetCurrentResourceName(), 'code.json')
                local codes = {}
                
                if file then 
                    codes = json.decode(file) or {}
                end

                local codiceEsistente = false

                for k, _ in pairs(codes) do 
                    if k == tostring(codice) then
                        codiceEsistente = true
                        break
                    end
                end
                
                if not codiceEsistente then 
                    local code 
                    local isUnique = false 
                    
                    while not isUnique do 
                        code = tostring(math.random(10000, 99999))
                        if not codes[code] then 
                            isUnique = true
                        end
                    end
                    
                    codes[code] = { idDiscord = idDiscord, ricompense = rewards, utilizzato = utilizzato }

                    SaveResourceFile(GetCurrentResourceName(), 'code.json', json.encode(codes, { indent = true }), -1)
                    print("Codice generato: " .. code)
                    TriggerClientEvent('ox_lib:notify', source, {title = "RICOMPENSA", description ="Codice generato: " .. code.." è copiato negli appunti.", type = 'success' })
                    TriggerClientEvent('Christian:ClipBoardClient', source, code)
                else
                    print("Codice esistente.")
                    TriggerClientEvent('ox_lib:notify', source, "Codice esistente.")
                end
                return
            end
        end
        
        TriggerClientEvent('ox_lib:notify', source, {title = "RICOMPENSA", description ="NON HAI IL PERMESSO PER QUESTO COMANDO ", type = 'error' })
    end
end)


TriggerClientEvent('chat:addSuggestion', -1, '/generaCodice', 'Genera un codice da assegnare a un utente',
{
    { name="Discord ID", help="L'ID Discord dell'utente (numero)" },
    { name="Ricompensa", help="Nome della ricompensa inserendo gli apici (es. 'WEAPON_PISTOL_MK2')" },
    { name="Quantità", help="Quantità della ricompensa (es. 10)" }
})

RegisterNetEvent('ChristianCheckCode')
AddEventHandler('ChristianCheckCode', function(codice)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then 
        local file = LoadResourceFile(GetCurrentResourceName(), "code.json")
        local codes = json.decode(file) or {}

        local Identifier = GetPlayerIdentifiers(_source)
        local discordId 
        for _, v in ipairs(Identifier) do 
            if string.find(v, "^discord:") then 
                discordId = string.sub(v, 9)
                break
            end
        end

        local codiceInfo = codes[tostring(codice)]
        if codiceInfo and codiceInfo.idDiscord == tonumber(discordId) then
            if codiceInfo.utilizzato then
                TriggerClientEvent('ox_lib:notify', _source, {title = "RICOMPENSA", description ="Codice già utilizzato", type = 'error' })
            else
                for _, reward in pairs(codiceInfo.ricompense) do
                    exports.ox_inventory:AddItem(xPlayer.source, reward.reward, reward.quantity)
                end
                
                -- Imposta il codice come utilizzato
                codes[tostring(codice)].utilizzato = true
                SaveResourceFile(GetCurrentResourceName(), 'code.json', json.encode(codes, { indent = true }), -1)
                TriggerClientEvent('esx:showNotification', _source, "Codice riscattato con successo")
            end
        else
            TriggerClientEvent('esx:showNotification', _source, "Codice non valido o Discord ID non corrispondente")
        end
    end
end)

function GenerateCode() 
    math.random()
end