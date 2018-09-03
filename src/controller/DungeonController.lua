--[[

]]
local DungeonController = qy.class("DungeonController", qy.tank.controller.BaseController)

function DungeonController:ctor(delegate)
    DungeonController.super.ctor(self)

    self.viewStack = qy.tank.widget.ViewStack.new()
    self.viewStack:addTo(self)

    self:init()
end



function DungeonController:init()
	local explore     = qy.DungeonModel:getExploreData()
	local currPosData = qy.DungeonModel:getCurrentPosData()

	self:addCacheResource()

	qy.DungeonModel:updateStatus("wait")

	if qy.BattleBodyModel:judgementGameLose() == "lose" then
		qy.DungeonUtil.asynExecute(function()
			qy.tank.service.DungeonService:closure({["formation"] = qy.BattleBodyModel:getServiceUseHeroData()})
	    end, 0.01)

	elseif currPosData["checkpoint_type"] == "boss_room" then
	    qy.DungeonModel:updateStatus("battle")
	    local view = require("view.dungeon.DungeonBasicView").new(self)
	    self.viewStack:push(view)
	    -- qy.DungeonModel:loadTile()
	    qy.DungeonModel:loadTileRandom()

	    qy.DungeonUtil.asynExecute(function()
		    qy.tank.service.DungeonService:bossBattle(function(data)
		    	qy.DungeonUtil.asynExecute(function()
		    		explore = qy.DungeonModel:getExploreData()
			    	qy.DungeonModel:battleByEnemyId(explore["is_battle"], data["drop_award"])

			    	if self.bossBattleEndListener then
		        		qy.Event.remove(self.bossBattleEndListener)
		        		self.bossBattleEndListener = nil
			    	end
			    	self.bossBattleEndListener = qy.Event.add(qy.Event.BATTLE_END, function(event)
			    		--给2秒时间让玩家看到东西进包里
		        		qy.Event.remove(self.bossBattleEndListener)
			    		qy.DungeonUtil.asynExecute(function() 
			    			
                    		qy.tank.service.DungeonService:closure({["formation"] = qy.BattleBodyModel:getServiceUseHeroData()})
			    		end, 2)
				    end)
		        end, 1)
		    end)
        end, 0.01)

	elseif explore["is_battle"] ~= 0 then
	    qy.DungeonModel:updateStatus("battle")
	    local view = require("view.dungeon.DungeonBasicView").new(self)
	    self.viewStack:push(view)
	    qy.DungeonModel:loadTileRandom()

	    qy.DungeonUtil.asynExecute(function()
	    	qy.DungeonModel:battleByEnemyId(explore["is_battle"], qy.DungeonModel.drop_award)

	    	if self.battleEndListener then
        		qy.Event.remove(self.battleEndListener)
        		self.battleEndListener = nil
	    	end
	    	self.battleEndListener = qy.Event.add(qy.Event.BATTLE_END, function(event)    
		        qy.Event.remove(self.battleEndListener)
		        if currPosData["checkpoint_type"] == "select_event" then
			        qy.tank.service.DungeonService:selectBattleEnd(
			            {["native"] = explore["pos"], ["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}, 
			            function(data)		         
				            if qy.BattleBodyModel:judgementGameLose() == "lose" then
		        				-- qy.DungeonModel:updateStatus("wait")
		                        qy.tank.service.DungeonService:closure({["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}) 
		                    else
		                    	--留2秒时间显示经验与升级
			    				qy.DungeonUtil.asynExecute(function() 
									self:openMapDialog()
				    				qy.DungeonUtil.asynExecute(function() 
			        					qy.DungeonModel:updateStatus("wait")
		        					end)
								end, 2)
		                    end                        	      
			        end)
			    else
			    	qy.tank.service.DungeonService:encampBattleEnd(
			            {["native"] = explore["pos"], ["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}, 
			            function(data)
							if qy.BattleBodyModel:judgementGameLose() == "lose" then
		       					-- qy.DungeonModel:updateStatus("wait")
		                        qy.tank.service.DungeonService:closure({["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}) 
		                    else
		                    	--留2秒时间显示经验与升级
			    				qy.DungeonUtil.asynExecute(function() 
									self:openMapDialog()
				    				qy.DungeonUtil.asynExecute(function() 
			        					qy.DungeonModel:updateStatus("wait")
		        					end)
								end, 2)
		                    end
			        end)
			    end
		    end)
        end, 1)

	elseif currPosData["finish"] == 1 then
		--选地图
	    -- qy.DungeonUtil.asynExecute(function()
			self:openMapDialog()
        -- end, 0.01)
	elseif currPosData["checkpoint_type"] == "select_event" then
	    -- qy.DungeonUtil.asynExecute(function()
			local cartoonEventDialog = require("view.dungeon.cartoon_event.CartoonEventDialog").new()
			cartoonEventDialog:render(currPosData["select_config_id"], explore["pos"])
			cartoonEventDialog:show()
	elseif currPosData["checkpoint_type"] == "bonfire_event" then
	    qy.DungeonModel:updateStatus("bonfire")
    	local view = require("view.dungeon.DungeonBasicView").new(self)
	    self.viewStack:push(view)
	    qy.DungeonModel:loadTileRandom(false, false)

	    qy.DungeonUtil.asynExecute(function()
			local encampDialog = require("view.dungeon.encamp.DungeonEncampDialog").new()
			encampDialog:show()
        end, 0.01)
	elseif currPosData["checkpoint_type"] == "shop_event" then
	    -- qy.DungeonUtil.asynExecute(function()
			local shopEventDialog = require("view.dungeon.blackmarket.BlackMarketDialog").new()
			shopEventDialog:show()
	else
	    local view = require("view.dungeon.DungeonBasicView").new(self)
	    self.viewStack:push(view)
	    qy.DungeonModel:loadTile()
	end


	qy.DungeonUtil.asynExecute(function()
		if currPosData["checkpoint_type"] == "ordinary_room" or 
			currPosData["checkpoint_type"] == "monster_room" or 
			currPosData["checkpoint_type"] == "battle_room" or 
			currPosData["checkpoint_type"] == "box_room" then

			--初次进入
			if explore["pos"] == "default" then
	        	qy.DungeonModel:triggerTalk(qy.BattleBodyModel:getRandomAliveBodyId(), 5)
			else
	        	qy.DungeonModel:judgementHeroStatusTalk()
			end
		end
    end, 0.1)
end



function DungeonController:openMapDialog()	
	local mapDialog = require("view.dungeon.map.DungeonMapDialog").new("select")
	mapDialog:show()
	mapDialog:addControlNode()
	mapDialog:hideCloseBtn()
end


function DungeonController:addCacheResource()
	local ids = {}
	local currentPosData = qy.DungeonModel:getCurrentPosData()
	if currentPosData["room"] then
		for i = 1, 4 do
			local id 
			if currentPosData["room"][i] and currentPosData["room"][i]["type"] == "room_battle" then
				id = currentPosData["room"][i]["config_id"]

			elseif currentPosData["room"][i] 
				and currentPosData["room"][i]["type"] == "room_event" 
				and currentPosData["room"][i]["scene_object"] 
				and currentPosData["room"][i]["scene_object"]["sub_type"] == "scene_battle" then

				id = currentPosData["room"][i]["scene_object"]["sub_config_id"]
			end

			if id then
				table.insert(ids, id)
			end
		end
	end

	local result = {}
	for i = 1, #table do
		local config = qy.Config.enemy[tostring(id)]
		for j = 1, 4 do
			if config["monster"..j] and config["monster"..j] ~= "" then
				local monsterData = qy.Config.monster[config["monster"..j].."01"]
				if monsterData then
					result[tostring(monsterData["cartoon"])] = 1
				end
			end
		end
	end

	for k, v in pairs(result) do
    	qy.tank.utils.cache.CachePoolUtil.addArmatureFileAsync("dragonBone/monster/monster"..k, nil)
	end
end




return DungeonController
