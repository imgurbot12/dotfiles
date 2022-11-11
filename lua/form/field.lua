--
-- Field Prototype used for Form Implementations
--

local api = vim.api

-- Functions

local function default_render(field, lines)
  table.insert(lines, string.format('%s: \033[3m%s\033[23m', field.name, field.value))
end

-- protect_field
--   prevent the user from ever moving the cursor over the field name
--   only allowing them access to modify the value
--
-- @param window Window  neovim window object wrapper
-- @param field  Field   field implementation tied to keybind
local function protect_field(direction)
  return function(window, field)
    local pos  = window:get_cursor()
    local protected = field.name:len() + 2
    if pos[2] < protected or (direction < 0 and pos[2] == protected) then
      window:set_cursor(pos[1], protected)
    else
      window:move_cursor(0, direction)
    end
  end
end

-- Classes

local Field = {}

-- Field:new
--   initialize a new generic field object with the specified settings
--
-- @param name    string  name of the generic field object
-- @param options Table   misc paramters used to customize field
function Field:new(name, options)
  assert(name, 'field name must be specified')
  -- build base object
  local o = {}
  setmetatable(o, self)
  self.__index = self
  -- validate and apply fields
  options     = options or {}
  o.name      = name
  o.default   = options.default or ''
  o.value     = o.default
  o.height    = options.height or 1
  o.width     = options.width or (o.name:len() + o.value:len() + 4)
  o.keymap    = options.keymap
  o.renderer  = options.render or default_render
  o.validate  = options.validate
  o.on_update = options.on_update
  o.pos      = {1, 0}
  -- return generated form object
  return o
end

-- Field:render
--  render the field content name/default-value to text form
--
-- @param lines Table  table to append rendered lines content to
function Field:render(lines)
  self.renderer(self, lines) 
end

-- Field:is_active
--  return true if the cursor is within bounds of the field object in the form
--
-- @param cursor {int, int}  row/column cursor position
function Field:is_active(cursor)
  if cursor[1] < self.pos[1] or cursor[1] >= self.pos[1] + self.height then
    return false
  end
  -- if cursor[2] < self.pos[2] or cursor[2] >= self.pos[2] + self.width then
  --  return false
  -- end
  return true
end

-- Field:parse
--  parse the raw field entry to retrieve and validate field value
--
-- @param content string raw form field text content
function Field:parse(content)
  local val = content:gsub(string.format('^%s: ', self.name), '')
  if self.validate then
    val = self.validate(val)
  end
  self.value = val
  return val
end

-- Export

return {
  Field         = Field,
  protect_field = protect_field,
}
