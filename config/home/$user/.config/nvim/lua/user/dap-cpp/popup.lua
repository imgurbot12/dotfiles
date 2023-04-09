
local api    = vim.api
local Path   = require('plenary.path')
local window = require('./user/dap-cpp.window')

local function prompt_submit()
  -- retrieve potential path from input
  local command = window.get_lines()[1]

  -- require('notify')(string.format('path: %s', path)) 
  window.close()
end

local function prompt_open()
  -- collect path from cache or set to default
  local path = '.../'
  -- generate window and keymap settings
  window.open({ height = 1, lines  = { path .. ' ' } })
  window.keymap('n', {
    ['<Esc>']   = window.close,
    ['<Enter>'] = prompt_submit,
  })
  -- set user to insert mode
  window.move_cursor({1, string.len(path) + 1})
  api.nvim_command('startinsert')
end

return {
  open   = prompt_open,
  submit = prompt_submit,
}
