--[[
Beetle Debug Library V 0.0.2
License : Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
http://creativecommons.org/licenses/by-nc-sa/3.0/
Programmed by substitute541
]]--

beetle = {}

local function indexOf( tbl, key )
	tbl = tbl or {}

	if key then
		if #tbl > 0 then
			for i, v in ipairs( tbl ) do
				if tostring( v ) == tostring( key ) then
					return i
				end
			end
		end
	end

	return nil
end

function beetle.load()
	dbg = {}
	dbg.x = 5
	dbg.y = 5
	dbg.names = {}
	dbg.value = {}
	dbg.font = love.graphics.newFont(14)
	dbg.color = {255, 255, 255, 255}
	dbg.show = false
	dbg.key = "d"
end

function beetle.key(key)
	if key == dbg.key and dbg.show then
		beetle.hide()
	elseif key == dbg.key and dbg.show == false then
		beetle.show()
	end
end

function beetle.setKey(key)
	dbg.key = key
end

function beetle.show()
	dbg.show = true
end

function beetle.hide()
	dbg.show = false
end

function beetle.getState()
	return dbg.show
end

function beetle.add(name, contents)
	table.insert(dbg.names, tostring(name))
	table.insert(dbg.value, tostring(contents))
end

function beetle.remove(name)
	local idx = indexOf( dbg.names, name )

	if idx then
		table.remove(dbg.name, idx)
		table.remove(dbg.value, idx)
	end
end

function beetle.update(name, value)
	local idx = indexOf( dbg.names, name ) or "nil"

	if idx then
		dbg.value[idx] = tostring(value)
	end
end

function beetle.draw()
	if dbg.show then
		love.graphics.setColor( 0, 0, 0, 87 )
		love.graphics.rectangle( "fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight() )

		love.graphics.setFont(dbg.font)
		love.graphics.setColor(dbg.color[3], dbg.color[2], dbg.color[1], 255)
		love.graphics.print("Beetle Debug Screen :", dbg.x, dbg.y)
		love.graphics.setColor(dbg.color)
		
		for i, v in ipairs(dbg.names) do
			love.graphics.print(v .. " : " .. dbg.value[i], dbg.x, dbg.y+17*i)
		end
		love.graphics.setColor(255, 255, 255, 255)
	end
end