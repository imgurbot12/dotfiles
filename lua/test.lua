
local notify  = require('notify')

local reload  = require('plenary.reload')
reload.reload_module('./user/window')
reload.reload_module('./user/form')
local window = require('./user/window')
local form  = require('./user/form')
local win = window:new({name = 'test', height = 4, width = 20, border = true})

win:keymap('n', {
  -- ["a"]       = '<cmd>lua require"notify"("a!") <cr>',
  ["<Esc>"]   = function() win:close() end,
  -- ["<Enter>"] = function() notify('enter!') end,
})

local function esc(field)
  notify(string.format('%s was pressed', field.name)) 
end
local map = { ["<Enter>"] = esc }

local one = form.Field:new('one', { default = '1', keymap = map })
local two = form.Field:new('two', { default = '2', keymap = map })

local winform = form.Form:new({ one, two})
winform:render(win)

winform:apply_keymap(win)

-- win:set_cursor(3, 0)


-- win:close()
