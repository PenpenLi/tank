
--[[

]]

local UserInfoModel = qy.class("UserInfoModel", qy.tank.model.BaseModel)

UserInfoModel.uid = nil -- sid
UserInfoModel.kid = nil -- sid
UserInfoModel.pid = cc.UserDefault:getInstance():getStringForKey("uuid", "abcdefg")


function UserInfoModel:init(data)
    self.uid = data.baseinfo.uid
    self.kid = data.baseinfo.kid
    local ud = cc.UserDefault:getInstance()
    ud:setIntegerForKey("tank_default_kid",self.kid)
    ud:flush()
    self.userInfoEntity = qy.tank.entity.UserInfoEntity.new(data)

    self:setSkillInfo(data.skill)
    self:setRecrultingInfo(data.recruit)
    self:setFormationInfo(data.formation)
    self:setEquipInfo(data.equip)
    self:setPropInfo(data.props)
    self:setArsenal(data.building.arsenal)
    self:setTraining(data.building.training)
    self:setMaterial(data.building.material)
    self:setMission(data.mission)
    self:setBaseMain(data.building.base)
    self:setMailInfo(data.remind_list)
    self:setGuideInfo(data.guide)
    --启动服务器时间定时器
end


function UserInfoModel:getUserDataByKey(key)
    return self.userInfoEntity:get(key)
end



function UserInfoModel:updateUserData(key, value)
    
end

--存储新手引导
function UserInfoModel:setGuideInfo(guideInfo)
    qy.GuideModel:init(guideInfo)
end

--存储技能信息
function UserInfoModel:setSkillInfo(skillInfo)
    qy.tank.model.SkillModel:init(skillInfo)
end

--存储招募信息
function UserInfoModel:setRecrultingInfo(recruitInfo)
    qy.tank.model.RecruitModel:init(recruitInfo)
end

--存储布阵信息
function UserInfoModel:setFormationInfo(formationInfo)
    qy.FormationModel:init(formationInfo)
end

--存储装备信息
function UserInfoModel:setEquipInfo(equipInfo)
    qy.EquipModel:init(equipInfo)
end

--存储物品信息
function UserInfoModel:setPropInfo(propInfo)
    qy.PropModel:init(propInfo)
end

function UserInfoModel:setArsenal(buildingInfo)
    qy.ArsenalModel:init(buildingInfo)
end

function UserInfoModel:setTraining(buildingInfo)
    qy.TrainingModel:init(buildingInfo)
end

function UserInfoModel:setMaterial(buildingInfo)
    qy.MaterialModel:init(buildingInfo)
end

function UserInfoModel:setBaseMain(buildingInfo)
    qy.BaseMainModel:init(buildingInfo)
end

function UserInfoModel:setMission(taskInfo)
    qy.TaskModel:init(taskInfo)
end

function UserInfoModel:setMailInfo(mailInfo)
    qy.MailModel:setMailInfo(mailInfo)
end

--更新服务器时间
function UserInfoModel:updateServerTime(serverTime)
    self.updateTipTime = 0
    self.serverTime = serverTime
    if self.timeListener == nil then
        self.timeListener = qy.Event.add(qy.Runtime.TIMER_UPDATE,function(event)
            self.serverTime = self.serverTime+ 1
            self.updateTipTime = self.updateTipTime+1
            if self.updateTipTime >60 then
                self.updateTipTime = 0
                qy.Event.dispatch("updateTips")
            end
            if qy.UserInfoModel.userInfoEntity then
                if self.serverTime == qy.UserInfoModel.userInfoEntity.energyTime then
                    if qy.UserInfoModel.userInfoEntity.energy < 30 then
                        qy.UserInfoModel.userInfoEntity.energy = qy.UserInfoModel.userInfoEntity.energy + 1
                        qy.Event.dispatch(qy.Event.USER_RESOURCE_DATA_UPDATE)
                    end
                    qy.UserInfoModel.userInfoEntity.energyTime = qy.UserInfoModel.userInfoEntity.energyTime + 3600
                end
            end
        end)
    end
end


function UserInfoModel:setUserId(uid)
    self.uid = uid
end


function UserInfoModel:setSessionId(sid)
    self.sid = sid
end

function UserInfoModel:getSessionId()
    return self.sid
end



function UserInfoModel:updateUserInfo(data)
    if self.userInfoEntity == nil then
        print("UserInfoModel  －－  > userInfoEntity 还未初始化！")
    return end

    -- 更新用户基础数据
    if data.baseinfo then        
        self.userInfoEntity:updateBaseInfo(data.baseinfo)
        qy.Event.dispatch(qy.Event.USER_BASE_INFO_DATA_UPDATE)
    end

    -- 更新充值数据
    if data.recharge then        
        self.userInfoEntity:updateRecharge(data.recharge)
        qy.Event.dispatch(qy.Event.USER_RECHARGE_DATA_UPDATE)
    end

    -- 更新资源数据
    if data.resource then
        self.userInfoEntity:updateResource(data.resource)
        qy.Event.dispatch(qy.Event.USER_RESOURCE_DATA_UPDATE)
    end
end





return UserInfoModel
