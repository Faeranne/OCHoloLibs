local comp = {}
comp.widgets = {}

function comp.injectGLS(gls)
  comp.gls = gls
end

function comp.init()

end

function comp.load(conf)
  for id,sign in pairs(conf.signs) do
    comp.widgets[id] = comp.gls.terminal.addText3D()
    comp.widgets[id].addTranslation(sign.x,sign.y,sign.z)
    comp.widgets[id].setText(sign.text)
    comp.widgets[id].setFaceWidgetToPlayer(false)
  end
end

function comp.addSign(text)
  local id = #comp.widgets+1
  comp.widgets[id] = comp.gls.terminal.addText3D()
  function cb(user,_,_,_,x,y,z,side)
    comp.widgets[id].addTranslation(x,y,z)
    comp.widgets[id].setText(text)
    comp.gls.save()
  end
  comp.widgets[id].setFaceWidgetToPlayer(false)
  comp.gls.secureQueue = cb
  return id
end

function comp.save()
  local conf = {}
  for id,widget in comp.widgets do
    conf[id] = widget.modifiers()[1].get()
    conf[id].text = widget.getText()
  end
  return conf
end

function comp.removeSign(id)
  table.remove(comp.widgets,id).removeWidget()
  comp.gls.save()
end

return comp
