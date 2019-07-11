local event = require('event')
local component = require('component')
local modem = component.modem

local comp = {}
comp.doors = {}
comp.widgets = {}

function comp.injectGLS(gls)
  comp.gls = gls
end

function comp.init()
  modem.broadcast(1,'Config','door_server')
end

function comp.load(conf)
	comp.doors = conf
end

function comp.addDoor(id,name)
  for _,client in pairs(comp.clients) do
    modem.send(client,2,'validate',id)
  end
  local valid,_,remote = modem.pull(4,'modem_message',nil,nil,2,nil,'validate_response')
  if not valid then
    error("Couldn't find door on network")
  end
  function cb(user,_,_,_,x,y,z)
    comp.doors[name] = {x=x,y=y,z=z,id=id,client=remote,users={}}
    comp.doors[name].users[user] = -1
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
        modem.send(pos.client,2,'door_open',pos.id)
      end
    end
  end
end

return comp
