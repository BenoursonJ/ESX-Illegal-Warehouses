-----------------------------------------
-- 
d by Benourson#9496
-----------------------------------------


local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job

end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job)
  PlayerData.job2 = job
end)


AddEventHandler('esx_illegalWarehouses:hasEnteredMarker', function(zone)
	for k,v in pairs(Config.Zones) do
		if zone == k and PlayerData.job ~= nil then
			CurrentAction     = 'open_storage'
			CurrentActionMsg  = _U('open_container')
			CurrentActionData = {zone = zone}
		end
	end
end)

AddEventHandler('esx_illegalWarehouses:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)


-- Display markers
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Zones) do
			if PlayerData ~= nil  then
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)
-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		local wait = 1200
		if PlayerData ~= nil  then
			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil
			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					wait = 0
					isInMarker  = true
					currentZone = k
				end
			end
			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_illegalWarehouses:hasEnteredMarker', currentZone)
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_illegalWarehouses:hasExitedMarker', LastZone)
			end
		end
		Citizen.Wait(wait)
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 300 then
				if CurrentAction == 'open_storage' then
					ESX.TriggerServerCallback('esx_illegalWarehouses:getStorageOwner', function(storageOwner)
						if (PlayerData.job ~= nil and PlayerData.job.name == storageOwner) or (PlayerData.job2 ~= nil and PlayerData.job2.name == storageOwner) then
							OpenStorageMenu(CurrentActionData.zone)
						elseif PlayerData.job.name == Config.Policejob and PlayerData.job2.name ~= storageOwner then
							PoliceOpenWarehouse(CurrentActionData.zone)
						else
							ESX.ShowNotification(_U('unauthorized_container_access'))
						end 
					end, CurrentActionData.zone)
				end
				CurrentAction = nil
				GUI.Time      = GetGameTimer()
			end
		end
	end
end)

--FUNCTIONS

function OpenStorageMenu(storageZone)
	local elements = {
		{label = _U('deposit_stock'), value = 'put_stock'},
		{label = _U('take_stock'), value = 'get_stock'},
		{label = _U('deposit_weapon'), value = 'put_weapon'},
		{label = _U('take_weapon'), value = 'get_weapon'}
	}
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'storage_menu',
		{
			title    = _U('storage_menu_title'),
			align    = 'top-left',
			elements = elements
		},
		function(data, menu)
			if data.current.value == 'put_stock' then
				OpenPutStocksMenu(storageZone)
			end
			if data.current.value == 'get_stock' then
				OpenGetStocksMenu(storageZone)
			end
			if data.current.value == 'put_weapon' then
				OpenPutWeaponMenu(storageZone)
			end
			if data.current.value == 'get_weapon' then
				OpenGetWeaponMenu(storageZone)
			end
		end,
		function(data, menu)
			menu.close()
			CurrentAction     = 'storage_menu'
			CurrentActionMsg  = _U('open_container')
			CurrentActionData = {}
		end)
end

function OpenPutStocksMenu(storageZone)
	local storeZone = storageZone
	ESX.TriggerServerCallback('esx_illegalWarehouses:getPlayerInventory', function(inventory)
		local elements = {}
		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]
			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name, storagename = storeZone, count = item.count})
			end
		end
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{
				title    = _U('inventory'),
				elements = elements
			},
			function(data, menu)
				local itemName = data.current.value
				local storage = data.current.storagename
				local itemcount = data.current.count
				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)
						local count = tonumber(data2.value)
						if count == nil or count <= 0 or count > itemcount then
							ESX.ShowNotification(_U('quantity_invalid'))
						else
							menu2.close()
							menu.close()
							OpenPutStocksMenu()
							TriggerServerEvent('esx_illegalWarehouses:putStockItems', itemName, count, storage)
						end
					end,
					function(data2, menu2)
						menu2.close()
					end)
			end,
			function(data, menu)
				menu.close()
			end)
	end)
end



function OpenGetStocksMenu(storageZone)
	ESX.TriggerServerCallback('esx_illegalWarehouses:getStockItems', function(items)
		local elements = {}
		for i=1, #items, 1 do
			if (items[i].count ~= 0) then
				table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name, storagename = storageZone, itemcount = items[i].count})
			end
		end
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{
				title    = _U('inventory'),
				align    = 'top-left',
				elements = elements
			},
			function(data, menu)
				local itemName = data.current.value
				local storage = data.current.storagename
				local localitemcount = data.current.itemcount
				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)
						local count = tonumber(data2.value)
						if count == nil or count <= 0 or count > localitemcount then
							ESX.ShowNotification(_U('quantity_invalid'))
						else
							menu2.close()
							menu.close()
							OpenGetStocksMenu(storage)
							TriggerServerEvent('esx_illegalWarehouses:getStockItem', itemName, count, storage)
						end
					end,
					function(data2, menu2)
						menu2.close()
					end)
		end,
		function(data, menu)
			menu.close()
		end)
	end, storageZone)
