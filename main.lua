class = require "30log"
Timer = require "libs/hump/timer"
vector = require "libs/hump/vector"
Camera = require "libs/hump/camera"
require "libs/Beetle"
require "displayobject"
require "player"

function love.load()
	beetle.load()
	beetle.setKey( "`" )

	center = vector( love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5 )

	love.physics.setMeter( 64 )
	gravity = vector( 0, 9.81 * 64 )
	world = love.physics.newWorld( gravity.x, gravity.y, true )
	world:setCallbacks( beginContact, endContact, preSolve, postSolve )

	persistingContacts = {
		["Floor"] = 0,
		["Ceiling"] = 0,
		["Wall Left"] = 0,
		["Wall Right"] = 0
	}

	player = Player:new( center.x - 25, center.y - 25, 50, 50 ) -- just Player() works as well
	player.maxVel = vector( 500, -gravity.y )

	cam = Camera( player:x(), player:y() )

	local boundsSize = 10
	bounds = {
		left = -boundsSize,
		right = love.graphics.getWidth() * 3,
		top = -boundsSize,
		bottom = love.graphics.getHeight() - player.height,
		size = boundsSize
	}

	local w = bounds.right - bounds.left
	local h = bounds.bottom - bounds.top
	worldObjects = {
		floor	= DisplayObject:new( bounds.left, bounds.bottom, w + bounds.size, bounds.size ),
		ceiling	= DisplayObject:new( bounds.left, bounds.top, w + bounds.size, bounds.size ),
		left	= DisplayObject:new( bounds.left, bounds.top + bounds.size, bounds.size, h ),
		right	= DisplayObject:new( bounds.right, bounds.top + bounds.size, bounds.size, h )
	}

	worldObjects.floor:userData( "Floor" )
	worldObjects.ceiling:userData( "Ceiling" )
	worldObjects.left:userData( "Wall Left" )
	worldObjects.right:userData( "Wall Right" )

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
	if input.left then
		player.body:applyForce( -player.maxVel.x, 0 )
	end
	if input.right then
		player.body:applyForce( player.maxVel.x, 0 )
	end
	if input.up then
		if not player.jumping then
			player.jumping = true
			input.up = false
			player.body:applyLinearImpulse( 0, -gravity.y * 0.33 )
		elseif player.canDoubleJump then
			player.canDoubleJump = false
			player.doubleJump = true
			player.body:applyLinearImpulse( 0, -gravity.y * 0.33 )
			player.canPowerGroundHit = true
		end
	end
	if input.down then
		if player.canPowerGroundHit and player:y() < bounds.bottom - player.height * 5 then
			player.body:applyLinearImpulse( 0, gravity.y * 1.5 )
			player.powerGroundHit = true
			input.down = false
			player.canPowerGroundHit = false
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

	beetle.update( "Player X", player:x() )
	beetle.update( "Player Y", player:y() )
	beetle.update( "Player Velocity", player.vel )

	--	e.g. 800 x 600
	-- 800 - 400 = 400
	-- 800 - 100 = 700
	-- 800 - 
	cam:lookAt( map( player:x(), bounds.left, bounds.right, center.x, bounds.right * 0.65 ), map( player:y(), bounds.top, bounds.bottom - player.width, center.y - player.width, center.y * 1.05 ) )--math.max( lerp( cam.x, player:x(), dt ), 0 ), math.max( lerp( cam.y, player:y(), dt ), 0 ) )
	Timer.update( dt )
	world:update( dt )
end

function love.draw()
	cam:attach()
	-- if we've done a powerful ground hit, shake the screen by a randomized amount
	if screenshake then
		love.graphics.push()
		local shakeAmt = math.random( -5, 5 )
		love.graphics.translate( shakeAmt, shakeAmt )
	end

	love.graphics.setColor( player.color.r, player.color.g, player.color.b, player.color.a )
	love.graphics.polygon( "fill", player.body:getWorldPoints( player.shape:getPoints() ) )

	love.graphics.setColor( 86, 0, 0 )
	love.graphics.polygon( "fill", worldObjects.floor.body:getWorldPoints( worldObjects.floor.shape:getPoints() ) )
	love.graphics.polygon( "fill", worldObjects.ceiling.body:getWorldPoints( worldObjects.ceiling.shape:getPoints() ) )
	love.graphics.polygon( "fill", worldObjects.left.body:getWorldPoints( worldObjects.left.shape:getPoints() ) )
	love.graphics.polygon( "fill", worldObjects.right.body:getWorldPoints( worldObjects.right.shape:getPoints() ) )
	if screenshake then
		love.graphics.pop()
	end
	cam:detach()

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

function lerp( a, b, t )
	return a+(b-a)*t
end

function beginContact( a, b, coll )
	-- nothing
end

function endContact( a, b, coll )
	local aud, bud = a:getUserData(), b:getUserData()
	persistingContacts[ aud == "Player" and bud or aud ] = 0
end

function preSolve( a, b, coll )
	local aud, bud = a:getUserData(), b:getUserData()
	local ud = aud == "Player" and bud or aud
	local n = persistingContacts[ ud ]

	persistingContacts[ ud ] = n + 1

	-- Only on the first hit
	if n == 0 then
		if ud == "Floor" then
			if player.powerGroundHit then
				screenshake = true
				Timer.add( 0.5, function()
					screenshake = false
					player.powerGroundHit = false
					-- Jump(s) reset will happen on next hit due to bounce
				end )
				player.color.r = 255
				Timer.tween( 0.5, player.color, {r=0,g=0,b=0,a=255}, "elastic" )
				if sfx.hit.groundHard then
					sfx.hit.groundHard:play()
				elseif sfx.hit.ground then
					sfx.hit.ground:play()
				end
			else
				if sfx.hit.ground then
					sfx.hit.ground:play()
				end

				player.jumping = false
				player.doubleJump = false
				player.canDoubleJump = false
			end
		elseif string.find( ud, "Wall" ) then
			player.canDoubleJump = not player.doubleJump and true
			if sfx.hit.wall then
				sfx.hit.wall:play()
			end
		elseif ud == "Ceiling" then
			if sfx.hit.wall then
				sfx.hit.wall:play()
			end
		end
	end
end

function postSolve( a, b, coll )
	-- nothing
end
