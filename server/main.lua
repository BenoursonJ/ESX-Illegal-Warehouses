ESX = nil
Storage1stat, Storage2stat, Storage3stat, Storage4stat, Storage5stat, Storage6stat = false, false, false, false, false, false


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('esx_illegalWarehouses:getStorageOwner', function(source, cb, storageName)
	MySQL.Async.fetchAll('SELECT owner FROM illegal_warehouses WHERE warehouse = @id', { ['@id'] = storageName }, function(result)
		cb(string.lower(result[1].owner))
	  end)
end)

RegisterServerEvent('esx_illegalWarehouses:getStockItem')
AddEventHandler('esx_illegalWarehouses:getStockItem', function(itemName, count, storageZone)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('esx_addoninventory:getSharedInventory', storageZone, function(inventory)
		local item = inventory.getItem(itemName)
		if item.count >= count then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)
	end)
end)

ESX.RegisterServerCallback('esx_illegalWarehouses:getStockItems', function(source, cb, storageZone)
	TriggerEvent('esx_addoninventory:getSharedInventory', storageZone, function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('esx_illegalWarehouses:putStockItems')
AddEventHandler('esx_illegalWarehouses:putStockItems', function(itemName, count, storageZone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local store = string.lower(storageZone)
	TriggerEvent('esx_addoninventory:getSharedInventory', store, function(inventory)
		local item = inventory.getItem(itemName)
		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. item.label)
	end)
end)

ESX.RegisterServerCallback('esx_illegalWarehouses:getPlayerInventory', function(source, cb)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory
	cb({
		items      = items
	})
end)




ESX.RegisterServerCallback('esx_illegalWarehouses:getWeapons', function(source, cb, storageZone)
	TriggerEvent('esx_datastore:getSharedDataStore', storageZone, function(store)
		local weapons = store.get('weapons')
		if weapons == nil then
			weapons = {}
		end
		cb(weapons)
	end)
end)



ESX.RegisterServerCallback('esx_illegalWarehouses:addWeapon', function(source, cb, weaponName, removeWeapon, storageZone)
	local xPlayer = ESX.GetPlayerFromId(source)
	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end
	TriggerEvent('esx_datastore:getSharedDataStore', storageZone, function(store)
		local weapons = store.get('weapons')
		if weapons == nil then
			weapons = {}
		end
		local foundWeapon = false
		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end
		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end
		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_illegalWarehouses:removeWeapon', function(source, cb, weaponName, storageZone)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 200)
	TriggerEvent('esx_datastore:getSharedDataStore', storageZone, function(store)
		local weapons = store.get('weapons')
		if weapons == nil then
			weapons = {}
		end
		local foundWeapon = false
		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end
		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 0
			})
		end
		store.set('weapons', weapons)
		cb()
	end)
end)


ESX.RegisterServerCallback('esx_illegalWarehouses:getWarehouses', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT * FROM illegal_warehouses',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				label = result[i].label,
				warehouse = result[i].warehouse,
				owner = result[i].owner
			})
		end
		cb(customers)
	end)
end)

RegisterServerEvent('esx_illegalWarehouses:revoke')
AddEventHandler('esx_illegalWarehouses:revoke', function(storageZone)
	MySQL.Async.execute('UPDATE illegal_warehouses set owner = "" WHERE warehouse = @livretID', {['@livretID'] = storageZone},	function ()	end)
end)

RegisterServerEvent('esx_illegalWarehouses:rent')
AddEventHandler('esx_illegalWarehouses:rent', function(storageZone, gangname)
	if gangname == 'mafia' then gangname = 'Mafia' end
	if gangname == 'vagos' then gangname = 'Vagos' end
	if gangname == 'ballas' then gangname = 'Ballas' end
	if gangname == 'families' then gangname = 'Families' end
	if gangname == 'biker' then gangname = 'Biker' end
	MySQL.Async.execute('UPDATE illegal_warehouses set owner = @gangname WHERE warehouse = @ID', {['@ID'] = storageZone, ['@gangname'] = gangname},	function ()	end)
end)

ESX.RegisterServerCallback('esx_illegalWarehouses:GetWareHouseStatus', function(source, cb, storageName)
	if storageName == "Storage1" then
		cb(Storage1stat)
	elseif storageName == "Storage2" then
		cb(Storage2stat)
	elseif storageName == "Storage3" then
		cb(Storage3stat)
	elseif storageName == "Storage4" then
		cb(Storage4stat)
	elseif storageName == "Storage5" then
		cb(Storage5stat)
	elseif storageName == "Storage6" then
		cb(Storage6stat)
	end
end)

RegisterServerEvent('esx_illegalWarehouses:UpdateWarehouseStatus')
AddEventHandler('esx_illegalWarehouses:UpdateWarehouseStatus', function(storageZone)
	if storageZone == "Storage1" then
		Storage1stat = not Storage1stat
	elseif storageZone == "Storage2" then
		Storage2stat = not Storage2stat
	elseif storageZone == "Storage3" then
		Storage3stat = not Storage3stat
	elseif storageZone == "Storage4" then
		Storage4stat = not Storage4stat
	elseif storageZone == "Storage5" then
		Storage5stat = not Storage5stat
	elseif storageZone == "Storage6" then
		Storage6stat = not Storage6stat
	end
end)

RegisterServerEvent('esx_illegalWarehouses:AlertPlayersPoliceBreakIn')
AddEventHandler('esx_illegalWarehouses:AlertPlayersPoliceBreakIn', function()
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'LSPD', '~b~Alerte LSPD', 'Le LSPD est en train de forcer un entrepôt!', 'CHAR_PLANESITE', 0)
	end
end)
