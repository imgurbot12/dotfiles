-- Floating Window Utility

local api   = vim.api
local Cache = require('./user/cache')

-- Functions

local function window_opts(options)
  local w = api.nvim_get_option("columns")
  local h = api.nvim_get_option("lines")
  options          = options or {}
  options.perw     = options.perw   or 0.5
  options.perh     = options.perh   or 0.4
  options.width    = options.width  or math.ceil(w * options.perw)
  options.height   = options.height or math.ceil(h * options.perh - 4)
  options.col      = options.col    or math.ceil((w - options.width) / 2)
  options.row      = options.row    or math.ceil((h - options.height) / 2 - 1)
  return {
    style    = options.style    or 'minimal',
    relative = options.relative or 'editor',
    row      = options.row,
    col      = options.col,
    width    = options.width,
    height   = options.height,
  }
end

local function apply_border(options)
  -- define border items
  local top = '╭' .. string.rep('─', options.width) .. '╮'
  local mid = '│' .. string.rep(' ', options.width) .. '│'
  local bot = '╰' .. string.rep('─', options.width) .. '╯'
  -- generate border from defined lines
  local lines = { top, bot }
  for _=1, options.height do
    table.insert(lines, 2, mid)
  end
  -- update options for border window
  local border_opts = {
    style    = 'minimal',
    relative = 'editor',
    row      = options.row    - 1,
    col      = options.col    - 1,
    width    = options.width  + 2,
    height   = options.height + 2,
  }
  -- write to buffer and spawn window
  local buf = api.nvim_create_buf(false, true)
  local win = api.nvim_open_win(buf, true, border_opts)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return { window = win, buffer = buf }
end

local function cache_func(cache, mode, bind, func)
  -- update bind to escape brackets before generating cache entry
  bind = bind:gsub("<", "\\<"):gsub(">", "\\>")
  cache[mode..bind] = func
  cache:save()
  -- generate lua command to call upon cached function
  bind = bind:gsub("<", "\\<"):gsub(">", "\\>")
  return string.format("<cmd>lua vim.api.nvim_get_var('%s')['%s']()<cr>", cache.name, mode..bind)
end

-- Classes

local Window = { name = nil, bufn = 0, win = 0, border = nil, cache = nil }

function Window:new(options)
  assert(options.name, 'window name must be specified in options')
  -- build self
  local o = {}
  setmetatable(o, self)
  self.__index = self
  -- generate base window buffer
  o.name = options.name
  o.bufn = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(o.bufn, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(o.bufn, 'filetype', options.name)
  -- build options for window and generate border (if enabled)
  local winopts = window_opts(options)
  o.border = options.border == true and apply_border(winopts) or nil
  -- generate window and apply border auto-close if not nil
  o.win = api.nvim_open_win(o.bufn, true, winopts) 
  if o.border then
    local cmd = 'au BufWipeout <buffer> exe "silent bwipeout! "'..o.border.buffer
    api.nvim_command(cmd)
  end
  api.nvim_win_set_option(o.win, 'cursorline', true)
  api.nvim_buf_add_highlight(o.bufn, -1, 'DapCppHeader', 0, 0, -1)
  -- add additional attributes
  o.wopts = winopts
  o.cache = Cache:new(string.format('window_%s_keymap', o.name))
  -- return generated window object
  return o
end

function Window:lock()
  api.nvim_buf_set_option(self.bufn, 'modifiable', false)
end

function Window:unlock()
  api.nvim_buf_set_option(self.bufn, 'modifiable', true)
end

function Window:keymap(mode, binds, options)
  assert(mode,  'keybind mode must be specified')
  assert(binds, 'keybind bindmap must not be empty')
  -- configure options
  options = options or {}
  options.nowait  = options.nowait  or true
  options.noremap = options.noremap or true
  options.silent  = options.silent  or true
  -- configure keybind cache for lua functions
  local cmd
  for bind, op in pairs(binds) do
    cmd = type(op) ~= "string" and cache_func(self.cache, mode, bind, op) or op
    api.nvim_buf_set_keymap(self.bufn, mode, bind, cmd, options)
  end
end

function Window:on_update(options)
  assert(options, 'on_update function options must be specified')
  vim.api.nvim_buf_attach(self.bufn, false, options)
end

function Window:writelines(lines)
  assert(lines, 'lines must be specified during write')
  api.nvim_buf_set_lines(self.bufn, 0, -1, false, lines)
end

function Window:readlines()
  return api.nvim_buf_get_lines(self.bufn, 0, -1, false)
end

function Window:get_cursor()
  return api.nvim_win_get_cursor(self.win)
end

function Window:set_cursor(row, col)
  assert(row, 'row number must be specified')
  assert(col, 'col number must be specified')
  api.nvim_win_set_cursor(self.win, { row, col })
end

function Window:move_cursor(row, col)
  local height = self.wopts.height - 2
  local width  = self.wopts.width  - 2
  local cursor = self:get_cursor()
  cursor       = { cursor[1] + (row or 0), cursor[2] + (col or 0) }
  cursor       = { math.min(cursor[1], height), math.min(cursor[2], width) }
  self:set_cursor(cursor[1], cursor[2])
end

function Window:close(force)
  force = force or true
  pcall(api.nvim_win_close, self.win, force)
  if self.border then
    pcall(api.nvim_win_close, self.border.win, force)
  end
end

-- Export

return Window
