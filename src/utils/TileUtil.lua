TileUtil = {}

function TileUtil.arrange(arr,len,cellWidth,cellHight,original)
	local node
	for i=1,#arr do
		local h = math.ceil(i/len)
		local w = (i -1) % len
		node = arr[i]
		node:setPosition(original.x+w*cellWidth,original.y-h*cellHight)
		--print("==========================================================")
		-- print(i .. "====[x]==" ..original.x+(i-1)*cellWidth.. "==[y]=="..original.y-j*cellHight)
		-- print("=original.x==="..original.x.."===(i-1)*cellWidth=="..(i-1)*cellWidth.."=================================================")
		-- print(j .."=original.y==="..original.y.."===j*cellHight=="..j*cellHight.."=================================================")
	end
	-- for i = 1, #arr do
	-- 	node = arr[i]
		
end

return TileUtil
