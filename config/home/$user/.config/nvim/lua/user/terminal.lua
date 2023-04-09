-- 
-- ToggleTerm wrapper designed to allow mass deployment of terminal sessions
--

-- Variables

local api = vim.api

local last_number    = 1
local last_direction = 'h'

local cmd_vertical   = 'ToggleTerm size=75 direction=vertical'
local cmd_horizontal = 'ToggleTerm size=10 direction=horizontal'

-- Functions

local function toggle_term(direction, number)
  number         = number or ((last_number or 0) + 1)
  direction      = direction or last_direction
  last_number    = number
  last_direction = direction
  local command  = direction == 'v' and cmd_vertical or cmd_horizontal
  api.nvim_command(string.format('%d%s', number, command))
end

local function lambda_toggle(direction, number)
  return function ()
    toggle_term(direction, number) 
  end
end

local function toggle_all()
  api.nvim_command('ToggleTermToggleAll')
end

-- Export

return {
  toggle_term   = toggle_term,
  lambda_toggle = lambda_toggle,
  toggle_all    = toggle_all,
}
