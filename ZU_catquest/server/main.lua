local ESX = exports["es_extended"]:getSharedObject()

MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS cat_course_scores (
            id INT AUTO_INCREMENT PRIMARY KEY,
            player_identifier VARCHAR(50) NOT NULL,
            player_name VARCHAR(50) NOT NULL,
            time FLOAT NOT NULL,
            date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {}, function(rowsChanged)
        print("Table cat_course_scores créée ou déjà existante")
    end)
end)

RegisterNetEvent('cat_course:finishCourse')
AddEventHandler('cat_course:finishCourse', function(time)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local moneyReward = math.random(Config.Rewards.MinMoney, Config.Rewards.MaxMoney)
    xPlayer.addMoney(moneyReward)
    
    local rewardMessage = 'Vous avez reçu ' .. moneyReward .. '$ et les jouets suivants :'
    
    for _, toy in ipairs(Config.Rewards.CatToys) do
        local quantity = math.random(toy.min, toy.max)
        if quantity > 0 then
            xPlayer.addInventoryItem(toy.name, quantity)
            rewardMessage = rewardMessage .. '\n- ' .. quantity .. 'x ' .. toy.label
        end
    end
    
    TriggerClientEvent('esx:showNotification', source, rewardMessage)
    
    MySQL.Async.execute('INSERT INTO cat_course_scores (player_identifier, player_name, time) VALUES (@identifier, @name, @time)', {
        ['@identifier'] = xPlayer.identifier,
        ['@name'] = xPlayer.getName(),
        ['@time'] = time
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("Score enregistré pour " .. xPlayer.getName())
        end
    end)
end)

ESX.RegisterServerCallback('cat_course:getTopScores', function(source, cb)
    MySQL.Async.fetchAll('SELECT player_name, time FROM cat_course_scores ORDER BY time ASC LIMIT 10', {}, function(results)
        cb(results)
    end)
end)