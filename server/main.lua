ESX = nil
StorageStat = {}

for k,v in pairs(Config.Zones) do
	table.insert(StorageStat, {k, false})
end

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('esx_illegalWarehouses:getStorageOwner', function(source, cb, storageName)
	MySQL.Async.fetchAll('SELECT owner FROM illegal_warehouses WHERE warehouse = @id', { ['@id'] = storageName }, function(result)
		cb(result[1].owner)
	  end)
end)

RegisterServerEvent('esx_illegalWarehouses:getStockItem')
AddEventHandler('esx_illegalWarehouses:getStockItem', function(itemName, count, storageZone)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('esx_addoninventory:getSharedInventory', string.lower(storageZone), function(inventory)
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
	TriggerEvent('esx_addoninventory:getSharedInventory', string.lower(storageZone), function(inventory)
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
	TriggerEvent('esx_datastore:getSharedDataStore', string.lower(storageZone), function(store)
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
	TriggerEvent('esx_datastore:getSharedDataStore', string.lower(storageZone), function(store)
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
	TriggerEvent('esx_datastore:getSharedDataStore', string.lower(storageZone), function(store)
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
				owner = result[i].ownerDisplayName
			})
		end
		cb(customers)
	end)
end)

RegisterServerEvent('esx_illegalWarehouses:revoke')
AddEventHandler('esx_illegalWarehouses:revoke', function(storageZone)
	MySQL.Async.execute('UPDATE illegal_warehouses set owner = "", ownerDisplayName = "" WHERE warehouse = @livretID', {['@livretID'] = storageZone},	function ()	end)
end)

RegisterServerEvent('esx_illegalWarehouses:rent')
AddEventHandler('esx_illegalWarehouses:rent', function(storageZone, gangname)
	local gangDisplayName
	for k, v in pairs(Config.Gangs) do
		if k == gangname then
			gangDisplayName = v.Name
		end
	end
	MySQL.Async.execute('UPDATE illegal_warehouses set owner = @gangname, ownerDisplayName = @Disp WHERE warehouse = @ID', {['@ID'] = storageZone, ['@gangname'] = gangname, ['@Disp'] = gangDisplayName},	function ()	end)
end)

ESX.RegisterServerCallback('esx_illegalWarehouses:GetWareHouseStatus', function(source, cb, storageName)
	for k,v in pairs(StorageStat) do
	   if v[1] == storageName then
		cb(v[2])
	   end
	end
end)

RegisterServerEvent('esx_illegalWarehouses:UpdateWarehouseStatus')
AddEventHandler('esx_illegalWarehouses:UpdateWarehouseStatus', function(storageZone)
	for k,v in pairs(StorageStat) do
		if v[1] == storageZone then
			StorageStat[k][2] = not v[2]
		end
	 end
end)

RegisterServerEvent('esx_illegalWarehouses:AlertPlayersPoliceBreakIn')
AddEventHandler('esx_illegalWarehouses:AlertPlayersPoliceBreakIn', function()
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'LSPD', '~b~Alerte LSPD', _U('lspd_enforcing'), 'CHAR_PLANESITE', 0)
	end
end)


RegisterServerEvent('esx_illegalWarehouses:RemoveInventoryItem')
AddEventHandler('esx_illegalWarehouses:RemoveInventoryItem', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, 1)
end)

