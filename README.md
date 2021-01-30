# esx_illegalWarehouses

ESX Illegal Warehouses

[REQUIREMENTS]


* es_extended
  * es_extended v1 : https://github.com/esx-framework/es_extended/tree/v1-final
  * es_extended v2 : https://github.com/esx-framework/es_extended

[INSTALLATION]

1) CD in your resources/[folderWhereYouWantTheScriptToBe]
2) Clone the repository
```
git clone https://github.com/BenoursonJ/esx_illegalWarehouses esx_illegalWarehouses
```
3) * Warehouses and Inventories : Import illegalWarehouses_en.sql or illegalWarehouses_fr.sql according to your language in your database

4) Add into a menu where you want to access the management panel from (example used is Mafia Job, full menu example at the end of this file):
```
exports["esx_illegalWarehouses"]:OpenWarehousesMenu()
```

5) Add this in your server.cfg :

```
ensure esx_illegalWarehouses
```


[MENU EXAMPLE]
```
function OpenCloakroomMenu()
  local elements = {
    {label = _U('citizen_wear'), value = 'citizen_wear'},
    {label = "Gestion Entrepôts", value = 'mafia_storagemanage'},
  }
  ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'cloakroom',
      {
        title    = _U('cloakroom'),
        align    = 'top-left',
        elements = elements,
        },
        function(data, menu)
      menu.close()
      if data.current.value == 'mafia_storagemanage' and ((PlayerData.job ~= nil and PlayerData.job.name == 'mafia' and PlayerData.job.grade_name == 'boss') or (PlayerData.job2 ~= nil and PlayerData.job2.name == 'mafia' and PlayerData.job2.grade_name == 'boss')) then
        exports["esx_illegalWarehouses"]:OpenWarehousesMenu()
      else
        TriggerEvent('esx:showNotification', "Vous devez être Parrain pour ouvrir ce menu")
      end

      if data.current.value == 'citizen_wear' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
          local model = nil
          if skin.sex == 0 then
            model = GetHashKey("mp_m_freemode_01")
          else
            model = GetHashKey("mp_f_freemode_01")
          end
          RequestModel(model)
          while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(1)
          end
          SetPlayerModel(PlayerId(), model)
          SetModelAsNoLongerNeeded(model)
          TriggerEvent('skinchanger:loadSkin', skin)
          TriggerEvent('esx:restoreLoadout')
        end)
      end
   CurrentAction     = 'menu_cloakroom'
      CurrentActionMsg  = _U('open_cloackroom')
      CurrentActionData = {}
    end,
    function(data, menu)
      menu.close()
      CurrentAction     = 'menu_cloakroom'
      CurrentActionMsg  = _U('open_cloackroom')
      CurrentActionData = {}
    end)
end
```
