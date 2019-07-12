local event = require('event')

local menu = {}

menu.elements = {}

function menu.init()
  
end

function menu.injectGLS(gls)
  menu.gls=gls
end

function menu.overlayInteract(user,x,y,button)
  for i,element in ipairs(menu.elements) do
    if element:inElement(x,y) then
      element:onClick(user,x,y,button)
    end
  end
end

function menu.redraw()
  for i,element in ipairs(menu.elements) do
    element:redraw()
  end
end

function menu.addElement(ele)
  local t = menu.elements
  ele:createWidget(menu.gls)
  t[#t+1] = ele
  return menu
end

local elements = {}

function elements.dropdown(x,w)
  local ele = {}
  ele.conf = {x=x,w=w}
  ele.conf.bColor = table.pack(.5,.5,.5,1)
  ele.conf.fColor = table.pack(1,1,1,1)
  ele.conf.tColor = table.pack(0,0,0,1)
  ele.options = {}

  function ele.createWidget(self,gls)
    if self.back then
      self:redraw()
    else
      self.back = {}
      self.back.widget = gls.terminal.addBox2D()
      self.back.translate = self.back.widget.addTranslation(self.conf.x,0,0)
      self.back.color1 = self.back.widget.addColor(table.unpack(self.conf.bColor))
      self.back.color2 = self.back.widget.addColor(table.unpack(self.conf.bColor))
      self.back.widget.setSize(self.conf.w,#self.options*10)
      self.selected = {}
      self.selected.widget = gls.terminal.addBox2D()
      self.selected.translate = self.selected.widget.addTranslation(self.conf.x,-10,0)
      self.selected.color1 = self.back.widget.addColor(table.unpack(self.conf.fColor))
      self.selected.color2 = self.back.widget.addColor(table.unpack(self.conf.fColor))
      self.selected.widget.setSize(self.conf.w,10)
      for i,option in ipairs(self.options) do
        if option.selected then
          self.selected.widget.modifiers()[self.selected.translate].set(self.conf.x,(i-1)*10)
        end
        option.widget = gls.terminal.addText2D()
        option.translate = option.widget.addTranslation(self.conf.x+3,((i-1)*10)+1)
        option.color = option.widget.addColor(table.unpack(self.conf.tColor))
        option.setText(option.text)
        self.options[i] = option
      end
    end
    return self
  end

  function ele.redraw(self)
    if not self.back then
      error("attempting to redraw before creating widgets")
    end
    self.back.widget.setSize(self.conf.w,#self.options*10)
    self.back.widget.modifiers()[self.back.translate].set(self.conf.x,0,0)
    self.back.widget.modifiers()[self.back.color1].set(table.unpack(self.conf.bColor))
    self.back.widget.modifiers()[self.back.color2].set(table.unpack(self.conf.bColor))
    self.selected.widget.setSize(self.conf.w,10)
    self.selected.widget.modifiers()[self.selected.translate].set(self.conf.x,-10,0)
    self.selected.widget.modifiers()[self.selected.color1].set(table.unpack(self.conf.fColor))
    self.selected.widget.modifiers()[self.selected.color2].set(table.unpack(self.conf.fColor))
    for i,option in ipairs(self.options) do
      if option.selected then
        self.selected.widget.modifiers()[self.selected.translate].set(self.conf.x,(i-1)*10)
      end
      option.widget.setText(option.text)
      option.widget.modifiers()[option.translate].set(self.conf.x+3,((i-1)*10)+1)
      option.widget.modifiers()[option.color].set(table.unpack(self.conf.tColor))
    end
    return self
  end

  function ele.addOption(self,text,onClick)
    self.options[#self.options+1] = {text=text,onClick=onClick}
    return self
  end

  function ele.destroyWidget(self)
    if self.back then
      self.back.widget.removeWidget()
      self.selected.widget.removeWidget()
      for i,option in ipairs(self.options) do
        option.widget.removeWidget()
      end
      self.back = {}
      self.selected = {}
    end
    return self
  end
    
  function ele.onClick(self,usr,x,y,btn)
    local opt = math.floor(y/10)
    if self.options[opt] and self.options[opt].onClick then
      self.options[opt]:onClick(usr,btn)
    end
  end

  function ele.inElement(self,x,y)
    if x>= self.conf.x and x<= self.conf.x+self.conf.w then
      if y >= 0 and y <= #self.options*10 then
        return true
      end
    end
    return false
  end

  function ele.setOwner(self,user)
    if self.back then
      self.back.widget.setOwner(user)
      self.selected.widget.setOwner(user)
      for i,option in ipairs(self.options) do
        option.widget.setOwner(user)
      end
    end
    return self
  end

  return ele
end

function elements.window(title,x,y,w,h)
  local win = {}
  win.conf = {title=title,x=x,y=y,w=w,h=h}
  win.conf.bColor = table.pack(0,0,0,0.5)
  win.conf.fColor = table.pack(0,.4,0,0.7)
  win.conf.tColor = table.pack(1,1,1,1)
  win.children = {}
  function win.createWidget(self,gls)
    if self.border then
      self:redraw()
    else
      self.border = {}
      self.border.widget = gls.terminal.addBox2D()
      self.border.translate = self.border.widget.addTranslation(self.conf.x,self.conf.y,0)
      self.border.color1 = self.border.widget.addColor(table.unpack(self.conf.fColor))
      self.border.color2 = self.border.widget.addColor(table.unpack(self.conf.fColor))
      self.border.widget.setSize(self.conf.w,self.conf.h)
      self.back = {}
      self.back.widget = gls.terminal.addBox2D()
      self.back.translate = self.back.widget.addTranslation(self.conf.x+3,self.conf.y+15,0)
      self.back.color1 = self.back.widget.addColor(table.unpack(self.conf.bColor))
      self.back.color2 = self.back.widget.addColor(table.unpack(self.conf.bColor))
      self.back.widget.setSize(self.conf.w-6,self.conf.h-18)
      self.title = {}
      self.title.widget = gls.terminal.addText2D()
      self.title.translate = self.title.widget.addTranslation(self.conf.x+3,self.conf.y+3,0)
      self.title.color = self.title.widget.addColor(table.unpack(self.conf.tColor))
      self.title.widget.setText(self.conf.title)
    end
    for i,ele in ipairs(self.children) do
      ele:destroyWidget()
      ele:createWidget(gls)
    end
    return self
  end

  function win.destroyWidget(self)
    if self.title then
      for i,ele in ipairs(self.children) do
        ele:destroyWidget()
      end
      self.title.widget.removeWidget()
      self.border.widget.removeWidget()
      self.back.widget.removeWidget()
      self.title = nil
      self.border = nil
      self.back = nil
    end
    return self
  end

  function win.redraw(self)
    if not self.border then
      error("attempting to redraw before creating widgets")
    end
    self.title.widget.setText(self.conf.title)
    self.title.widget.modifiers()[self.title.translate].set(self.conf.x+3,self.conf.y+3,0)
    self.title.widget.modifiers()[self.title.color].set(table.unpack(self.conf.fColor))
    self.border.widget.setSize(self.conf.w,self.conf.h)
    self.border.widget.modifiers()[self.border.translate].set(self.conf.x,self.conf.y,0)
    self.border.widget.modifiers()[self.border.color1].set(table.unpack(self.conf.fColor))
    self.border.widget.modifiers()[self.border.color2].set(table.unpack(self.conf.fColor))
    self.back.widget.setSize(self.conf.w-6,self.conf.h-18)
    self.back.widget.modifiers()[self.back.translate].set(self.conf.x+3,self.conf.y+15,0)
    self.back.widget.modifiers()[self.back.color1].set(table.unpack(self.conf.bColor))
    self.back.widget.modifiers()[self.back.color2].set(table.unpack(self.conf.bColor))
    for i,ele in ipairs(self.children) do
      ele:redraw()
    end
    return self
  end

  function win.translateChild(self,x,y)
    return x+self.conf.x+3,y+self.conf.y+15
  end

  function win.addElement(self,ele)
    self.children[#self.children+1] = ele
    ele:destroyWidget()
    if self.back then
      ele:createWidget()
    end
    return self
  end

  function win.setOwner(self,user)
    for i,ele in ipairs(self.children) do
      ele:setOwner(user)
    end
    self.title.widget.setOwner(user)
    self.border.widget.setOwner(user)
    self.back.widget.setOwner(user)
    return self
  end

  function win.onClick(self,user,x,y,button)
    for i,ele in ipairs(self.children) do
      if ele:inElement(x,y) then
        ele:onClick(user,x,y,button)
      end
    end
  end

  function win.inElement(self,x,y)
    if x >= self.conf.x and x <= self.conf.x+self.conf.w then
      if y >= self.conf.y and y <= self.conf.y+self.conf.h then
        return true
      end
    end
    return false
  end

  return win
end

function elements.button(text,x,y,w,h)
  local btn = {}
  btn.conf = {text=text,x=x,y=y,w=w,h=h}
  btn.conf.bColor = table.pack(0,0,1,0.75)
  btn.conf.fColor = table.pack(1,1,1,1)
  function btn.createWidget(self,gls)
    if self.box then
      self:redraw()
    else
      self.box = {}
      self.box.widget = gls.terminal.addBox2D()
      self.box.translate = self.box.widget.addTranslation(self.conf.x,self.conf.y,0)
      self.box.color1 = self.box.widget.addColor(table.unpack(self.conf.bColor))
      self.box.color2 = self.box.widget.addColor(table.unpack(self.conf.bColor))
      self.box.widget.setSize(self.conf.w,self.conf.h)
      self.text = {}
      self.text.widget = gls.terminal.addText2D()
      self.text.translate = self.text.widget.addTranslation(self.conf.x+5,self.conf.y+5,0)
      self.text.color = self.text.widget.addColor(table.unpack(self.conf.fColor))
      self.text.widget.setText(self.conf.text)
    end
    return self 
  end

  function btn.destroyWidget(self)
    if self.box then
      self.box.widget.removeWidget()
      self.box = nil
      self.text.widget.removeWidget()
      self.text = nil
    end
    return self
  end
  
  function btn.redraw(self)
    if not self.box then
      error("attempting to redraw before creating widgets")
    end
    self.text.widget.setText(self.conf.text)
    self.text.widget.modifiers()[self.text.translate].set(self.conf.x+5,self.conf.y+5,0)
    self.text.widget.modifiers()[self.text.color].set(table.unpack(self.conf.fColor))
    self.box.widget.setSize(self.conf.w,self.conf.h)
    self.box.widget.modifiers()[self.box.translate].set(self.conf.x,self.conf.y,0)
    self.box.widget.modifiers()[self.box.color1].set(table.unpack(self.conf.bColor))
    self.box.widget.modifiers()[self.box.color2].set(table.unpack(self.conf.bColor))
    return self
  end

  function btn.changeColor(self,fr,fg,fb,fa,br,bg,bb,ba)
    self.conf.fColor = table.pack(fr,fg,fb,fa)
    self.conf.bColor = table.pack(br,bg,bb,ba)
    if self.box then
      self.redraw()
    end
    return self
  end

  function btn.onClick(self,user,x,y,button)
    if self.callback then
      self.callback(user,button)
    end
  end

  function btn.inElement(self,x,y)
    if x >= self.conf.x and x <= self.conf.x+self.conf.w then
      if y >= self.conf.y and y <= self.conf.y+self.conf.h then
        return true
      end
    end
    return false
  end

  function btn.setOwner(self,user)
    self.text.widget.setOwner(user)
    self.box.widget.setOwner(user)
  end

  return btn
end

menu.classes = elements

return menu
