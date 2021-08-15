local isModelLoaded = false

local skin_name = {
		"model_goku" ,  --1
		"s_m_y_hulk_01" , --2
		"spiderman_advanced_suit_ps4",  --3
		"model_cap",  --4
		"model_thanos_1", --5
		-- "model_thanos_2" , --6
		"model_superman" , --7
		-- "model_batman" , 
		"model_gohan",
		"model_itachi",
		"model_luffy",
		"model_piccolo",
		"model_vegeta",
	}

RegisterCommand("changeskin", function(source, args)
	local id = tonumber(args[1])
	local maxId = #skin_name
	if ( id == 0 ) or ( id > maxId ) then 
		id  = 1;
	end
	local skin = skin_name[id] -- "model_gokuen";
	local model = GetHashKey(skin)
	RequestModel(model)
	msg("Loading request model...")
	while not HasModelLoaded(model) do
		notify("~p~Still loading mode : ~h~~g~" .. id)
		RequestModel(model)
		Citizen.Wait(0)
	end
	msg("Finish loading...")
	SetPlayerModel(PlayerId(), model)
	SetPedComponentVariation(GetPlayerPed(-1), 0, 0, 0, 2)
	msg("CHANGED SKIN TO "..id)
end)

RegisterCommand("addnpc", function(source, args)
	local id = tonumber(args[1])
	doAddNPC(id)
end)

RegisterCommand("addallnpc", function(source, args)
	for i=1,#skin_name do
		doAddNPC(i)
	end
end)


RegisterCommand("nowanted", function(source, args)
	local currentPlayer = PlayerId();
	SetPlayerWantedLevel(currentPlayer, 0, false)
	msg("NO WANTED ANY MORE.");
end)

RegisterCommand("wanted", function(source, args)
	local currentPlayer = PlayerId();
	local level = tonumber(args[1])
	SetPlayerWantedLevel(currentPlayer, level, false)
	notify("SET WANTED LEVEL TO "..level);
end)

RegisterCommand("hoisinh", function(source, args)
	local id = GetPlayerPed(-1)
	revivePed(id);
	notify("REVIVED");
end)

function doAddNPC(id) 
	local totalPeople = 5
	local maxId = #skin_name
	if ( id == 0 ) or ( id > maxId ) then 
		id  = 1;
	end
	local skin = skin_name[id] -- "model_gokuen";
	local ped = GetHashKey(skin)
	-- msg("Loading request model...")
	RequestModel(model)
	-- while not HasModelLoaded(model) do
		-- notify("~p~Still loading mode : ~h~~g~" .. id)
		-- Citizen.Wait(0)
	-- end
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	local newPed = CreatePed(4 --[[refer above (4 only works for male peds and 5 is for female peds)]], ped, x+math.random(-totalPeople,totalPeople),y+math.random(-totalPeople,totalPeople) --[[ This random number will space them out more ]],z , 0.0 --[[float (int) Heading]], true, true)
	SetPedCombatAttributes(newPed, 0, true) --[[ BF_CanUseCover ]]
    SetPedCombatAttributes(newPed, 5, true) --[[ BF_CanFightArmedPedsWhenNotArmed ]]
    SetPedCombatAttributes(newPed, 46, true) --[[ BF_AlwaysFight ]]
    SetPedFleeAttributes(newPed, 0, true) --[[ allows/disallows the ped to flee from a threat i think]]
	SetPedRelationshipGroupHash(newPed, GetHashKey("allies"))
	SetRelationshipBetweenGroups(0, GetHashKey("allies"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey("allies"))
	SetRelationshipBetweenGroups(5, GetHashKey("allies"), GetHashKey("COP"))
	SetRelationshipBetweenGroups(5, GetHashKey("allies"), GetHashKey("ARMY"))
    SetPedAccuracy(newPed, 100) --[[ Allies will have 100 percent accuracy ]]
	--TaskStartScenarioInPlace(newPed, "WORLD_HUMAN_SMOKING", 0, true)
	GiveWeaponToPed(newPed, GetHashKey("WEAPON_ASSAULTRIFLE"), 2000, true--[[ weapon is hidden or not (bool)]], true) --[[ https://runtime.fivem.net/doc/natives/#_0xBF0FD6E56C964FCB]]
	SetPedArmour(newPed, 100)
	SetPedMaxHealth(newPed, 100)
	for k=0,11 do
		local z = GetNumberOfPedDrawableVariations(newPed,k)
		if (z>0) then
			local z1 = GetNumberOfPedTextureVariations(newPed,k,z)
			SetPedComponentVariation(newPed, k, z, z1, 2)
		end
	end
    SetPedComponentVariation(newPed, 0, 0, 0, 2)
	msg("Added "..skin)
	Citizen.CreateThread(function()
		while (1==1) do
			local npc_name = skin
			if ( IsPedDeadOrDying (newPed, true) ) then
					notify("NPC " .. npc_name .. " is dead...")
					break
			end
			Citizen.Wait( math.random (1000,5000) ) -- do not let ped come same time
			local x1, y1, z1 = table.unpack(GetEntityCoords(newPed, true))
			TaskGoToEntity(newPed, GetPlayerPed(-1), -1, 3.0, 10.0, 1073741824.0, 0)
			Citizen.Wait( math.random (1000,15000) ) -- do not let ped come same time
			--SetPedKeepTask(newPed, true)
			--Citizen.Wait(math.random(3000, 8000))
		end
	end)
end




function msg(text)
    -- TriggerEvent will send a chat message to the client in the prefix as red
    TriggerEvent("chatMessage",  "[Server]", {255,0,0}, text)
end

RegisterCommand("listnpc", function(source, args)
	for i=1,#skin_name do
		msg(i.." : "..skin_name[i])	
	end
end)


Citizen.CreateThread(function()
  while true do
		Citizen.Wait(0)
			if not isModelLoaded then
			for i, name in ipairs(skin_name) do
				targetSkin = name
				if not IsModelAPed(targetSkin) then
					notify(targetSkin .. " could not be found as a skin.")
					goto continue
				end
				RequestModel(targetSkin)
				while not HasModelLoaded(targetSkin) do
                    notify("[SkinLoader] Loading skin " ..targetSkin)
					Citizen.Wait(1000) 
				end
                if HasModelLoaded(targetSkin) then
					notify("Loaded skin " ..targetSkin)
                end
				-- SetModelAsNoLongerNeeded(targetSkin)
				::continue::
			end
			isModelLoaded = true
		end
  end
  msg("All skin is loaded")
  
end)

function notify(string)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(string)
    DrawNotification(true, false)
end

function alert(msg) 
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function revivePed(ped)
	local playerPos = GetEntityCoords(ped, true)
	NetworkResurrectLocalPlayer(playerPos, true, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
	DoScreenFadeIn(800)
end