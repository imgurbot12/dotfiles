-- User Input Implementation

local api = vim.api

-- Functions

local function default_render(field, lines)
  table.insert(lines, string.format('%s: %s', field.name, field.value))
end

-- FIELD Implementations

local Field = { name = nil, default = nil, value = nil }

function Field:new(name, options)
  assert(name, 'field name must be specified')
  -- build base object
  local o = {}
  setmetatable(o, self)
  self.__index = self
  -- validate and apply fields
  options    = options or {}
  o.name     = name
  o.default  = options.default or ''
  o.value    = o.default
  o.height   = options.height or 1
  o.width    = options.width or (o.name:len() + o.value:len() + 4)
  o.keymap   = options.keymap
  o.renderer = options.render or default_render
  o.validate = options.validate
  o.pos      = {1, 0}
  -- return generated form object
  return o
end

function Field:render(lines)
  self.renderer(self, lines) 
end

function Field:is_active(cursor)
  if cursor[1] < self.pos[1] or cursor[1] >= self.pos[1] + self.height then
    return false
  end
  if cursor[2] < self.pos[2] or cursor[2] >= self.pos[2] + self.width then
    return false
  end
  return true
end

function Field:parse(content)
  local val = content:gsub(string.format('^%s: ', self.name), '')
  if self.validate then
    val = self.validate(val)
  end
  self.value = val
end

-- FORM Implementation

local Form = { name = nil, bounds = nil }

function Form:new(fields)
  assert(fields, 'form fields must be declared')
  -- build base object
  local o = {}
  setmetatable(o, self)
  self.__index = self
  -- modify fields
  for i, field in pairs(fields) do
    field.pos = { i, 0 }
  end
  -- apply fields
  o.fields = fields
  -- return generated form object
  return o
end

function Form:apply_keymap(window)
  local keymap = {}
  -- assign all keys registed in keymap
  for _, field in pairs(self.fields) do
    local fkm = field.keymap or {}
    for key in pairs(fkm) do
      keymap[key] = false
    end
  end
  -- build functions to call the relevant field functions for keymap
  for key in pairs(keymap) do
    keymap[key] = function()
      local cursor = window:get_cursor()
      for _, field in pairs(self.fields) do
        local func = field.keymap[key]
        if func and field:is_active(cursor) then
          func(field)
        end
      end
    end
  end
  -- apply keymap to window
  keymap["<Esc>"] = function() window:close() end
  window:keymap('n', keymap)
end

function Form:render(window)
  local lines = {}
  for _, field in ipairs(self.fields) do
    field:render(lines)
  end
  window:writelines(lines)
end

function Form:submit(lines)
  assert(lines, 'lines must be specified on submit') 
  for i=1,lines.len() do
    local pos    = { i - 1, 0}
    local line   = lines[i]

  end

end

-- Export

return { Field = Field, Form = Form }
