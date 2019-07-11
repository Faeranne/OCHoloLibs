local component = require('component')
local event = require('event')

function message(_,_,remote,port,_,...)
  local pkt = table.pack(...)
  if port == 1 then
    if pkt[1] == "Config" then
      if pkt[2] == "door_server" then
        modem.send(remote,1,'config_resp','door_client')
      end
    end
  end
  if port == 2 then
    if pkt[1] == "validate" then
      local door = pkt[2]
      local addr = component.get(door)
      if addr then
        if component.proxy(addr).type == "os_doorcontroller" then
          modem.send(2,'validate_response')
        end
      end
    end
    if pkt[1] == "door_open" then
      local door = pkt[2]
      local addr = component.get(door)
      component.proxy(addr).toggle()
    end
  end
end

component.modem.open(1)
component.modem.open(2)

print(event.listen('modem_message',message))
