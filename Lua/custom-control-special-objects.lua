function handlespecial(unitid,type,data)
	local unit = mmf.newObject(unitid)

	if (type == "controls") then
		local subtype = data[1]

		local x = Xoffset + unit.values[XPOS] * tilesize * spritedata.values[TILEMULT] + tilesize * spritedata.values[TILEMULT] * 0.5
		local y = Yoffset + unit.values[YPOS] * tilesize * spritedata.values[TILEMULT] + tilesize * spritedata.values[TILEMULT] * 0.5
		if subtype:sub(1,1) == "!" then
			y = Yoffset + (unit.values[YPOS] - 1) * tilesize * spritedata.values[TILEMULT] + tilesize * spritedata.values[TILEMULT] * 0.5
			writetext(subtype:sub(2),0,x,y + tilesize * spritedata.values[TILEMULT],"InGame",true,1,true)
		elseif subtype:sub(1,1) == "?" then
			local icon = mmf.newObject(MF_specialcreate("ControlIcon"))
			local key = string.upper(subtype:sub(2))
			icon.animSet = 5
			icon.x = x
			icon.y = y
			icon.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
			icon.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
			for i, j in pairs(binds["keyboard"]) do
				if string.upper(j) == key then
					icon.animFrame = i
					break
				end
			end
		else
			local gamepad = MF_profilefound()
			local gamepad_ = false
			if (gamepad ~= nil) then
			gamepad_ = true
			end
		
			if (generaldata2.values[BUTTONPROMPTTYPE] == 0) then
				gamepad_ = false
				gamepad = nil
			end
		
			if (gamepad == nil) or ((gamepad ~= nil) and (subtype ~= "right") and (subtype ~= "left") and (subtype ~= "up") and (subtype ~= "right2") and (subtype ~= "left2") and (subtype ~= "up2")) then
				local xtile = unit.values[XPOS]
				local ytile = unit.values[YPOS]
			
				local finaltype = subtype
			
				if (gamepad == nil) or ((gamepad ~= nil) and (subtype ~= "down") and (subtype ~= "down2")) then
					createcontrolicon(finaltype,gamepad_,x,y,"InGame",nil,1,{xtile,ytile})
				elseif (gamepad ~= nil) and ((subtype == "down") or (subtype == "down2")) then
					if (subtype == "down2") then
						finaltype = "move2"
					else
						finaltype = "move"
					end
					createcontrolicon(finaltype,gamepad_,x,y,"InGame",nil,1,{xtile,ytile})
				end
				
				if (subtype ~= "right") and (subtype ~= "left") and (subtype ~= "up") and (subtype ~= "right2") and (subtype ~= "left2") and (subtype ~= "up2") then
					if (subtype == "down") and (gamepad == nil) then
						finaltype = "move"
					end
					
					if (subtype == "down2") and (gamepad == nil) then
						finaltype = "move2"
					end
				
					writetext(langtext(finaltype),0,x,y + tilesize * spritedata.values[TILEMULT] + 2,"InGame",true,1,true)
				end
			end
		end
	elseif (type == "level") then
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local things = findallhere(x,y)
		
		local levelfile = data[1]
			
		MF_setfile("level","Data/Worlds/" .. generaldata.strings[WORLD] .. "/" .. levelfile .. ".ld")
		local levelname = MF_read("level","general","name")
		local leveltype = tonumber(MF_read("level","general","leveltype"))
		MF_setfile("level","Data/Worlds/" .. generaldata.strings[WORLD] .. "/" .. generaldata.strings[CURRLEVEL] .. ".ld")
		
		local leveltype_bool = false
		if (leveltype == 1) then
			for i,v in ipairs(leveltree) do
				if (v ~= generaldata.strings[LEVELFILE]) and (v == levelfile) then
					leveltype_bool = true
				end
			end
		end
		
		unit.flags[MAPLEVEL] = leveltype_bool
		
		for i,v in ipairs(things) do
			local level = mmf.newObject(v)
			
			if (level.className ~= "level") then
				level.strings[U_LEVELFILE] = levelfile
				level.strings[U_LEVELNAME] = levelname
				level.values[VISUALLEVEL] = tonumber(data[3])
				level.values[VISUALSTYLE] = tonumber(data[2])
				level.flags[MAPLEVEL] = leveltype_bool
				
				if (string.len(data[4]) > 0) then
					level.values[COMPLETED] = tonumber(data[4])
				end
				
				if (string.len(data[5]) > 0) and (string.len(data[6]) > 0) then
					level.strings[COLOUR] = data[5] .. "," .. data[6]
				end
				
				if (string.len(data[7]) > 0) and (string.len(data[8]) > 0) then
					level.strings[CLEARCOLOUR] = data[7] .. "," .. data[8]
				end
			end
		end
	elseif (type == "flower") then
		local flowerid = MF_specialcreate("Flower_center")
		local flower = mmf.newObject(flowerid)
		
		flower.strings[2] = "flower"
		flower.values[10] = 2
		flower.values[6] = 1
		flower.values[8] = tonumber(data[3])
		flower.x = unit.x
		flower.y = unit.y
		
		flower.strings[1] = data[1] .. ", " .. data[2]
	elseif (type == "art") then
		local artid = MF_specialcreate("Secret_art")
		local art = mmf.newObject(artid)
		
		art.x = unit.x + tilesize * 0.5
		art.y = unit.y - tilesize * 0.5
	elseif (type == "sign") then
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local things = findallhere(x,y)
		
		local fulltext = data[1] .. "=" .. data[2] .. "=" .. data[3]
		
		for i,v in ipairs(things) do
			local vunit = mmf.newObject(v)
			
			vunit.strings[UNITSIGNTEXT] = fulltext
		end
	elseif (type == "sign_lang") then
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local things = findallhere(x,y)
		
		local fulltext = langtext(data[1],true,true) .. "=" .. langtext(data[2],true,true) .. "=" .. langtext(data[3],true,true)
		
		for i,v in ipairs(things) do
			local vunit = mmf.newObject(v)
			
			vunit.strings[UNITSIGNTEXT] = fulltext
		end
	end
end