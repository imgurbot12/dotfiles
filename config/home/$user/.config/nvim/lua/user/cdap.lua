
-- Variables

local LATEST_LLDB_VERSION = 15

-- Functions

-- attempt to find binary for lldb in $PATH
local function find_lddb_bin()
  local lldb = nil
  for i=11,LATEST_LLDB_VERSION,1 do
    local bin = string.format('lldb-vscode-%d', i)
    local cmd = io.popen(string.format('which %s', bin))
    lldb = cmd:read()
    if lldb then
      break
    end
  end
  return lldb
end



-- Installers

-- install lldb adapter
local function install_adapter(dap)
  local lldb = find_lddb_bin()
  assert(lldb, 'lldb must be installed to use DAP')
  dap.adapters.lldb = {                                                                                                                      
    name    = 'lldb',                                                                                                                         
    type    = 'executable',
    command = lldb,
    env = {
      LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
    },
  }
end

-- install lldb configurations
local function install_configs(dap)
  dap.configurations.c = {
    {
      name    = 'Launch File',
      type    = 'lldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      externalTerminal = false,
      stopOnEntry = false,
      args = {},
    }
  } 
end

-- local cmd    = io.popen('which lldb-vscode-14')
-- local result = cmd:read()
-- notify(string.format("popen result: %s", result))
