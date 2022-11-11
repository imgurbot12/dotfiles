-- ToggleTerm wrapper

local api = vim.api

local last_number    = 0
local last_direction = 'h'

local cmd_vertical   = 'ToggleTerm size=%d direction=vertical'
local cmd_horizontal = 'ToggleTerm size=%d direction=horizontal'

local function toggle_term(direction, number)
  number         = number or (last_number + 1)
  direction      = direction or last_direction
  last_number    = number
  last_direction = direction
  local command
  if direction == 'v' then
    command = string.format(cmd_vertical, (api.nvim_get_option("columns") / 2) - 5)
  else
    command = string.format(cmd_horizontal, api.nvim_get_option("lines") / 3)
  end
  api.nvim_command(string.format('%d%s', number, command))
end

local function lambda_toggle(direction)
  return function()
    toggle_term(direction)
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
