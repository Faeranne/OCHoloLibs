local component = require('component')
local event = require('event')
local term = require('term')
local config = require('config')

local gls = {}

gls.screenWidth,gls.screenHeight = 840,496

gls.components = {}
gls.widgets = {}
gls.queue = {}
gls.admins = {}

gls.configs = {}

function gls.equip(_,id,user)
  term.write("User "..user.." enabled glasses")
end

function gls.addAdmin(user)
  gls.admins[user]=true
end

function gls.removeAdmin(user)
  gls.admins[user]=nil
end

function gls.interactOverlay(_,id,user,x,y,button)
  for name,comp in pairs(gls.components) do
    if comp.overlayInteract then
      comp.overlayInteract(user,x,y,button)
    end
  end
end

function gls.addComponent(name)
  local tab = require('holo-'..name)
  if not tab then
    return
  end
  tab.injectGLS(gls)
  tab.init()
  if gls.configs[name] then
    tab.load(gls.configs[name])
  end
  gls.components[name] = tab
end

function gls.interactWorld(ev,id,user,posX,posY,posZ,lookX,lookY,lookZ,height,blockX,blockY,blockZ,size,rot,pitch,facing)
  -- process secured queue requests first.
  if gls.secureQueue then
    local allowed = false
    for name,_ in pairs(gls.admins) do
      print(name)
      print(user)
      if name == user then
        allowed = true
      end
    end
    if allowed then
      term.write("Processing secure interact\n")
      gls.secureQueue(user,posX,posY,posZ,blockX,blockY,blockZ,side)
      term.write("Done")
      gls.secureQueue = nil
      return
    end
  end
  -- process commands requested by user actions
  if gls.queue[user] then
    gls.queue[user](posX,posY,posZ,blockX,blockY,blockZ,side) 
    gls.queue[user] = nil
  else
    -- pass interaction to each component for a chance to do something.
    for name,comp in pairs(gls.components) do
      if comp.worldInteract then
        comp.worldInteract(user,posX,posY,posZ,blockX,blockY,blockZ,side)
      end
    end
  end
end

function gls.resize(_,id,user,width,height,scale)
  gls.screenWidth = width
  gls.screenHeight = height
end

function gls.connectTerminal(id)
  if not component.list()[component.get(id)]=='glasses'  then
    error(id.." is not a glasses terminal.")
  end
  gls.terminal = component.proxy(component.get(id))
  gls.terminal.removeAll()
end

function gls.save()
  for name,comp in pairs(gls.components) do
    gls.configs[name] = gls.components[name].save()
  end
  local conf = {}
  conf.admins = gls.admins
  conf.term = gls.terminal.address
  conf.components = gls.configs
  conf.version = 1
  config.save(conf,'/etc/holo.conf')
end

function gls.load()
  local conf = config.load('/etc/holo.conf')
  if not conf.version then
    print("Old save version.")
    gls.configs = conf
    return
  end
  if conf.version > 1 then
    print('Config version is newer than library.  Some configs may be lost/broken.')
  end
  gls.configs = conf.components
  gls.admins = conf.admins
  gls.terminal = component.proxy(conf.term)
  gls.terminal.removeAll()
  for name,_ in pairs(gls.configs) do
    local comp = gls.addComponent(name)
  end
end

event.listen('interact_world_block_right',gls.interactWorld)
event.listen('interact_overlay',gls.interactOverlay)
event.listen('glasses_on',gls.equip)

return gls
