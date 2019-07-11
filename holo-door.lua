local event = require('event')
local component = require('component')

local comp = {}
comp.doors = {}
comp.widgets = {}

function comp.injectGLS(gls)
  comp.gls = gls
end

function comp.init()

end

function comp.load(conf)
	comp.doors = conf
end

function comp.addDoor(id,name)
  if component.list('door')[component.get(id)]~='os_doorcontroller' then
    error("No door found with id "..id)
    return
  end
  function cb(user,_,_,_,x,y,z)
    comp.doors[id] = {x=x,y=y,z=z,name=name,users={}}
    comp.doors[id].users[user] = -1
	computer.push('door_added',id,user)
  end
  comp.gls.secureQueue = cb
end

function comp.addUser(id,user)
  if comp.doors[id] then
    comp.doors[id].users[user] = 1
  end
end

function comp.removeUser(id,user)
  if comp.doors[id] then
    comp.doors[id].users[user] = nil
  end
end

function comp.save()
  return comp.doors
end

function comp.worldInteract(user,_,_,_,x,y,z)
  for id,pos in pairs(comp.doors) do
    if pos.x == x and pos.y == y and pos.z == z then
      if pos.users[user] then
        component.proxy(id).toggle()
      end
    end
  end
end

return comp
