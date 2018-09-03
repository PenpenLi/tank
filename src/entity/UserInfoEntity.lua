--[[
    说明: 用户信息实体
]]

local UserInfoEntity = qy.class("UserInfoEntity", qy.tank.entity.BaseEntity)

function UserInfoEntity:ctor(userinfo)
    self.model = qy.tank.model.UserInfoModel
    self:updateBaseInfo(userinfo.baseinfo)
    self:updateRecharge(userinfo.recharge)
    self:updateResource(userinfo.resource)

    -- 战队升级需要的经验
    self:setproperty("needExp",0)
end

--更新用户基本信息
function UserInfoEntity:updateBaseInfo(baseInfo)
    -- 昵称
    self:setproperty("name", baseInfo.nickname)
    -- kid
    self:setproperty("kid", baseInfo.kid)
    -- uid
    self:setproperty("uid", baseInfo.uid)
    -- 经验
    --self:setproperty("exp", baseInfo.exp)
    -- 原本战斗力
    --self.oldfight_power = self.fightPower or baseInfo.fight_power

    --战斗力
    --self:setproperty("fightPower", baseInfo.fight_power)
    --头像
    self:setproperty("headicon", baseInfo.headicon)

    self:setproperty("level", baseInfo.level)
end


--更新recharge相关
function UserInfoEntity:updateRecharge(recharge)
    self:setproperty("diamond", recharge.diamond)
    -- VIP
    self:setproperty("vipLevel", recharge.vip_level)
    self:setproperty("isDrawDaily", recharge.is_draw_daily)
    -- 充值
    self:setproperty("amount", recharge.amount)
    -- 充值奖励
    self:setproperty("gift", recharge.gift or {})
    --充值的钻石数
    self:setproperty("payment_diamond_added", recharge.payment_diamond_added + (recharge.amount_diamond_extra or 0))
end


function UserInfoEntity:updateResource(resource)
    self:setproperty("skill_spot", resource.skill_spot)
    
    self:setproperty("camp_spot", resource.camp_spot)
    
    self:setproperty("gold", resource.gold)
    self:setproperty("embers", resource.embers)
    self:setproperty("energy", resource.energy)
    self:setproperty("energyTime", resource.energy_uptime+3600)
end



return UserInfoEntity
