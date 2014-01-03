

function love.load()
	player = {
		x = 25,
		y = 25,
		width = 50,
		height = 50,
		vel = {
			x = 0,
			y = 0
		}
	}

	input = {
		up = false,
		down = false,
		left = false,
		right = false
	}
end

function love.draw()
	if input.up then
		player.vel.y = math.max( player.y - player.height, player.height * 0.5 )
	end
	if input.down then
		player.y = math.min( player.y + player.height, love.graphics.getHeight() - (player.height * 0.5) )
	end
	if input.left then
		player.x = math.max( player.x - player.width, player.width * 0.5 )
	end
	if input.right then
		player.x = math.min( player.x + player.width, love.graphics.getWidth() - (player.width * 0.5) )
	end

	love.graphics.rectangle( 'fill', player.x - (player.width * 0.5), player.y - (player.height * 0.5), player.width, player.height )
end

function love.keypressed( key )
	if key == "up" then
		input.up = true
	end
	if key == "down" then
		input.down = true
	end
	if key == "left" then
		input.left = true
	end
	if key == "right" then
		input.right = true
	end
end

function love.keyreleased( key )
	if key == "up" then
		input.up = false
	end
	if key == "down" then
		input.down = false
	end
	if key == "left" then
		input.left = false
	end
	if key == "right" then
		input.right = false
	end
end
