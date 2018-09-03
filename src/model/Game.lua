local Game = class("Game", qy.tank.model.BaseModel)



function Game:initData(data)
    qy.tank.model.UserInfoModel:init(data)
    qy.tank.model.BodyModel:init(data.hero)
    qy.tank.model.DungeonModel:init(data)
    qy.tank.model.AreaModel:init(data.pass)


    if data.explore.is_complete == 0 and data.explore.pos ~= "" then
        --调用地图恢复
        qy.tank.service.DungeonService:resume(function(data)
            qy.DungeonModel:setData(data)
            qy.tank.manager.ScenesManager:showDungeonScene()
        end)
    elseif data.explore.is_complete == 1 and data.explore.pos == "" then
        --qy.tank.manager.ScenesManager:showHomeScene()
        if device.platform == "android" or device.platform == "ios" then
            --local userDefault = cc.UserDefault:getInstance()
            --local mp4 = userDefault:getStringForKey("mp4", "")
            local guideIndex = qy.GuideModel:getGuideIndex()
            if guideIndex == 1 then
                require("view.login.CGView").new():show()
                --require("view.login.CGView").new():show()
            else
                --qy.tank.manager.ScenesManager:showHomeScene()
                qy.tank.manager.ScenesManager:showHomeScene()
            end
            
        else
            qy.tank.manager.ScenesManager:showHomeScene()
        end
    end    
end


function Game:updateData(jdata, request)
     -- 更新服务器时间
    if jdata.server_time then
        qy.UserInfoModel:updateServerTime(jdata.server_time)
    end

    if jdata.skill then
        qy.SkillModel:updateSkillById(jdata.skill)
    end

    if jdata.hero then
        qy.tank.model.BodyModel:updateHero(jdata.hero)
    end

    if jdata.equip then
        qy.tank.model.EquipModel:updateEquipById(jdata.equip)
    end

    if jdata.formation then
        qy.FormationModel:init(jdata.formation)
    end

    if jdata.props then
        qy.PropModel:updateProp(jdata.props)
    end

    if jdata.backpack then
        if jdata.backpack.equip then
            qy.tank.model.EquipModel:updateEquipById(jdata.backpack.equip)
        end        
    end

    if jdata.pass then
        qy.AreaModel:updatePass(jdata.pass)
    end

    if jdata.mission then
        qy.TaskModel:update(jdata.mission)
    end

    if jdata.remind_list then
        qy.MailModel:setMailInfo(jdata.remind_list)
        qy.Event.dispatch("mailUpdate")
    end

    --更新用户数据
    qy.UserInfoModel:updateUserInfo(jdata)
    qy.DungeonModel:setData(jdata)
    qy.BattleBodyModel:updateBattleHero(jdata.battle_heros)

    if jdata.backpack then
        qy.DungeonModel:updateBackpackData(jdata.backpack)
    end

    
    if jdata.append_exp then
        qy.Event.dispatch(qy.Event.UPDATE_EXP, jdata.append_exp)
    end
end


return Game
