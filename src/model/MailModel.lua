local MailModel = qy.class("MailModel", qy.tank.model.BaseModel)

function MailModel:init(mailList)
	self.mailList = {}
	self.mailList =mailList
end
function MailModel:setMailInfo(mailInfo)
	self.mailNum = 0
	if mailInfo.mail then
		self.mailNum = mailInfo.mail
	end
end

function MailModel:getMailNum()
	return self.mailNum
end
function MailModel:updateMail(id,status)
	for k, v in pairs(self.mailList) do
		if self.mailList[k]._id == id then
			self.mailList[k].status = status
			break
		end
	end
end

function MailModel:getMailList()
	local tastArray = {}
	for k, v in pairs(self.mailList) do
		table.insert(tastArray,v)
	end
	table.sort(tastArray, function(a, b)
		  local r
		  local al = tonumber(a.send_time)
		  local bl = tonumber(b.send_time)
		  r = bl < al
		  return r
	end)
	return tastArray
end


return MailModel