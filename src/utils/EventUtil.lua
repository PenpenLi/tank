--[[
	全局事件工具
	Author: Your
	Date: 2015-01-15 21:21:22
]]

local EventUtil = {}


--更新战斗下方操作面板
EventUtil.BODY_UPDATE = "body_update"
EventUtil.LAYER_BLUR = "layer_blur"
EventUtil.RUNACTION = "runaction"
EventUtil.BATTLE_UI_SET_VISIBLE = "battle_ui_set_visible"
EventUtil.LAYER_GL_RESTORE = "layer_gl_restore"
EventUtil.BATTLE_BODY_SET_VISIBLE = "battle.body.set.visible"
EventUtil.BATTLE_TARGET_SELECT = "battle.target.select"


EventUtil.SERVICE_LOADING_SHOW = "serviceLoadingShow"
EventUtil.SERVICE_LOADING_HIDE = "serviceLoadingHide"

EventUtil.USER_RESOURCE_DATA_UPDATE = "user_resource_data_update"

--战斗准备
EventUtil.BATTLE_READY          = "battle_ready"
--战斗准备结束
EventUtil.BATTLE_READY_END      = "battle_ready_end"
--偷袭动画
EventUtil.BATTLE_SNEAK_ATTACK   = "battle_sneak_attack"
--指挥技能
EventUtil.BATTLE_COMMAND_SKILL  = "battle_command_skill"
--战斗开始
EventUtil.BATTLE_BEGIN          = "battle_begin"
--战斗结束
EventUtil.BATTLE_END            = "battle_end"
--更新回合数
EventUtil.BATTLE_UPDATE_ROUND   = "battle_update_round"
--更新速度队列
EventUtil.BATTLE_UPDATE_QUEUE   = "battle_update_queue"
--人物技能选择开始
EventUtil.BATTLE_SKILL_SELECT_BEGIN = "battle_skill_select_begin"
--屏幕左右倾斜
EventUtil.BATTLE_ORBITCAMERA    = "battle_orbitCamera"

EventUtil.BATTLE_UI_LAYER_ADD_CHILD = "battle_ui_layer_add_child"

EventUtil.CONTROL_LAYER_ADD_CHILD = "control_layer_add_child"

EventUtil.BAG_BTN_ACTION = "bag_btn_action"
--body觉醒
EventUtil.BODY_AWAKEN = "body_awaken"
--body崩溃
EventUtil.BODY_COLLAPSE = "body_collapse"


EventUtil.BODY_HP_NODE_VISIBLE = "body_hp_node_visible"

EventUtil.BODY_INFO_UPDATE = "body_info_update"

EventUtil.UPDATE_ATK_POSITION = "update_atk_position"

EventUtil.BODY_DIE = "body_die"

EventUtil.BODY_INFO_SHOW_TEXT = "body_info_show_text"



EventUtil.LAYER_UPDATE_POS_ACTION = "layer_update_pos_action"

EventUtil.BODY_MOVE_ACTION_START = "body_move_action_start"

EventUtil.BODY_MOVE_ACTION_END = "body_move_action_end"

EventUtil.ITEM_DROP_ACTION = "item_drop_action"

EventUtil.ADD_AWARDS_IN_ORNAMENT_LAYER = "add_awards_in_ornament_layer"

EventUtil.ENTER_THE_DOOR = "enter_the_door"

EventUtil.LOAD_TILE = "load_tile"


EventUtil.DUNGEON_CONTROLLER_FUNC = "dungeon_controller_func"


EventUtil.BODY_LAYER_RESET = "body_layer_reset"

EventUtil.ORNAMENT_LAYER_RESET = "ornament_layer_reset"

EventUtil.PLAYER_CONTROL_REMOVE_ALL = "player_controll_remove_all"

EventUtil.COLLAPSE_AWAKENING = "collapse_awakening"

EventUtil.SKILL_NAME_ACTION = "skill_name_action"

EventUtil.HERO_TALK = "hero_talk"

EventUtil.AREA_ALL_UNSELECTED = "area_all_unselected"

EventUtil.AREA_SELECT = "area_select"

EventUtil.UPDATE_FORMATION = "update_formation"

EventUtil.AREA_DIFFICULTY_UPDATE = "area_difficulty"

EventUtil.UPDATE_EXP = "update_exp"



EventUtil.BUY_SUPPLY = "buy_supply"

EventUtil.BUY_SUPPLY_CANCEL = "buy_supply_cancel"


EventUtil.ADD_MONSTER_IN_BATTLE = "add_monster_in_battle"


EventUtil.BTN_ESC_VISIBLE = "btn_esc_visible"

EventUtil.USER_BASE_INFO_DATA_UPDATE = "user_base_info_data_update"
EventUtil.USER_RECHARGE_DATA_UPDATE = "userrecharge_info_data_update"
EventUtil.USER_GUIDE_DATA_UPDATE = "rookieGuide"

EventUtil.YA_LI_ZHI_YIN_DAO = "ya_li_zhi_yin_dao"

-- EventUtil.SELECT_DUNGEON_STOP_SCROLLVIEW = "select_dungeon_stop_scrollview"

-- EventUtil.SELECT_DUNGEON_RESUME_SCROLLVIEW = "select_dungeon_resume_scrollview"



EventUtil.dispatcher = cc.Director:getInstance():getEventDispatcher()

-- 增加一个事件监听
-- name: 事件名称
-- func: 事件回调
-- fixedPriority: 优化级, 默认为1
function EventUtil.add(name, func, fixedPriority)
    local listener = cc.EventListenerCustom:create(name, func)
    EventUtil.dispatcher:addEventListenerWithFixedPriority(listener, fixedPriority or 1)
    return listener
end

-- 删除一个事件监听
function EventUtil.remove(listener)
    if listener then
        EventUtil.dispatcher:removeEventListener(listener)
    end
end

-- 触发一个事件监听
function EventUtil.dispatch(name, usedata)
    local event = cc.EventCustom:new(name)
    event._usedata = usedata
    EventUtil.dispatcher:dispatchEvent(event)
end

return EventUtil
