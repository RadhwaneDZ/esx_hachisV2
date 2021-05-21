ESX 						   = nil
local CopsConnected       	   = 0
local PlayersHarvestingHachis     = {}
local PlayersTransformingHachis   = {}
local PlayersSellingHachis     = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()

	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(5000, CountCops)

end

CountCops()

--lsd
local function HarvestHachis(source)

	if CopsConnected < Config.RequiredCopsHachis then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsHachis)
		return
	end

	SetTimeout(5000, function()

		if PlayersHarvestingHachis[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local lsd = xPlayer.getInventoryItem('hachis')

			if lsd.limit ~= -1 and lsd.count >= lsd.limit then
				TriggerClientEvent('esx:showNotification', source, _U('inv_full_hachis'))
			else
				xPlayer.addInventoryItem('hachis', 1)
				HarvestHachis(source)
			end

		end
	end)
end

RegisterServerEvent('esx_hachis:startHarvestHachis')
AddEventHandler('esx_hachis:startHarvestHachis', function()

	local _source = source

	PlayersHarvestingHachis[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('pickup_in_prog'))

	HarvestHachis(_source)

end)

RegisterServerEvent('esx_hachis:stopHarvestHachis')
AddEventHandler('esx_hachis:stopHarvestHachis', function()

	local _source = source

	PlayersHarvestingHachis[_source] = false

end)

local function TransformHachis(source)

	if CopsConnected < Config.RequiredCopsHachis then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsHachis)
		return
	end

	SetTimeout(10000, function()

		if PlayersTransformingHachis[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local lsdQuantity = xPlayer.getInventoryItem('hachis').count
			local poochQuantity = xPlayer.getInventoryItem('hachis_pooch').count

			if poochQuantity > 35 then
				TriggerClientEvent('esx:showNotification', source, _U('too_many_pouches'))
			elseif lsdQuantity < 10 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_hachis'))
			else
				xPlayer.removeInventoryItem('hachis', 10)
				xPlayer.addInventoryItem('hachis_pooch', 1)
			
				TransformHachis(source)
			end

		end
	end)
end

RegisterServerEvent('esx_hachis:startTransformHachis')
AddEventHandler('esx_hachis:startTransformHachis', function()

	local _source = source

	PlayersTransformingHachis[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('packing_in_prog'))

	TransformHachis(_source)

end)

RegisterServerEvent('esx_hachis:stopTransformHachis')
AddEventHandler('esx_hachis:stopTransformHachis', function()

	local _source = source

	PlayersTransformingHachis[_source] = false

end)

local function SellHachis(source)

	if CopsConnected < Config.RequiredCopsHachis then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsHachis)
		return
	end

	SetTimeout(7500, function()

		if PlayersSellingHachis[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local poochQuantity = xPlayer.getInventoryItem('hachis_pooch').count

			if poochQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_pouches_sale'))
			else
				xPlayer.removeInventoryItem('hachis_pooch', 1)
				if CopsConnected == 0 then
                    xPlayer.addAccountMoney('black_money', 680)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_hachis'))
                elseif CopsConnected == 1 then
                    xPlayer.addAccountMoney('black_money', 695)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_hachis'))
                elseif CopsConnected == 2 then
                    xPlayer.addAccountMoney('black_money', 705)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_hachis'))
                elseif CopsConnected == 3 then
                    xPlayer.addAccountMoney('black_money', 715)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_hachis'))
                elseif CopsConnected == 4 then
                    xPlayer.addAccountMoney('black_money', 725)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_hachis'))
                elseif CopsConnected >= 5 then
                    xPlayer.addAccountMoney('black_money', 735)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_hachis'))
                end
				
				SellHachis(source)
			end

		end
	end)
end

RegisterServerEvent('esx_hachis:startSellHachis')
AddEventHandler('esx_hachis:startSellHachis', function()

	local _source = source

	PlayersSellingHachis[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))

	SellHachis(_source)

end)

RegisterServerEvent('esx_hachis:stopSellHachis')
AddEventHandler('esx_hachis:stopSellHachis', function()

	local _source = source

	PlayersSellingHachis[_source] = false

end)


-- RETURN INVENTORY TO CLIENT
RegisterServerEvent('esx_hachis:GetUserInventory')
AddEventHandler('esx_hachis:GetUserInventory', function(currentZone)
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('esx_hachis:ReturnInventory', 
    	_source,
		xPlayer.getInventoryItem('hachis').count, 
		xPlayer.getInventoryItem('hachis_pooch').count,
		xPlayer.job.name, 
		currentZone
    )
end)
