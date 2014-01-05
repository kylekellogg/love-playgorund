DisplayObject = class()
DisplayObject.__name = "DisplayObject"

function DisplayObject:__init( _x, _y, _width, _height, _type, _mass )
	self.width = _width or 50
	self.height = _height or 50

	self.body = love.physics.newBody( world, self.width * 0.5, self.height * 0.5, _type or "static" )
	self.shape = love.physics.newRectangleShape( _x or love.graphics.getWidth() * 0.5, _y or love.graphics.getHeight() * 0.5, self.width, self.height, 0 )
	self.fixture = love.physics.newFixture( self.body, self.shape, _mass or 0 )
end

function DisplayObject:x( val )
	local x, y = self.body:getPosition()
	if val then
		x = tonumber( val )
		self.body:setPosition( x, y )
	end
	return x
end

function DisplayObject:y( val )
	local x, y = self.body:getPosition()
	if val then
		y = tonumber( val )
		self.body:setPosition( x, y )
	end
	return y
end
