
local api = vim.api
local name, buffer, window

local function apply_borders(options)
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

local function open_window(options)
  -- get dimensions of editor
  local w = api.nvim_get_option("columns")
  local h = api.nvim_get_option("lines")
  -- fill default values
  options          = options or {}
  options.perw     = options.perw   or 0.5
  options.perh     = options.perh   or 0.4
  options.width    = options.width  or math.ceil(w * options.perw)
  options.height   = options.height or math.ceil(h * options.perh - 4)
  options.col      = options.col    or math.ceil((w - options.width) / 2)
  options.row      = options.row    or math.ceil((h - options.height) / 2 - 1)
  -- update window name
  name = options.name or 'default'
  -- define and build primary buffer
  buffer = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buffer, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buffer, 'filetype', name)
  -- define borders if configured 
  local border
  if not options.borderless then
    border = apply_borders(options)
  end
  -- generate window with buffer
  local winopts = {
    style    = options.style    or 'minimal',
    relative = options.relative or 'editor',
    col      = options.col,
    row      = options.row,
    width    = options.width,
    height   = options.height,
  }
  window = api.nvim_open_win(buffer, true, winopts) 
  if border then
    local cmd = 'au BufWipeout <buffer> exe "silent bwipeout! "'..border.buffer
    api.nvim_command(cmd)
  end
  api.nvim_win_set_option(window, 'cursorline', true)
  api.nvim_buf_add_highlight(buffer, -1, 'DapCppHeader', 0, 0, -1)
  -- update buffer content if lines are set
  if options.lines then
    api.nvim_buf_set_lines(buffer, 0, -1, false, options.lines)
  end
end

local function _setdefault(map, key, value)
  if not map[key] then
    map[key] = value
  end
end

local function _cache_keymap(mode, bind, cmd)
  bind = bind:gsub("<", "\\<"):gsub(">", "\\>")
  _setdefault(_G, '_wb', {})
  _setdefault(_G._wb, name, {})
  _setdefault(_G._wb[name], mode, {})
  _setdefault(_G._wb[name][mode], bind, {})
  _G._wb[name][mode][bind] = cmd
  bind = bind:gsub("<", "\\<"):gsub(">", "\\>")
  return string.format("<cmd>lua _G._wb['%s']['%s']['%s']()<cr>", name, mode, bind)
end

local function keybind_window(mode, binds, options)
  assert(mode,  'keybind mode must be specified')
  assert(binds, 'keybind bindmap must not be empty')
  -- configure options
  options = options or {}
  options.nowait  = options.nowait  or true
  options.noremap = options.noremap or true
  options.silent  = options.silent  or true
  -- apply keybinds 
  for bind,op in pairs(binds) do
    local cmd
    if type(op) ~= "string" then
      cmd = _cache_keymap(mode, bind, op)
    else
      cmd = op
    end
    api.nvim_buf_set_keymap(buffer, mode, bind, cmd, options)
  end
end

local function lock_window()
  api.nvim_buf_set_option(buffer, 'modifiable', false)
end

local function unlock_window()
  api.nvim_buf_set_option(buffer, 'modifiable', true)
end

local function update_window(lines)
  api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
end

local function close_window()
  api.nvim_win_close(window, true)
end

local function get_lines_window()
  return api.nvim_buf_get_lines(buffer, 0, -1, false)
end

local function cursor_window(pos)
  api.nvim_win_set_cursor(window, pos)
end

return {
  open        = open_window,
  lock        = lock_window,
  unlock      = unlock_window,
  update      = update_window,
  move_cursor = cursor_window,
  get_lines   = get_lines_window,
  keymap      = keybind_window,
  close       = close_window,
}
