local Skill = class("Skill")


function Skill.excute(sender)
    local monsterId = qy.DungeonUtil.appendNum(require("entity.skills.Skill160").getAddMonsterId(), qy.DungeonModel:getExploreData()["difficulty_level"])

    local bodys = qy.BattleBodyModel:getMonsters()
    local monsterConfig = qy.Config.monster[tostring(monsterId)]
    monsterConfig["configId"] = monsterId
    monsterConfig["drop"] = {}

    for i = 1, 4 do
        if bodys[tostring(i)] == nil or (type(bodys[tostring(i)]) == "table" and bodys[tostring(i)]:isDie()) then
            qy.DungeonUtil.asynExecute(function()
                qy.BattleBodyModel:addBodyInBattle(i, monsterConfig)

                for j = 1, monsterConfig["body"] - 1 do
                    print("ddddddddddddd", i + j)
                    qy.BattleBodyModel:addBodyInBattle(i + j, "monster"..i)
                end
            end, qy.BattleConfig.battleAttackActionDuration)
            break
        end
    end

    local buffConfig = require("entity.skills.Skill160").getBuffConfig()
    for i = 1, 3 do
        if buffConfig["property_"..i] ~= "" and buffConfig["property_"..i] ~= "22401" then
            qy.BattleModel:buffJudgement({["idx"] = i, ["target"] = sender, ["buff"] = buffConfig, ["sender"] = sender, ["skillType"] = "1"})
                    
        end
    end 
end

function Skill.judgement()
    local monsterId = qy.DungeonUtil.appendNum(require("entity.skills.Skill160").getAddMonsterId(), qy.DungeonModel:getExploreData()["difficulty_level"])

    local bodys = qy.BattleBodyModel:getMonsters()
    local flag = true

    print(monsterId)
    print(qy.Config.monster[tostring(monsterId)])
    print(qy.Config.monster[tostring(monsterId)]["body"])
    for i = 4 - (qy.Config.monster[tostring(monsterId)]["body"] or 1) + 1, 4 do
        if type(bodys[tostring(i)]) == "string" or (type(bodys[tostring(i)]) == "table" and not bodys[tostring(i)]:isDie()) then
            flag = false
        end
    end

    return flag
end

function Skill.getBuffConfig()
    local skillConfig = qy.Config.skill["160"]
    local buffConfig = qy.Config.buff[skillConfig["buff_id"]]

    return buffConfig
end


function Skill.getAddMonsterId()
    local buffConfig = require("entity.skills.Skill160").getBuffConfig()

    local addMonsterConfigId = 0
    for i = 1, 3 do
        if buffConfig["property_"..i] == "22401" then
            addMonsterConfigId = buffConfig["effect_value"..i]
            break
        end
    end

    return addMonsterConfigId
end

return Skill