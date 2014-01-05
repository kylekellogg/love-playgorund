class = require "30log"
Timer = require "libs/hump/timer"
vector = require "libs/hump/vector"
require "libs/Beetle"
require "displayobject"
require "player"

function love.load()
	beetle.load()
	beetle.setKey( "`" )

	love.physics.setMeter( 64 )
	world = love.physics.newWorld( 0, 9.81 * 64, true )
	local g = {}
	g.x, g.y = world:getGravity()

	player = Player:new( love.graphics.getWidth() * 0.5 - 25, love.graphics.getHeight() * 0.5 - 25, 50, 50 ) -- just Player() works as well
	player.maxVel = vector( 150, -g.y )

	local boundsSize = 10
	bounds = {
		left = -boundsSize,
		right = love.graphics.getWidth(),
		top = -boundsSize,
		bottom = love.graphics.getHeight() - player.height,
		size = boundsSize
	}

	worldObjects = {
		floor	= DisplayObject:new( bounds.left, bounds.bottom, bounds.right - bounds.left, bounds.size ),
		ceiling	= DisplayObject:new( bounds.left, -bounds.size, bounds.right - bounds.left, bounds.size ),
		left	= DisplayObject:new( bounds.left, bounds.top, bounds.size, bounds.bottom - bounds.top ),
		right	= DisplayObject:new( bounds.right, bounds.top, bounds.size, bounds.bottom - bounds.top )
	}

	beetle.add( "Player X", player.body:getX() )
	beetle.add( "Player Y", player.body:getY() )
	player.vel = vector( player.body:getLinearVelocity() )
	beetle.add( "Player Velocity", player.vel )

	input = {
		up = false,
		down = false,
		left = false,
		right = false
	}

	sfx = {
		hit = {
			ground		= love.audio.newSource( "assets/sounds/HitGround.wav", "static" ),
			groundHard	= love.audio.newSource( "assets/sounds/HitGroundHard.wav", "static" ),
			wall		= love.audio.newSource( "assets/sounds/HitWall.wav", "static" )
		}
	}

	screenshake = false

	love.graphics.setBackgroundColor( 255, 255, 255 )
end

function love.update( dt )
	local g = {}
	g.x, g.y = world:getGravity()

	if input.left then
		player.body:applyForce( -150, 0 )
	end
	if input.right then
		player.body:applyForce( 150, 0 )
	end
	if input.up then
		if not player.jumping then
			player.jumping = true
			player.body:applyLinearImpulse( 0, -g.y * 0.33 )
		end
	end
	if input.down then
		if player:x() < bounds.bottom - player.height * 1.5 then
			player.body:applyLinearImpulse( 0, g.y * 0.33 )
			player.powerGroundHit = true
		else
			player.body:applyForce( 0, 100 )
		end
	end

	-- Limit to maximum velocity
	-- Only limit y on negative, leave positive alone for slam
	player.vel = vector( player.body:getLinearVelocity() )
	player.vel.x = math.max( math.min( player.vel.x, player.maxVel.x ), -player.maxVel.x )
	player.vel.y = math.max( player.vel.y, player.maxVel.y )
	player.body:setLinearVelocity( player.vel:unpack() )

	player.wasHittingWall = player.wasHittingWall and (player:x() <= bounds.left or player:x() >= bounds.right)
	player.wasHittingGround = player.wasHittingGround and player:y() >= bounds.bottom

	if player:x() >= bounds.right then
		if input.right then
			player:resetCanDoubleJump()
		end
		if not player.wasHittingWall then
			player.wasHittingWall = true
			if sfx.hit.wall then
				sfx.hit.wall:play()
			end
		end
	end
	if player:x() <= bounds.left then
		if input.left then
			player:resetCanDoubleJump()
		end
		if not player.wasHittingWall then
			player.wasHittingWall = true
			if sfx.hit.wall then
				sfx.hit.wall:play()
			end
		end
	end

	beetle.update( "Player X", player:x() )
	beetle.update( "Player Y", player:y() )
	beetle.update( "Player Velocity", player.vel )

	Timer.update( dt )
	world:update( dt )
end

function love.draw()
	if screenshake then
		love.graphics.push()
		local shakeAmt = math.random( -10, 10 )
		love.graphics.translate( shakeAmt, shakeAmt )
	end
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.polygon( "fill", player.body:getWorldPoints( player.shape:getPoints() ) )

	love.graphics.setColor( 86, 0, 0 )
	love.graphics.polygon( "fill", worldObjects.floor.body:getWorldPoints( worldObjects.floor.shape:getPoints() ) )
	love.graphics.polygon( "fill", worldObjects.ceiling.body:getWorldPoints( worldObjects.ceiling.shape:getPoints() ) )
	love.graphics.polygon( "fill", worldObjects.left.body:getWorldPoints( worldObjects.left.shape:getPoints() ) )
	love.graphics.polygon( "fill", worldObjects.right.body:getWorldPoints( worldObjects.right.shape:getPoints() ) )
	if screenshake then
		love.graphics.pop()
	end

	beetle.draw()
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

	beetle.key( key )
end

function map( val, omin, omax, nmin, nmax )
	return nmin + (nmax - nmin) * ( (val - omin) / (omax - omin) )
end
