return {	
	--战斗阵位的坐标设置，以屏幕0.5, 0 为基准点
	battlePos = {["hero1"] = cc.p(-148, 240), ["hero2"] = cc.p(-278, 240), ["hero3"] = cc.p(-408, 240), ["hero4"] = cc.p(-538, 240), 
					  ["monster1"] = cc.p(148, 240), ["monster2"] = cc.p(278, 240), ["monster3"] = cc.p(408, 240), ["monster4"] = cc.p(538, 240)},
	--播放战斗准备动画的持续时间
	battleReadyActionDuration = 1,
	--播放偷袭动画的持续时间
	battleSneakAttackActionDuration = 1,
	--播放攻击动画的时间
	battleAttackActionDuration = 0.9,
	--播放攻击动画后，回去，将一切还原的时间
	battleAttackActionEndDuration = 0.3,



}

