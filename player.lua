Player = DisplayObject:extends()
Player.__name = "Player"

function Player:__init( _x, _y, _width, _height, _vel, _mxvel, _spd )
	Player.super.__init( self, _x, _y, _width, _height, "dynamic", 1 )

	self:userData( "Player" )

	self.vel = _vel and vector( _vel.x or 0, _vel.y or 0 ) or vector( 0, 0 )
	self.maxVel = _mxvel and vector( _mxvel.x or 10, _mxvel.y or 10 ) or vector( 10, 10 )
	self.omaxVel = self.maxVel:clone()
	self.speed = _spd and vector( _spd.x or 1, _spd.y or 1 ) or vector( 1, 1 )
	self.ospeed = self.speed:clone()

	self.jumping = false
	self.doubleJump = false
	self.canDoubleJump = false

	self.powerGroundHit = false

	self.resetCanDoubleJumpTimerHandler = nil
end

local function __resetCanDoubleJump( instance )
	if instance and instance.resetCanDoubleJumpTimerHandler then
		instance.canDoubleJump = false
		instance.resetCanDoubleJumpTimerHandler = nil
	end
end

function Player:resetCanDoubleJump()
	if not self.canDoubleJump and not self.resetCanDoubleJumpTimerHandler then
		self.canDoubleJump = true
		self.resetCanDoubleJumpTimerHandler = Timer.add( 0.5, function() __resetCanDoubleJump( self ) end )
	end
end
