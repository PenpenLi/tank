local BattleManager = {}

function BattleManager:instance()
    local o = _G.BattleManager
    if o == nil then 
        o = {}
        _G.BattleManager = o
        setmetatable(o, self)
        self.__index = self 
    end
    return o
end

--当前战斗进程的状态
BattleManager.BATTLE_STATUS = {    
    ["BATTLE_READY"]                = "BATTLE_READY" ,
    ["BATTLE_SNEAK_ATTACK"]         = "BATTLE_SNEAK_ATTACK" ,
    ["BATTLE_COMMAND_SKILL"]        = "BATTLE_COMMAND_SKILL" ,
    ["BATTLE_BEGIN"]                = "BATTLE_BEGIN",
    ["UPDATE_SPEED_QUEUE"]          = "UPDATE_SPEED_QUEUE",
    ["ITERATION_CURRENT_BODY_BUFF"] = "ITERATION_CURRENT_BODY_BUFF",
    ["BATTLE_BODY_EXECUTE"]         = "BATTLE_BODY_EXECUTE",
    ["BATTLE_SKILL_SELECT_BEGIN"]   = "BATTLE_SKILL_SELECT_BEGIN",
    ["SHOW_BATTLE_ACTION"]          = "SHOW_BATTLE_ACTION",
    ["COLLAPSE_AWAKENING"]          = "COLLAPSE_AWAKENING",
    ["CURR_BODY_END"]               = "CURR_BODY_END",
    ["BODY_DIE"]                    = "BODY_DIE",
    ["UPDATE_ATK_POSITION"]         = "UPDATE_ATK_POSITION",
    ["BATTLE_END"]                  = "BATTLE_END",
}


function BattleManager:start(enemyConfigData)
    print("BattleManager:start")
    self.enemyConfigData = enemyConfigData

    qy.QYPlaySound.playMusic("music/fight_bgm.mp3")

    -- cc.Director:getInstance():getScheduler():setTimeScale(0.5);

    self.isAutoBattle = cc.UserDefault:getInstance():getBoolForKey("autoBattle", false)
    self.battleSpeed = cc.UserDefault:getInstance():getStringForKey("battleSpeed", "1")

    qy.BattleModel:init()
    self:battleReady()
end


function BattleManager:update(data)
    if (not self.battleStatus or self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_END) and qy.DungeonModel:getStatus() == "battle" then
        self:battleReady()

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_READY then
        self:battleReadyEnd()

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_SNEAK_ATTACK then        
        self:battleSneakEnd()

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_COMMAND_SKILL then        
        self:commandSkillEnd()

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.UPDATE_SPEED_QUEUE then        
        self:updateSpeedQueueEnd()

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.ITERATION_CURRENT_BODY_BUFF then        
        self:iterationCurrentBodyBuffEnd()

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.UPDATE_ATK_POSITION then        
        self:updateAtkPositionEnd()

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_SKILL_SELECT_BEGIN and data then        
        self:showBattleAction(data)

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_BODY_EXECUTE and data then        
        self:showBattleAction(data)

    elseif self.battleStatus == BattleManager.BATTLE_STATUS.SHOW_BATTLE_ACTION then        
        self:currentBodyEnd()
    end
end




--战斗准备
function BattleManager:battleReady()
    print("BattleManager:battleReady")
    self:setBattleStatus(BattleManager.BATTLE_STATUS.BATTLE_READY)
    qy.Event.dispatch(qy.Event.BATTLE_READY)
end



--战斗准备结束 判断偷袭
function BattleManager:battleReadyEnd()
    print("BattleManager:battleReadyEnd")
    qy.Event.dispatch(qy.Event.BATTLE_READY_END)
    
    local sneakObject = qy.DungeonModel:getExploreData()["sneakAttack"]
    if sneakObject and tostring(sneakObject) ~= "0" then
        self:setBattleStatus(BattleManager.BATTLE_STATUS.BATTLE_SNEAK_ATTACK)
        qy.Event.dispatch(qy.Event.BATTLE_SNEAK_ATTACK, tostring(sneakObject))
    else        
        self:battleSneakEnd()
    end
