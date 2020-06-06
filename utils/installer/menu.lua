local menu = {}

local _menu = {}

function menu.create(title)
	return setmetatable({}, {__index=_menu})
end

function _menu:destroy()

end

function _menu:add(obj)

end

function _menu:calcsize()
	local w, h = 0,0
	for i=1, #self do
		local ew, eh = self[i]:size()
		if (ew > w) then
			w = ew
		end
		h = h + eh
	end
	self.w = w
	self.h = h
	return w, h
end

function _menu:draw()
	local w, h = self.w+2, self.h+2
	for i=1, #self do

	end
end

function _menu:drawblit()
	local w, h = self.w+2, self.h+2
	for i=1, #self do

	end
end

local _text = {}

function _text:size()
	return self.w, self.h
end

function _text:draw(gpu, x, y, width)
	for i=1, #self.txt do
		local rx = x+math.floor((width/2)-(#self.txt/2))
		gpu.set(rx, y+i-1, self.txt[i])
	end
end

local _select = {entry = true}

function _select:select(func)
	self.select = func
end

function _select:size()
	return self.w, self.h
end

function _select:keyupdate(key)

end

local _buttons = {entry = true}

function _buttons:select(func)
	self.select = func
end

function _buttons:size()
	return self.w, self.h
end

function _buttons:keyupdate(key)

end

local _checkboxes = {entry = true}

function _checkboxes:size()

end

function _checkboxes:keyupdate(key)

end

local _textbox = {entry = true}

function _textbox:keyupdate(key)

end

function _textbox:size()

end

function _textbox:select(func)

end

function _textbox:get()
	return self.buffer
end

function menu.textbox(w)

end

function menu.select(options)

end

function menu.buttons(buttons)

end

function menu.checkbox(options)

end