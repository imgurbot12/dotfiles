-- FORM Implementation

local Form = {}

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
  -- build functions to call the relevant field functions for keymap
  local keymap = {i = {}, n = {}}
  for _, field in pairs(self.fields) do
    for mode, keys in pairs(field.keymap) do
      if not keymap[mode] then keymap[mode] = {} end
      for key, func in pairs(keys) do
        -- declare cursor controlled dynamic keybind
        keymap[mode][key] = function()
          local cursor = window:get_cursor()
          for _, field in pairs(self.fields) do
            local func = field.keymap[mode][key]
            if func and field:is_active(cursor) then
              func(window, field)
            end
          end
        end
      end
    end
  end
  -- assign global updates tracker
  window:on_update({on_bytes = function(_, buf, _, row, col)
    local line = window:readlines()[row + 1]
    for _, field in pairs(self.fields) do
      if field.on_update and field:is_active({row + 1, col}) then
        field.on_update(window, field, buf, line, { row = row, col = col })
      end
    end
  end})
  -- assign generated keymap
  for mode, binds in pairs(keymap) do
    window:keymap(mode, binds)
  end
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
