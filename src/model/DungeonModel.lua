local DungeonModel = qy.class("DungeonModel", qy.tank.model.BaseModel)



------------------------------------------------------------------地图数据相关 start
function DungeonModel:init(data)

    -- qy.BattleBodyModel:setHeroData("s")
    -- qy.BattleBodyModel:setBattleMonsterData("s")

    self.explore = data.explore
    self.mapData = {}
end


function DungeonModel:setData(data)
    self:updateExploreData(data.explore)
    self:updateMapData(data.map)
    self.drop_award = data.drop_award or {}
end


function DungeonModel:loadTile(bodyLayer, ornamentLayer)
    if self:getCurrentPosData()["checkpoint_type"] ~= "select_event" then
        qy.DungeonUtil.asynExecute(function()
            local data = self:getCurrentPosData()
            local csbName = qy.Config.room[tostring(data["room_config_id"])]["scenes"]
            if string.find(csbName, "|") then
                csbName = qy.tank.utils.String.split(csbName, "|")
                csbName = csbName[qy.DungeonUtil.random(#csbName)]
            end
            self.currCsbName = csbName
            -- local csbName = qy.Config.room["10101"]["scenes"]
            qy.Event.dispatch(qy.Event.LOAD_TILE, csbName)

            if bodyLayer ~= false then
                qy.Event.dispatch(qy.Event.BODY_LAYER_RESET)
            end
            if ornamentLayer ~= false then
                qy.Event.dispatch(qy.Event.ORNAMENT_LAYER_RESET)
            end

        end, 0.01)
    end
end

--获得所有房间的地图数据
function DungeonModel:getMapData()
	return self.mapData
end

--根据房间名获取房间信息
function DungeonModel:getMapDataByPos(position)
    return self.mapData[position]
end

--获得当前所在房间的信息
function DungeonModel:getCurrentPosData()
	local data = self:getMapDataByPos(self.explore.pos)
	-- data["name"]
	return data
end

--每个地图4个事件
function DungeonModel:getCurrentPosEventByIndex(idx)
    return self:getCurrentPosData()["room"][idx]
end

--更新explore数据
function DungeonModel:updateExploreData(explore)
    if explore then        
        if explore["pos"] ~= self.explore["pos"] then
            self.currentBodyPos = 667
        end

        for k, v in pairs(explore) do
            if explore[k] ~= self.explore[k] then
                self.explore[k] = explore[k]
            end
        end
    end
end

--更新个别房间或全部房间的数据  想着从当前地图出去后要清空self.mapData
function DungeonModel:updateMapData(mapData)
    if mapData then
        for k, v in pairs(mapData) do
            self:updatePosData(k, v)
        end
    end
end

function DungeonModel:getExploreData()
    return self.explore
end

--更新某个房间的数据
function DungeonModel:updatePosData(position, data)
    self.mapData[position] = data
end


function DungeonModel:loadTileRandom(bodyLayer, ornamentLayer)
    local keys = {"B", "C", "D", "E", "F", "G", "H", "I"}
    local mapData = self:getMapData()

    for i = 1, #keys do
        for j = 1, 5 do
            if mapData[keys[i]..j] and mapData[keys[i]..j]["room_config_id"] then
                qy.DungeonUtil.asynExecute(function()
                    local data = self:getCurrentPosData()
                    local scenes = qy.Config.room[tostring(mapData[keys[i]..j]["room_config_id"])]["scenes"]
                    if string.find(scenes, "|") then
                        scenes = qy.tank.utils.String.split(scenes, "|")
                        scenes = scenes[qy.DungeonUtil.random(#scenes)]
                    end

                    qy.Event.dispatch(qy.Event.LOAD_TILE, scenes)

                    if bodyLayer ~= false then
                        qy.Event.dispatch(qy.Event.BODY_LAYER_RESET)
                    end
                    if ornamentLayer ~= false then
                        qy.Event.dispatch(qy.Event.ORNAMENT_LAYER_RESET)
                    end
                end, 0.01) 
                return
            end
        end
    end 
end


------------------------------------------------------------------地图数据相关 end



------------------------------------------------------------------背包数据 start
function DungeonModel:sortBackpackData(data)
    table.sort(data, function(a, b)        
        if b["prop_id"] and not a["prop_id"] then
            return true
        elseif b["quality"] < a["quality"] then
            return true
        elseif a["equip_id"] and b["equip_id"] and b["quality"] == a["quality"] and b["type"] > a["type"] then
            return true
        elseif tonumber(b["id"]) > tonumber(a["id"]) and b["quality"] == a["quality"] and (not (a["equip_id"] and b["equip_id"]) or b["type"] > a["type"]) then
            return true
        else
            return false
        end
    end)
end


function DungeonModel:sortBackpackPropsData()
    self.backpackPropsShow = {}

    for id, data in pairs(self.backpackOriginal.props) do
        for key, value in pairs(data) do
            table.insert(self.backpackPropsShow, value)
        end
    end      
    self:sortBackpackData(self.backpackPropsShow)
end


function DungeonModel:sortBackpackEquipData()
    self.backpackEquipShow = {}

    for unique_id, data in pairs(self.backpackOriginal.equip) do
        if data["hero_unique_id"] == 0 and data["pos"] == 0 then
            table.insert(self.backpackEquipShow, data)
        end
    end
    self:sortBackpackData(self.backpackEquipShow)
end


function DungeonModel:sortBackpackSupplyData()
    self.backpackSupplyShow = {}

    for id, data in pairs(self.backpackOriginal.supply) do 
        table.insert(self.backpackSupplyShow, data)
    end

    table.sort(self.backpackSupplyShow, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)
end


function DungeonModel:updateBackpackData(backpack)
    self.backpackOriginal = self.backpackOriginal or {}
    self.backpackOriginal.equip = self.backpackOriginal.equip or {}
    self.backpackOriginal.props = self.backpackOriginal.props or {}
    self.backpackOriginal.supply = self.backpackOriginal.supply or {}

    if backpack.equip then
        for k, v in pairs(backpack.equip) do
            local data
            if v ~= -1 and v["equip_id"] then
                data = clone(qy.Config.equipment[tostring(v["equip_id"])])
                for k2, v2 in pairs(v) do
                    data[k2] = v[k2]
                end
            end
            self.backpackOriginal.equip[k] = data
        end
        self:sortBackpackEquipData()
    end

    if backpack.props then
        for k, v in pairs(backpack.props) do
            self.backpackOriginal.props[k] = self.backpackOriginal.props[k] or {}
            for k2, v2 in pairs(v) do
                local data 
                if v2 ~= -1 and v2["prop_id"] then
                    data = clone(qy.Config.props[tostring(v2["prop_id"])])
                    data["num"] = v2["num"]
                end
                self.backpackOriginal.props[k][k2] = data
            end
        end
        self:sortBackpackPropsData()
    end

    if backpack.supply then
        for k, v in pairs(backpack.supply) do            
            local data
            if v ~= -1 and v["supply_id"] then
                data = clone(qy.Config.supply[tostring(v["supply_id"])])
                for k2, v2 in pairs(v) do
                    data[k2] = v[k2]
                end
            end
            self.backpackOriginal.supply[k] = data
        end
        self:sortBackpackSupplyData()
    end
end


function DungeonModel:getBackpackData()
    local result = {}
    for i = 1, #self.backpackPropsShow do
        table.insert(result, self.backpackPropsShow[i])
    end
    for i = 1, #self.backpackEquipShow do
        table.insert(result, self.backpackEquipShow[i])
    end
    return result
end


function DungeonModel:getBackpackPropsData()
    return self.backpackPropsShow or {}
end


function DungeonModel:getBackpackEquipData()
    return self.backpackEquipShow or {}
end

function DungeonModel:getBackpackSupplyData()
    return self.backpackSupplyShow or {}
end

------------------------------------------------------------------背包数据 end


------------------------------------------------------------------玩家控制, 移动相关 start
-- --摇杆按下的消息  1左 2右
function DungeonModel:rockerPress(direction)
    self.moveSwitch = 1
    self.moveDirection = direction
    print(not self.status or self.status == "wait", self.status)
    if not self.status or self.status == "wait" then
        self:playerBodyAction()
        qy.Event.dispatch(qy.Event.BODY_MOVE_ACTION_START)
    end
end


--摇杆抬起
function DungeonModel:rockerLiftUp()
    self.moveSwitch = 0
    self.moveDirection = 0
    -- qy.Event.dispatch(qy.Event.BODY_MOVE_ACTION_END)
end



function DungeonModel:playerBodyAction()
    if self.status ~= "wait" and self.status ~= nil then
        return
    end
    
    if self.moveSwitch == 1 then
        self:playerBodyMove()
    else

        qy.Event.dispatch(qy.Event.BODY_MOVE_ACTION_END)
    end
end


--移动 参数pos可选，传pos则会移动固定的点
function DungeonModel:playerBodyMove()
    if self.status ~= "move" and self.moveDirection ~= 0 then
        self:updateStatus("move")

        local param = {}
        param.duration = 0.1

        if self.moveDirection == 1 and self:getCurrBodyPos() > 667 + 20 then
            param.pos = 23
            self.currentBodyPos = self:getCurrBodyPos() - param.pos
            qy.Event.dispatch(qy.Event.LAYER_UPDATE_POS_ACTION, param)
        elseif self.moveDirection == 2 and self:getCurrBodyPos() < (7 * 667 - 25) then
            param.pos = -29
            self.currentBodyPos = self:getCurrBodyPos() - param.pos
            qy.Event.dispatch(qy.Event.LAYER_UPDATE_POS_ACTION, param)
        end


        qy.DungeonUtil.asynExecute(function()
            if not self:judgementEventTrigger() then
                qy.DungeonModel:playerBodyMoveEnd()
            end
        end, param.duration)
    end
end


--移动完毕
function DungeonModel:playerBodyMoveEnd()
    self:updateStatus("wait")
    self:playerBodyAction()
end

function DungeonModel:getCurrBodyPos()
    return self.currentBodyPos or 667
end


function DungeonModel:playerBodyMoveTo(posX, callBack, sender)
    if self.status ~= "move" then
        self:updateStatus("move")

        local subPosX = self:getCurrBodyPos() - posX

        local param     = {}
        param.duration  = math.abs(subPosX / 20) * 0.1
        param.pos       = subPosX
  
        self.currentBodyPos = self:getCurrBodyPos() - subPosX

        qy.Event.dispatch(qy.Event.LAYER_UPDATE_POS_ACTION, param)
        qy.Event.dispatch(qy.Event.BODY_MOVE_ACTION_START)

        qy.DungeonUtil.asynExecute(function()
            -- qy.DungeonModel:playerBodyMoveEnd()
            self:updateStatus("wait")
            qy.Event.dispatch(qy.Event.BODY_MOVE_ACTION_END)
            if callBack then
                callBack(sender)
            end
        end, param.duration)
    end
end



------------------------------------------------------------------玩家控制, 移动相关 end


------------------------------------------------------------------地图内事件相关 start
--判断直接战斗事件的触发
function DungeonModel:judgementEventTrigger()
    for i = 4, 1, -1 do
        local data = self:getCurrentPosEventByIndex(i)
        if self:getCurrBodyPos() > (i + 0.5) * 667 and data["type"] == "room_battle" and data["finish"] == 0 then

            qy.Event.dispatch(qy.Event.BODY_MOVE_ACTION_END)
            self:triggerEvent(i)
            return true
        end
    end
end


--触发战斗事件，直接触发的那种
function DungeonModel:triggerEvent(roomEventIdx)
    local configId = self:getCurrentPosEventByIndex(roomEventIdx)["config_id"]
    --这个room_index不是房间index，而是房间内4个事件的index, 并且idx是0到3
    qy.tank.service.DungeonService:roomBattleStart({["native"] = self.explore.pos, ["room_index"] = roomEventIdx - 1}, function(data)
        self:battleByEnemyId(configId, data["drop_award"])

        if self.eventBattleEndListener then
            qy.Event.remove(self.eventBattleEndListener)
            self.eventBattleEndListener = nil
        end
        
        self.eventBattleEndListener = qy.Event.add(qy.Event.BATTLE_END, function(event)     
            self:updateStatus("wait")
            qy.Event.remove(self.eventBattleEndListener)
            qy.tank.service.DungeonService:roomBattleEnd(
                {["native"] = self.explore.pos, ["room_index"] = roomEventIdx - 1, ["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}, 
                function(data)
                    if qy.BattleBodyModel:judgementGameLose() == "lose" then
                        qy.tank.service.DungeonService:closure({["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}) 
                    else
                        for k, v in pairs(data.map) do
                            self:updatePosData(k, v)
                        end
                    end
            end)
        end)
    end)
end


--说话人的阵位，触发点1到12
-- 1 探索时点击物体触发空事件时  随机幸存者
-- 2 切换地图后-血量不足（某位英雄血量少于30%）  随机幸存者
-- 3 切换地图后-压力过高（某位英雄处于崩溃中）  随机幸存者
-- 4 切换地图后-状态正常  随机幸存者
-- 5 刚进入探索时  随机幸存者
-- 6 队友死亡  随机幸存者
-- 7 被暴击  被暴击目标
-- 8 暴击敌人（20%）  暴击者
-- 9 击杀目标  击杀者
-- 10 崩溃时-自身被击中（20%）  自身
-- 11 崩溃时-队友被击中（10%）  自身
-- 12 扎营时使用技能  使用者
function DungeonModel:triggerTalk(id, trigger, probability)
    if id == nil or qy.DungeonUtil.random(100) > (probability or 30) then
        return
    end

    local result = {}
    local config = qy.Config.dialogue_text
    local heroProfession = qy.BattleBodyModel:getBodyByUniqueId(id):get("profession")
    local types = {heroProfession, 0}
    for j = 1, #types do
        local id = types[j]

        if trigger < 10 then
            id = id.."0"..trigger
        else
            id = id..trigger
        end

        for i = 1, 99 do
            if i < 10 then
                id = id.."0"..i
            else
                id = id..i
            end

            if config[id] then
                table.insert(result, id)
            end
        end
    end

    qy.Event.dispatch(qy.Event.HERO_TALK, {["id"] = id, ["talkId"] = result[qy.DungeonUtil.random(#result)]})
end


--英雄说话触发点2/3。 血量低于百分之三十与英雄崩溃
function DungeonModel:judgementHeroStatusTalk()
    local heros = qy.BattleBodyModel:getHeros()
    local flag = false
    for i = 1, 4 do
        if heros[tostring(i)] then
            if heros[tostring(i)]:getTotalProperty("134") / heros[tostring(i)]:getTotalProperty("106") <= 0.3 then
                flag = true
                break
            end
        end
    end

    if flag then
        self:triggerTalk(qy.BattleBodyModel:getRandomAliveBodyId(), 2)
        return
    else
        for i = 1, 4 do
            if heros[tostring(i)] then
                if heros[tostring(i)]:get("special")["type"] == 2 then
                    flag = true
                    break
                end
            end
        end
    end

    if flag then
        self:triggerTalk(qy.BattleBodyModel:getRandomAliveBodyId(), 3)
    else        
        self:triggerTalk(qy.BattleBodyModel:getRandomAliveBodyId(), 4)
    end
end


function DungeonModel:battleByEnemyId(enemyId, drop_award)
    local enemyConfigData = qy.Config.enemy[tostring(enemyId)]
    local table = {}

    for i = 1, 4 do
        if enemyConfigData["monster"..i] ~= "" and not table[tostring(i)] then
            --id这里这么写 是因为id想跟英雄的区分一下 仅此而已
            local monsterId = enemyConfigData["monster"..i]
            local level = self:getExploreData()["difficulty_level"]
            if tonumber(level) < 10 then
                monsterId = monsterId.."0"..level
            else
                monsterId = monsterId..level
            end

            table[tostring(i)] = {["id"] = "123456"..i, ["configId"] = monsterId}

            local monsterConfigData = qy.Config.monster[monsterId]
            
            if monsterConfigData["body"] > 1 then
                for j = 1, monsterConfigData["body"] - 1 do
                    table[tostring(i + j)] = "monster"..i
                end
            end
        end
    end

    qy.BattleBodyModel:setBattleMonsterData(table, drop_award)
    qy.BattleManager:start(enemyConfigData)
    qy.Event.dispatch(qy.Event.BODY_MOVE_ACTION_END)
    self:updateStatus("battle")
end




--点击事件战斗的结束，区别直接战斗的 战斗结束
function DungeonModel:sceneObjectTail(roomEventIdx)
    if self.battleEndListener then        
        qy.Event.remove(self.battleEndListener)
        self.battleEndListener = nil
    end

    self.battleEndListener = qy.Event.add(qy.Event.BATTLE_END, function(event)     
        self:updateStatus("wait")
        qy.Event.remove(self.battleEndListener)
        self.battleEndListener = nil
        qy.tank.service.DungeonService:sceneObjectTail(
            {["native"] = self.explore.pos, ["room_index"] = roomEventIdx - 1, ["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}, 
            function(data)
                if qy.BattleBodyModel:judgementGameLose() == "lose" then
                    qy.tank.service.DungeonService:closure({["formation"] = qy.BattleBodyModel:getServiceUseHeroData()}) 
                else
                    for k, v in pairs(data.map) do
                        self:updatePosData(k, v)
                    end
                end 
        end)
    end)
end



function DungeonModel:sceneEvent(subType, subConfigId, eventIdx, data)    
    if subType == "scene_empty" then
        self:triggerTalk(qy.BattleBodyModel:getRandomAliveBodyId(), 1)
    elseif subType == "scene_effect" then
        self:updateStatus("event")
        local burst = data["burst"]
        local addBuff = data["add_buff"]

        function judgementBurst()
            local time = 0
            if burst and burst.status then
                for i = 1, 4 do
                    local hero = qy.BattleBodyModel:getHeros()[tostring(i)]
                    if hero and burst.status[tostring(hero:get("id"))] then
                        qy.DungeonUtil.asynExecute(function()
                            qy.Event.dispatch(qy.Event.COLLAPSE_AWAKENING, {["campAtkPosition"] = hero:get("campAtkPosition"), ["status"] = tostring(burst.status[tostring(hero:get("id"))]), ["effect"] = burst["effect"][tostring(hero:get("id"))]})
                        end, time)
                        time = time + 6
                    end
                end
            end

            qy.DungeonUtil.asynExecute(function()
                if self.status == "event" then
                    self:updateStatus("wait")
                end
            end, time)
        end

        if qy.DungeonUtil.getTableLength(addBuff) > 0 then
            for atkPosition, buffData in pairs(addBuff) do
                for buffId, buffIdxData in pairs(buffData) do
                    for idx, buff in pairs(buffIdxData) do
                        buff["campAtkPosition"] = "hero"..atkPosition
                        qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, buff)
                    end
                end
            end
        end

        qy.DungeonUtil.asynExecute(function()
            local dieBody = qy.BattleBodyModel:judgementAllBodyJustDead("hero")
            if type(dieBody) == "table" and qy.DungeonUtil.getTableLength(dieBody) > 0 then
                --死亡数大于0
                qy.Event.dispatch(qy.Event.BODY_DIE, dieBody)

                qy.DungeonUtil.asynExecute(function()
                    local result = qy.BattleBodyModel:judgementGameLose()
                    if result == "" then
                        qy.BattleBodyModel:updateAtkPosition()
                        qy.Event.dispatch(qy.Event.UPDATE_ATK_POSITION)
                        judgementBurst()
                    elseif result == "lose" then
                        qy.tank.service.DungeonService:closure({["formation"] = qy.BattleBodyModel:getServiceUseHeroData()})
                    end
                end, 0.6)
            else
                judgementBurst()
            end
        end, 1)
    --如果是战斗，先屏蔽点击，开干
    elseif subType == "scene_battle" then
        self:updateStatus("battle")
        qy.DungeonUtil.asynExecute(function()
            self:battleByEnemyId(subConfigId, data["drop_award"])
            self:sceneObjectTail(eventIdx)
        end, 1.5)
    end
end


------------------------------------------------------------------地图内事件相关 end


function DungeonModel:updateStatus(status)
    self.status = status
end

function DungeonModel:getStatus()
    return self.status
end

function DungeonModel:clearData()
    self.backpackOriginal = {}
    self.explore = {}
    self.mapData = {}
    self.currentBodyPos = 667
    self.moveSwitch = 0
    self.moveDirection = 0
    self.status = "wait"
end




return DungeonModel