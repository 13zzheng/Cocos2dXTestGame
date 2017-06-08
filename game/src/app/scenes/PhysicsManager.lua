--
-- Author: Your Name
-- Date: 2017-06-07 15:46:15
--
local world = nil

local PhysicsManager = class("PhysicsManager", function()
	return CCPhysicsWorld:create(0, 0)
end)

CollisionType = {}
CollisionType.kCollisionPlayer = 1;
CollisionType.kCollisionEnemy = 2;


function PhysicsManager:getInstance()
	if world == nil or tolua.isnull(world) then
		world = PhysicsManager.new()
	end

	return world
end


function PhysicsManager:purgeInstance()
    if world ~= nil then
        world:removeAllCollisionListeners()
        world:removeAllBodies(true)
        world = nil
    end
end

return PhysicsManager