end


--偷袭判断结束 将所有人的被动技能变成buff，使用指挥技能
function BattleManager:battleSneakEnd()
    print("BattleManager:battleSneakEnd")
    --将所有被动技能变成buff，但事实上不应该在这做，而是在外面就已经变成buff了，并且是永久的
    -- qy.BattleBodyModel:passiveSkill()
    local commandSkillData = qy.BattleBodyModel:commandSkill()
    if #commandSkillData == 0 then
        self:battleBegin()
    else
        self:commandSkill(commandSkillData)
    end
end


--指挥技能开始
function BattleManager:commandSkill(skillData)
    print("BattleManager:commandSkill")
    self:setBattleStatus(BattleManager.BATTLE_STATUS.BATTLE_COMMAND_SKILL)
    qy.Event.dispatch(qy.Event.BATTLE_COMMAND_SKILL, skillData)
    qy.Event.dispatch(qy.Event.BODY_INFO_UPDATE)
end


--指挥技释放结束
function BattleManager:commandSkillEnd()
    print("BattleManager:commandSkillEnd")
    self:battleBegin()
end


--战斗正式开始
function BattleManager:battleBegin()
    print("BattleManager:battleBegin")
    self:setBattleStatus(BattleManager.BATTLE_STATUS.BATTLE_BEGIN)
    --更新所有人所有技能的前置cd
    qy.BattleBodyModel:addAllBodysSkillFrontCD()
    qy.Event.dispatch(qy.Event.BATTLE_BEGIN)

    qy.DungeonUtil.asynExecute(function()
        self:updateSpeedQueue()
    end, 0.1)
end


--开始更新队列， 根据速度执行下一个人出手
function BattleManager:updateSpeedQueue()
    print("BattleManager:updateSpeedQueue")
    --更新队列 并且把当前出手的选中精灵移到出手的人下面

    self:setBattleStatus(BattleManager.BATTLE_STATUS.UPDATE_SPEED_QUEUE)    

    qy.DungeonUtil.asynExecute(function()
        qy.BattleBodyModel:updateSpeedQueue()
    end, 0.01)
end


--更新队列结束，开始执行
function BattleManager:updateSpeedQueueEnd()
    print("BattleManager:updateSpeedQueueEnd")
    -- local nextBody = qy.BattleBodyModel:getNextBody()
    -- assert(nextBody ~= nil and (not nextBody:isDie()), "The nextBody can not nil or die")

    --先计算这个人 需要在战斗前产生效果的buff
    --显示buff掉血，眩晕等。再更新buff回合数, 在这个阶段，下方面板先置灰，等待这个阶段结束后，再判断可否出手后再将其恢复


    --等上面的动画都结束了。然后再判断是跳过回合，还是等待操作，还是自动战斗
    --要跟上面分开，上面动画结束后才到下面
    --buff, 死亡，自动强制跳过
    --技能都不可以释放，手动跳过
    qy.DungeonUtil.asynExecute(function()
        self:iterationCurrentBodyBuff()
    end, 0.1)
end

--到某个人出手时，先恢复能量，再迭代此人的buff效果
function BattleManager:iterationCurrentBodyBuff()
    print("BattleManager:iterationCurrentBodyBuff")
    self:setBattleStatus(BattleManager.BATTLE_STATUS.ITERATION_CURRENT_BODY_BUFF)

    qy.BattleBodyModel:getNextBody():addEnergy(3)

    local buffResult = qy.BattleBodyModel:getNextBody():iterationBuff()
    for i = 1, #buffResult do
        qy.DungeonUtil.asynExecute(function()
            qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, buffResult[i])
        end, 0.01 * i)
    end

    qy.DungeonUtil.asynExecute(function()
        qy.Event.dispatch(qy.Event.BODY_INFO_UPDATE) 

        if #buffResult > 0 then
            qy.DungeonUtil.asynExecute(function()
                qy.BattleManager:iterationCurrentBodyBuffEnd()            
            end, 1.5)
        else
            qy.BattleManager:iterationCurrentBodyBuffEnd()
        end
    end, 0.01)
    
