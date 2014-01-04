local class = require "libs/middleclass"
local vector = require "libs/hump/vector"

Player = class( "Player" )

function Player:initialize( _x, _y, _width, _height, _vel, _mxvel, _spd )
	self.vel = _vel and vector( _vel.x or 0, _vel.y or 0 ) or vector( 0, 0 )
	self.maxVel = _mxvel and vector( _mxvel.x or 10, _mxvel.y or 10 ) or vector( 10, 10 )
	self.speed = _spd and vector( _spd.x or 1, _spd.y or 1 ) or vector( 1, 1 )

	self.x = _x or love.graphics.getWidth() * 0.5
	self.y = _y or love.graphics.getHeight() * 0.5

	self.width = _width or 50
	self.height = _height or 50

	self.jumpCounter = 0
	self.maxJumpCounter = 10
	self.doubleJump = false
end

function Player:__tostring()
	return "Player"
end
