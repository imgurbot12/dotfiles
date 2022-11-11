-- 
-- Text Input Implementation
--
local api   = vim.api
local field = require('./user/form/field')

-- Functions

local function setdefault(table, key, value)
  assert(key,   'key must be specified to set default')
  assert(value, 'value must be spcified to set default')
  if not table[key] then
    table[key] = value
  end
end

local function protect_down(w, f)
  w:move_cursor(1, 0)
end

-- Classes

local function text_input(name, options)
  -- build important text defaults
  options.keymap = options.keymap or {}
  -- set on-update manager
  options.on_update = function(window, field, buf, line, details)
    -- if not pcall(field:parse, line) then
    --   
    -- end
  end
  -- update keymap with defaults
  setdefault(options.keymap, 'n', {})
  setdefault(options.keymap, 'i', {})
  options.keymap['n']['<Left>']  = field.protect_field(-1)
  options.keymap['n']['<Right>'] = field.protect_field(1)
  options.keymap['i']['<Left>']  = field.protect_field(-1)
  options.keymap['i']['<Right>'] = field.protect_field(1)
  options.keymap['i']['<Enter>'] = protect_down 
  -- generate field object
  return field.Field:new(name, options)
end

-- Exports

return text_input
