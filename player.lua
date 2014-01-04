local class = require "30log"
local vector = require "libs/hump/vector"
local Timer = require "libs/hump/timer"

Player = class()
Player.__name = "Player"

function Player:__init( _x, _y, _width, _height, _vel, _mxvel, _spd )
	self.vel = _vel and vector( _vel.x or 0, _vel.y or 0 ) or vector( 0, 0 )
	self.maxVel = _mxvel and vector( _mxvel.x or 10, _mxvel.y or 10 ) or vector( 10, 10 )
	self.speed = _spd and vector( _spd.x or 1, _spd.y or 1 ) or vector( 1, 1 )
	self.ospeed = self.speed:clone()

	self.x = _x or love.graphics.getWidth() * 0.5
	self.y = _y or love.graphics.getHeight() * 0.5

	self.width = _width or 50
	self.height = _height or 50

	self.jumpCounter = 0
	self.maxJumpCounter = 10
	self.doubleJump = false
	self.canDoubleJump = false

	self.resetCanDoubleJumpTimerHandler = nil
end

local function __resetCanDoubleJump( instance )
	if instance and instance.resetCanDoubleJumpTimerHandler then
		print( 'reset!' )
		instance.canDoubleJump = false
		instance.resetCanDoubleJumpTimerHandler = nil
	end
end

function Player:resetCanDoubleJump()
	if not self.canDoubleJump and not self.resetCanDoubleJumpTimerHandler then
		print( 'waiting to reset...' )
		self.canDoubleJump = true
		self.resetCanDoubleJumpTimerHandler = Timer.add( 0.5, function() __resetCanDoubleJump( self ) end )
	end
end
