# esx_illegalWarehouses

Illegal warehouses that can be rented to gangs, illegal organizations or even certain jobs and that can be lockpicked by police forces as long as they have lockpicks.


# [FEATURES]


* **Warehouses management** from any menu via an export
  * **View the current state of the warehouses** : Warehouse Name | Jobname rented to | Gang Name rented to
  * **Rent** a warehouse
  * **Reset** the warehouse ownership
* **Private warehouses**: each warehouse can only be opened by the gang/org/job it has been rented to
* **LSPD OPEN UP !!** : each warehouse can be raided by the LSPD as long as they have lockpicks. When raiding a warehouse, a notification will be sent alerting every player of the raid but you will have to guess which warehouse is being raided !
* **Easily add or remove warehouses** : Just add or remove the Warehouses from Config.lua, add or remove the needed info in the database and you are done !
* **Easily add or remove gangs, orgs, jobs** : Just add or remove the jobs in Config.lua

# [REQUIREMENTS]


* es_extended
  * es_extended v1 : https://github.com/esx-framework/es_extended/tree/v1-final
  * es_extended v2 : https://github.com/esx-framework/es_extended
* async          : https://github.com/esx-framework/async
* mysql-async    : https://github.com/brouznouf/fivem-mysql-async

# [INSTALLATION]

1) CD in your resources/[folderWhereYouWantTheScriptToBe]
2) Clone the repository
``` git
git clone https://github.com/BenoursonJ/esx_illegalWarehouses esx_illegalWarehouses
```
3) * Warehouses and Inventories : Import illegalWarehouses_en.sql or illegalWarehouses_fr.sql according to your language in your database

4) Add into a menu where you want to access the management panel from (example used is Mafia Job, full menu example at the end of this file):
``` lua
exports["esx_illegalWarehouses"]:OpenWarehousesMenu()
```

5) Add this in your server.cfg :

``` lua
ensure esx_illegalWarehouses
```

# [CONFIG.LUA EXPLAINED]
* **Config.DrawDistance** | Maximum distance from which the markers can be seen
* **Config.Locale** | Text language (currently supported: fr and en)
* **Config.PoliceCond** | Percentage of failure (default: 75%)
* **Config.Policejob**	| Name of the job that is able to lockpick warehouses

* **Config.Zones** | Array listing the warehouses, structure is as follow :
  * **StorageName** (ex: Storage1) | Marker name, must be the same than as defined in the DB
    * **Position** | Marker position
    * **Marker Size** | Marker size
    * **Marker Color** | Marker colour
    * **Display Name** | Marker Display Name
    * **Type** | Marker Type (0 = hidden | 1 = displayed)

* **Config.Gangs** | List of gangs, organizations or jobs that can use the illegal warehouses system
  * **Gangname (ex: ballas)** | Gang name, must be the same as the one used to set a job (ex: /setjob 1 ballas 3)
    * **Name** | Display named that is used when a warehouse is rented. When opening the warehouses menu, you will see this variable and not the gangname


# [MENU EXAMPLE]
``` lua
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
