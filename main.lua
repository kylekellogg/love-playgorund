require "libs/Beetle"
require "player"

function love.load()
	beetle.load()
	beetle.setKey( "`" )

	player = Player:new()

	beetle.add( "Player X", player.x )
	beetle.add( "Player Y", player.y )
	beetle.add( "Player Velocity", player.vel )

	input = {
		up = false,
		down = false,
		left = false,
		right = false
	}

	love.graphics.setBackgroundColor( 255, 255, 255 )
end

function love.update( dt )
	if input.left then
		player.vel.x = player.vel.x - player.speed.x
	end
	if input.right then
		player.vel.x = player.vel.x + player.speed.x
	end

	if input.up then
		if player.jumpCounter < player.maxJumpCounter then
			player.vel.y = math.max( player.vel.y + ((player.maxJumpCounter - player.jumpCounter) * -(player.speed.y * math.pi)), -player.maxVel.y )
			player.jumpCounter = player.jumpCounter + 1
		else
			player.jumpCounter = 0
			input.up = false
		end
	end
	if input.down then
		player.vel.y = player.vel.y + player.speed.y
	end

	if not input.up and player.y < love.graphics.getHeight() - (player.height * 0.5) then
		player.vel.x = math.max( math.min( player.vel.x * 0.94, player.maxVel.x ), -player.maxVel.x )
	else
		player.vel.x = math.max( math.min( player.vel.x * 0.92, player.maxVel.x ), -player.maxVel.x )
	end
	player.vel.y = math.max( math.min( player.vel.y + 0.81, player.maxVel.y ), -player.maxVel.y )

	player.x = player.x + player.vel.x
	player.y = player.y + player.vel.y

	if player.x > love.graphics.getWidth() - (player.width * 0.5) then
		player.x = love.graphics.getWidth() - (player.width * 0.5)
		player.vel.x = 0
	elseif player.x < player.width * 0.5 then
		player.x = player.width * 0.5
		player.vel.x = 0
	end

	if player.y > love.graphics.getHeight() - (player.height * 0.5) then
		player.y = love.graphics.getHeight() - (player.height * 0.5)
		player.doubleJump = false
	elseif player.y < player.height * 0.5 then
		player.y = player.height * 0.5
		player.vel.y = 0
	end

	beetle.update( "Player X", player.x )
	beetle.update( "Player Y", player.y )
	beetle.update( "Player Velocity", player.vel )
end

function love.draw()
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.rectangle( "fill", player.x - (player.width * 0.5), player.y - (player.height * 0.5), player.width, player.height )

	beetle.draw()
end

function love.keypressed( key )
	if key == "up" then
		if player.y >= (love.graphics.getHeight() - (player.height * 0.5)) then
			input.up = true
		elseif not player.doubleJump then
			player.doubleJump = true
			input.up = true
		end
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

	beetle.key( key )
end

function map( val, omin, omax, nmin, nmax )
	return nmin + (nmax - nmin) * ( (val - omin) / (omax - omin) )
end