end


--buff迭代结束
function BattleManager:iterationCurrentBodyBuffEnd()
    print("BattleManager:iterationCurrentBodyBuffEnd")
    qy.DungeonUtil.asynExecute(function()
        self:judgementAllBodyDie(self.execute)
    end, 0.01)
end


--执行这个人的行为
function BattleManager:execute()
    print("BattleManager:execute")
    self:setBattleStatus(BattleManager.BATTLE_STATUS.BATTLE_BODY_EXECUTE)
    local nextBody = qy.BattleBodyModel:getNextBody()
    -- assert(nextBody ~= nil and (not nextBody:isDie()), "The nextBody can not nil or die")
    if nextBody and not nextBody:isDie() and qy.BattleBodyModel:judgementBodyCanAct(nextBody) then

        qy.DungeonUtil.asynExecute(function()
            qy.BattleBodyModel:judgementBodyAllSkill(nextBody)

            qy.DungeonUtil.asynExecute(function()
                if nextBody:get("camp") == "hero" and self.isAutoBattle == false then
                    --选择行动，等待用户选择
                    self:setBattleStatus(BattleManager.BATTLE_STATUS.BATTLE_SKILL_SELECT_BEGIN)
                    qy.Event.dispatch(qy.Event.BATTLE_SKILL_SELECT_BEGIN)
                else
                    qy.BattleModel:autoBattle(nextBody)
                end
            end, 0.02)
        end, 0.01)
    else
        -- self:updateSpeedQueue()
        self:currentBodyEnd()
    end
end


--显示战斗动画
function BattleManager:showBattleAction(data)
    print("BattleManager:showBattleAction")
    self:setBattleStatus(BattleManager.BATTLE_STATUS.SHOW_BATTLE_ACTION)
    qy.DungeonUtil.asynExecute(function()
        qy.Event.dispatch(qy.Event.BATTLE_ACTION, data)                                                  
    end, 0.01)
end


--当前出手的人行动结束
function BattleManager:currentBodyEnd()
    print("BattleManager:currentBodyEnd")

    self:setBattleStatus(BattleManager.BATTLE_STATUS.CURR_BODY_END)    
    --更新出手人的所有cd
    local nextBody = qy.BattleBodyModel:getNextBody()
    nextBody:iterationCD()
    --更新人物数据信息
    qy.DungeonUtil.asynExecute(function()
        qy.Event.dispatch(qy.Event.BODY_INFO_UPDATE)

        qy.DungeonUtil.asynExecute(function()
            self:judgementAllBodyDie(self.judgementCollapseAwakening)
        end, 0.01)
    end, 0.01)
end


--崩溃觉醒判断
function BattleManager:judgementCollapseAwakening()    
    print("BattleManager:judgementCollapseAwakening")    
    self:setBattleStatus(BattleManager.BATTLE_STATUS.COLLAPSE_AWAKENING)    
    local collapseAwakeningData = qy.BattleBodyModel:judgementCollapseAwakening()
    local time = 0
    for i = 1, #collapseAwakeningData do
        qy.DungeonUtil.asynExecute(function()
            qy.Event.dispatch(qy.Event.COLLAPSE_AWAKENING, collapseAwakeningData[i])
        end, time)
        time = time + 6
    end

    qy.DungeonUtil.asynExecute(function()
        self:updateSpeedQueue()
    end, time + 0.01)
end


