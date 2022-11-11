
local notify  = require('notify')

local reload  = require('plenary.reload')
reload.reload_module('./user/window')
reload.reload_module('./user/form/form')
reload.reload_module('./user/form/field')
reload.reload_module('./user/form/text')

local window = require('./user/window')
local text = require('./user/form/text') 
local form = require('./user/form/form')

local win = window:new({name = 'test', height = 4, width = 20, border = true})

win:keymap('n', {
  -- ["a"]       = '<cmd>lua require"notify"("a!") <cr>',
  ["<Esc>"]   = function() win:close() end,
  -- ["<Enter>"] = function() notify('enter!') end,
})


local one = text('one', { default = '1' })
local two = text('two', { default = '2' })

local winform = form.Form:new({ one, two })
winform:render(win)

keymap = winform:apply_keymap(win)

notify(vim.inspect(one))
-- n_keymap["<Esc>"] = function() window:close() end

-- win:set_cursor(3, 0)


-- win:close()
