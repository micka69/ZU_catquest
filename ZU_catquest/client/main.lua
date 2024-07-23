local ESX = exports["es_extended"]:getSharedObject()
local npc = nil
local npcBlip = nil
local isOnCourse = false
local currentCheckpoint = 1
local checkpoint = nil
local checkpointBlip = nil
local startTime, endTime
local currentCatType = ""
local nextCheckpointDirection = vector3(0, 0, 0)

local function PlayCatSound(soundName)
    PlaySoundFrontend(-1, soundName, "Cat_Sounds", 1)
end

local function norm(v)
    local length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    return vector3(v.x / length, v.y / length, v.z / length)
end

function FinishCourse()
    isOnCourse = false
    endTime = GetGameTimer()
    local totalTime = (endTime - startTime) / 1000
    
    if DoesBlipExist(checkpointBlip) then
        RemoveBlip(checkpointBlip)
    end
    
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        local model = GetHashKey(skin.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
    
    TriggerServerEvent('cat_course:finishCourse', totalTime)
    
    PlayCatSound('Purr')

    ESX.ShowNotification(string.format('Parcours terminé. Temps: %.2f secondes.', totalTime))
end

local function CreateNextCheckpoint()
    if currentCheckpoint > #Config.Checkpoints then
        FinishCourse()
        return
    end

    local checkpointData = Config.Checkpoints[currentCheckpoint]
    
    if DoesBlipExist(checkpointBlip) then
        RemoveBlip(checkpointBlip)
    end
    
    checkpointBlip = AddBlipForCoord(checkpointData.pos.x, checkpointData.pos.y, checkpointData.pos.z)
    SetBlipSprite(checkpointBlip, 1)
    SetBlipColour(checkpointBlip, 5)
    SetBlipScale(checkpointBlip, 0.8)
    SetBlipAsShortRange(checkpointBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Checkpoint " .. currentCheckpoint)
    EndTextCommandSetBlipName(checkpointBlip)

    checkpoint = checkpointData.pos

    -- Calculer la direction vers le prochain checkpoint
    local playerPos = GetEntityCoords(PlayerPedId())
    nextCheckpointDirection = vector3(checkpoint.x - playerPos.x, checkpoint.y - playerPos.y, checkpoint.z - playerPos.z)
    nextCheckpointDirection = norm(nextCheckpointDirection)
end

local function StartCourse()
    isOnCourse = true
    currentCheckpoint = 1
    startTime = GetGameTimer()
    
    local model = Config.CatModels[math.random(#Config.CatModels)]
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    
    currentCatType = GetEntityModel(PlayerPedId())
    
    CreateNextCheckpoint()
 
    PlayCatSound('Meow')

    ESX.ShowNotification('Parcours commencé. Vous êtes transformé en chat. Atteignez tous les checkpoints !')
end

local function CreateStartNPC()
    Citizen.CreateThread(function()
        if DoesEntityExist(npc) then
            DeletePed(npc)
        end
        if DoesBlipExist(npcBlip) then
            RemoveBlip(npcBlip)
        end

        local model = Config.StartNPC.model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end
        
        npc = CreatePed(4, model, Config.StartNPC.coords.x, Config.StartNPC.coords.y, Config.StartNPC.coords.z, Config.StartNPC.coords.w, false, true)
        SetEntityHeading(npc, Config.StartNPC.coords.w)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        
        npcBlip = AddBlipForCoord(Config.StartNPC.coords.x, Config.StartNPC.coords.y, Config.StartNPC.coords.z)
        SetBlipSprite(npcBlip, Config.StartNPC.blip.sprite)
        SetBlipDisplay(npcBlip, 4)
        SetBlipScale(npcBlip, Config.StartNPC.blip.scale)
        SetBlipColour(npcBlip, Config.StartNPC.blip.color)
        SetBlipAsShortRange(npcBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.StartNPC.blip.label)
        EndTextCommandSetBlipName(npcBlip)

        print("PNJ et blip du parcours du chat créés avec succès")
    end)
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(10)
    end
    CreateStartNPC()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isOnCourse then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            if checkpoint then
                local checkpointData = Config.Checkpoints[currentCheckpoint]
                -- Dessiner le checkpoint existant
                DrawMarker(1, checkpoint.x, checkpoint.y, checkpoint.z - 1.0, 0, 0, 0, 0, 0, 0, 
                           checkpointData.radius * 2, checkpointData.radius * 2, 1.0, 255, 0, 0, 200, false, true, 2, false, nil, nil, false)
                
                -- Dessiner le marker directionnel
                local markerDistance = 5.0  -- Distance à laquelle placer le marker devant le joueur
                local markerPos = playerCoords + (nextCheckpointDirection * markerDistance)
                DrawMarker(0, markerPos.x, markerPos.y, markerPos.z + 2.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 200, false, true, 2, false, nil, nil, false)
                
                if #(playerCoords - checkpoint) < checkpointData.radius then
                    PlayCatSound('Meow')
                    ESX.ShowNotification('Checkpoint passé: ' .. checkpointData.description)
                    currentCheckpoint = currentCheckpoint + 1
                    CreateNextCheckpoint()
                end
            end
            
            if IsControlPressed(0, 36) then  -- Touche Ctrl gauche
                SetPedMoveRateOverride(playerPed, Config.CatAbilities.CrouchSpeed)
            else
                SetPedMoveRateOverride(playerPed, 1.0)
            end
        end

        if not isOnCourse and DoesEntityExist(npc) then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local npcCoords = GetEntityCoords(npc)
            
            if #(playerCoords - npcCoords) < 2.0 then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour commencer le parcours du chat")
                if IsControlJustReleased(0, 38) then  -- Touche E
                    StartCourse()
                end
            end
        end
    end
end)

RegisterCommand('debugcatnpc', function()
    print("Débug NPC Chat:")
    print("NPC existe: " .. tostring(DoesEntityExist(npc)))
    if DoesEntityExist(npc) then
        local coords = GetEntityCoords(npc)
        print("Coordonnées NPC: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
    end
    print("Blip existe: " .. tostring(DoesBlipExist(npcBlip)))
    print("Coordonnées config: " .. Config.StartNPC.coords.x .. ", " .. Config.StartNPC.coords.y .. ", " .. Config.StartNPC.coords.z)
end, false)

RegisterCommand('respawncatnpc', function()
    CreateStartNPC()
end, false)

RegisterCommand('catscores', function()
    ESX.TriggerServerCallback('cat_course:getTopScores', function(scores)
        for i, score in ipairs(scores) do
            print(string.format("%d. %s - Temps: %.2fs", i, score.player_name, score.time))
        end
    end)
end, false)