--更新每个人的阵位 
function BattleManager:judgementAllBodyDie(nextFun)
    print("BattleManager:judgementAllBodyDie")
    local justDeadBody = qy.BattleBodyModel:judgementAllBodyJustDead()

    if type(justDeadBody) == "table" and qy.DungeonUtil.getTableLength(justDeadBody) > 0 then
        self:setBattleStatus(BattleManager.BATTLE_STATUS.BODY_DIE)

        qy.DungeonUtil.asynExecute(function()
            --死亡数大于0
            qy.Event.dispatch(qy.Event.BODY_DIE, justDeadBody)
            --有死的就先更新阵位，在阵位更新结束后再执行nextfun
            self.nextFun = nextFun

            qy.DungeonUtil.asynExecute(function()
                local isWin = qy.BattleBodyModel:judgementBattleWin()

                if isWin == "win" then
                    --赢了
                    self:battleEnd()
                elseif isWin == "lose" then
                    --输了
                    self:setBattleStatus(BattleManager.BATTLE_STATUS.UPDATE_ATK_POSITION)
                    qy.BattleBodyModel:updateAtkPosition()
                    qy.Event.dispatch(qy.Event.UPDATE_ATK_POSITION)
                    self.nextFun = self.battleEnd
                else                
                    self:setBattleStatus(BattleManager.BATTLE_STATUS.UPDATE_ATK_POSITION)
                    qy.BattleBodyModel:updateAtkPosition()
                    qy.Event.dispatch(qy.Event.UPDATE_ATK_POSITION)
                end
            end, 0.6)
        end, 0.01)
        
    else
        qy.DungeonUtil.asynExecute(function()
            nextFun(self)
        end, 0.01)
    end
end



--更新每个人的阵位结束
function BattleManager:updateAtkPositionEnd()   
    print("BattleManager:updateAtkPositionEnd") 
    qy.DungeonUtil.asynExecute(function()
        -- self:updateSpeedQueue()
        if type(self.nextFun) == "function" and self.battleStatus == BattleManager.BATTLE_STATUS.UPDATE_ATK_POSITION then
            self:nextFun()
        end
    end, 0.1)
end


--跳过当前行动的人
function BattleManager:skipCurrentBody()
    print("BattleManager:skipCurrentBody") 
    -- if self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_SKILL_SELECT_BEGIN then
        -- self:updateSpeedQueue()
    -- end
    self:currentBodyEnd()
end

--自动战斗逻辑
function BattleManager:autoBattle(flag)
    if self.battleStatus == BattleManager.BATTLE_STATUS.BATTLE_SKILL_SELECT_BEGIN and self.isAutoBattle ~= flag and flag then
        qy.BattleModel:autoBattle(qy.BattleBodyModel:getNextBody())
    end
    self.isAutoBattle = flag
    cc.UserDefault:getInstance():setBoolForKey("autoBattle", self.isAutoBattle == true)
end

function BattleManager:setBattleSpeed(speed)
    self.battleSpeed = speed
    cc.UserDefault:getInstance():setStringForKey("battleSpeed", speed)
end


--设置当前战斗进度
function BattleManager:setBattleStatus(status)
    self.battleStatus = status
end

--获得当前战斗进度
function BattleManager:getBattleStatus()
    return self.battleStatus
end


function BattleManager:battleEnd()    
    print("BattleManager:battleEnd")
    cc.Director:getInstance():getScheduler():setTimeScale(1)
    self.nextFun = nil
    self:setBattleStatus(BattleManager.BATTLE_STATUS.BATTLE_END)

    qy.BattleBodyModel:resetBodys()
    qy.BattleBodyModel:resumeAllBodySpeed()
    qy.Event.dispatch(qy.Event.BATTLE_END)
    
    qy.QYPlaySound.playMusic("music/tansuozhong.mp3")
end


function BattleManager:destroy()
    for i = 1, #self.listener do
        qy.Event.remove(self.listener[i])
    end
end

function BattleManager:getEnemyConfigData()
    return self.enemyConfigData
end


return BattleManager