end


function OpenGetWeaponMenu(storageZone)
	ESX.TriggerServerCallback('esx_illegalWarehouses:getWeapons', function(weapons)
		local elements = {}
		for i=1, #weapons, 1 do
			if weapons[i].count > 0 then
				table.insert(elements, {
					label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name),
					value = weapons[i].name,
					storagename = storageZone
				})
			end
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_get_weapon', {
			title    = _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()
			ESX.TriggerServerCallback('esx_illegalWarehouses:removeWeapon', function()
				OpenGetWeaponMenu(data.current.storagename)
			end, data.current.value, data.current.storagename)
		end, function(data, menu)
			menu.close()
		end)
	end, storageZone)
end

function OpenPutWeaponMenu(storageZone)
	local elements   = {}
	local playerPed  = PlayerPedId()
	local weaponList = ESX.GetWeaponList()
	for i=1, #weaponList, 1 do
		local weaponHash = GetHashKey(weaponList[i].name)
		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			table.insert(elements, {
				label = weaponList[i].label,
				value = weaponList[i].name,
				storagename = storageZone
			})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_put_weapon', {
		title    = _U('deposit_weapon'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		menu.close()
		ESX.TriggerServerCallback('esx_illegalWarehouses:addWeapon', function()
			OpenPutWeaponMenu(data.current.storagename)
		end, data.current.value, true, data.current.storagename)
	end, function(data, menu)
		menu.close()
	end)
end

exports("OpenWarehousesMenu", function()
	ESX.TriggerServerCallback('esx_illegalWarehouses:getWarehouses', function(customers)
		local elements = {
			head = { _U('warehouse'), _U('warehouse_id'), _U('gang_id'), _U('actions')},
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].label,
					customers[i].warehouse,
					customers[i].owner,
					'{{' .. _U('rent') .. '|rent}} {{' .. _U('lease') .. '|revoke}}'
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			if data.value == 'revoke' then
				menu.close()
				TriggerServerEvent('esx_illegalWarehouses:revoke', data.data.warehouse)
				ESX.ShowNotification(data.data.label .. _U('successfully_revoked'))
				Citizen.Wait(100)
				exports["esx_illegalWarehouses"]:OpenWarehousesMenu()
			end
			if data.value == 'rent' then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing',
					{
						title = _U('gang_name_title')
					},
					function(data2, menu2)
						local gangname = string.lower(data2.value)
						if gangname == nil then
							ESX.ShowNotification(_U('please_enter_gangname'))
						elseif not has_value(Config.Gangs, gangname) then
							ESX.ShowNotification(_U('please_enter_valid_gangname'))
						else
							menu2.close()
							TriggerServerEvent('esx_illegalWarehouses:rent', data.data.warehouse, gangname)
							ESX.ShowNotification(data.data.label .. _U('successfully_rented'))
							Citizen.Wait(100)
							exports["esx_illegalWarehouses"]:OpenWarehousesMenu()
						end
					end,
					function(data2, menu2)
					menu2.close()
					end)
				end
		end, 
		function(data, menu)
			menu.close()
		end)
	end)
end)

function PoliceOpenWarehouse(zone)
	local bool = false
	ESX.TriggerServerCallback('esx_illegalWarehouses:getPlayerInventory', function(inventory)
		for i=1, #inventory.items, 1 do
			if inventory.items[i].count > 0 and inventory.items[i].name == "lockpick" then
				bool = true
			end
		end
		if bool then
			ESX.TriggerServerCallback('esx_illegalWarehouses:GetWareHouseStatus', function(status)
				if status then
					OpenStorageMenu(zone)
				else
					TriggerServerEvent('esx_illegalWarehouses:AlertPlayersPoliceBreakIn')
					TriggerServerEvent('esx_illegalWarehouses:RemoveInventoryItem', "lockpick")
					ESX.ShowNotification(_U('police_open_container_notify'))
					Citizen.Wait(5000)
					cond = math.random(0, 100)
					if cond >= Config.PoliceCond then
						ESX.ShowNotification(_U('police_opened_container'))
						TriggerServerEvent('esx_illegalWarehouses:UpdateWarehouseStatus', zone)
						OpenStorageMenu(zone)
					else
						ESX.ShowNotification(_U('police_open_container_fail'))
					end
				end
			end, zone)
		else
			ESX.ShowNotification(_U('no_lockpick'))
		end
	end)
end

function has_value (tab, val)
	for k, v in pairs(tab) do
		if k == val then
			return true
		end
	end
	return false
end
