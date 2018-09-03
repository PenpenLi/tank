local AStarFindUtil = class("AStarFindUtil")

--F = G + H
local DIRECTIONS = {{-1, 0}, {0, -1}, {0, 1}, {1, 0}} --暂时仅支持上下左右移动

local START_POS
local END_POS
local CURRENT_POS

local MAP_LIST      -- 地图数据
local OPEN_LIST     -- 开放节点
local OPEN_MAP      -- key为x_y 节省开销
local CLOSEED_LIST  -- 关闭节点
local CLOSED_MAP    -- key为x_y 节省开销
local PATH_LIST     -- 路径

--utils
local GET_KEY = function(p) return string.format("%d_%d", p.x, p.y) end
local P = function(x, y) 
    local point = {}
    point.x = x
    point.y = y 
    point.last = nil
    point.g = 0
    point.h = 0
    point.f = 0
    point.key = GET_KEY(point)
	return point
end
local MANHTATAN_DIS = function(currPos, targetPos) return ( math.abs(targetPos.x - currPos.x) + math.abs(targetPos.y - currPos.y)) end
local IS_SAME_P = function(p1, p2) return p1.x == p2.x and p1.y == p2.y end
local GET_VALUE_G = function(p) return (p.g + 1) end
local GET_VALUE_H = function(p1, p2) return MANHTATAN_DIS(p1, p2) end
local GET_VALUE_F = function(p) return (p.g + p.h )end
local COMPARE_FUNC = function(p1, p2) return p1.f < p2.f end

function AStarFindUtil:ctor()
end


function AStarFindUtil:init(params)
    TILES = params.tiles
    BODYS = params.bodyPosArray or {}
    START_POS = P(params.startPos.x, params.startPos.y)
    END_POS = P(params.endPos.x, params.endPos.y)

    OPEN_MAP = {}
    OPEN_LIST = {}
    CLOSEED_LIST = {}
    CLOSED_MAP = {}

    OPEN_MAP[START_POS.key] = START_POS
    table.insert(OPEN_LIST, START_POS)
	
    PATH_LIST = self:findPath() or {}
    return PATH_LIST
end

function AStarFindUtil:getNextPoints(point)
    local nextPoints = {}
    for i = 1, #DIRECTIONS do
        local offset = DIRECTIONS[i]
        local nextPoint = P(point.x + offset[1], point.y + offset[2])
        nextPoint.last = point
        local tile = TILES[nextPoint.x.."_"..nextPoint.y]
        if tile then
            nextPoint.g = GET_VALUE_G(point)
            nextPoint.h = GET_VALUE_H(point, END_POS)
            nextPoint.f = GET_VALUE_F(nextPoint)
            table.insert(nextPoints, nextPoint)
        end
    end
    return nextPoints
end

function AStarFindUtil:findPath()
    while (table.nums(OPEN_LIST) > 0) do
		CURRENT_POS = OPEN_LIST[1]
        table.remove(OPEN_LIST, 1)
        OPEN_MAP[CURRENT_POS.key] = nil
        if IS_SAME_P(CURRENT_POS, END_POS) then
            return self:makePath(CURRENT_POS)
        else
            CLOSED_MAP[CURRENT_POS.key] = CURRENT_POS
            local nextPoints = self:getNextPoints(CURRENT_POS)
            for i = 1, #nextPoints do
                local nextPoint = nextPoints[i]
                local tile = TILES[nextPoint.x.."_"..nextPoint.y]
                local body = BODYS[nextPoint.x.."_"..nextPoint.y]
                if (OPEN_MAP[nextPoint.key] == nil) and (CLOSED_MAP[nextPoint.key] == nil) and tile and tile.can_move == 1 and (not body or IS_SAME_P(nextPoint, END_POS)) then
                    OPEN_MAP[nextPoint.key] = nextPoint
                    table.insert(OPEN_LIST, nextPoint)
                end
            end
            table.sort(OPEN_LIST, COMPARE_FUNC)
        end
    end
    return nil
end

function AStarFindUtil:makePath(endPos)
    local path = {}
    local point = endPos
    while point.last ~= nil do
        table.insert(path, 1, P(point.x, point.y))
        point = point.last
    end
    --local startPoint = point
    --table.insert(path, startPoint)
    return path
end

return AStarFindUtil
--endregion