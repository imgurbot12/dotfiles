
---- Variables

local WindowUp      = "<cmd>wincmd k<CR>"
local WindowDown    = "<cmd>wincmd j<CR>"
local WindowLeft    = "<cmd>wincmd h<CR>"
local WindowRight   = "<cmd>wincmd l<CR>"

local NextBuffer  = "<cmd>BufferLineCycleNext<cr>"
local PrevBuffer  = "<cmd>BufferLineCyclePrev<cr>"
local CloseBuffer = "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>"

---- Functions

-- geneate new mock object w/ optional notify function
local function new_mock(notify)
  local mock = {};
  setmetatable(mock, {
    __index=function () return function() end end,
    __call=function()
      if notify ~= nil then
        notify()
      end
      return mock 
    end,
  })  
  return mock
end

-- return module if found, else return mock object to take no action
local function use(pkg, silent)
  local library = nil 
  if not pcall(function() library = require(pkg) end) then
      return new_mock(function()
        if not silent then
          require('notify')(string.format('module not found: %s', pkg), 'error')
        end
      end) 
  end
  return library
end

-- run function if package exists (for setup)
local function setup(pkg, run)
  local library = nil
  if pcall(function() library = require(pkg) end) then
    run(library)
  end
end

-- Function Wrappers

-- telscope search function
local telescope_grep     = use 'telescope.builtin' .current_buffer_fuzzy_find
local telescope_grep_all = use 'telescope.builtin' .live_grep

-- terminal wrappers
local term_new             = use 'terminal' .new_term
local term_toggle_all      = use 'terminal' .toggle_all
local term_shutdown_active = use 'terminal' .shutdown_active
local term_shutdown_all    = use 'terminal' .shutdown_all

-- bind a new function to spawn a new terminal for the given direction
local function term_bind_toggle(direction)
  return function()
    use 'terminal' .new_term({ direction = direction })
  end
end

-- dap/dapui wrappers

local dap_continue          = use 'dap'   .continue
local dap_toggle_breakpoint = use 'dap'   .toggle_breakpoint
local dap_step_over         = use 'dap'   .step_over
local dap_step_into         = use 'dap'   .step_into
local dapui_eval            = use 'dapui' .eval

---- Configuration

local config = {

  -- Configure AstroNvim updates
  updater = {
    remote = "origin", -- remote to use
    channel = "stable", -- "stable" or "nightly"
    version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "main", -- branch name (NIGHTLY ONLY)
    commit = nil, -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false, -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
  },

  -- Set colorscheme
  colorscheme = "default_theme",

  -- set vim options here (vim.<first_key>.<second_key> =  value)
  options = {
    -- sets vim.opt.relativenumber
    opt = { relativenumber = false, },
    -- sets vim.g.mapleader
    g = { mapleader = " ", },
  },

  -- Default theme configuration
  default_theme = {
    diagnostics_style = { italic = true },
    -- Modify the color table
    colors = {},
    -- enable or disable extra plugin highlighting
    plugins = {},
  },

  -- Disable AstroNvim ui features
  ui = {},

  -- Configure plugins
  plugins = {
    init = {
      { "imgurbot12/essentials.nvim" },
      { "junegunn/fzf", run = function() vim.fn['fzf#install']() end},
      { "kevinhwang91/nvim-bqf" },
      { "euclio/vim-markdown-composer", run = "cargo build --release" },
      -- dap plugins
      { "mfussenegger/nvim-dap" },
      { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} },
      { "mfussenegger/nvim-dap-python", requires = {"mfussenegger/nvim-dap"} },
    },
    ["toggleterm"] = {
      start_in_insert = true,
    },
    ["session_manager"] = {
      sessions_dir = string.format("%s/sessions", vim.fn.stdpath('data')),
      autosave_last_session = true,
    },
    ["which-key"] = {
      silent = true,
      noremap = true,
    },
    ["neo-tree"] = {
      window = {
        mappings = {
          ["Z"] = "expand_all_nodes",
        },
      },
    },
  },

  -- CMP Source Priorities
  -- modify here the priorities of default cmp sources
  -- higher value == higher priority
  -- The value can also be set to a boolean for disabling default sources:
  -- false == disabled
  -- true == 1000
  cmp = {
    source_priority = {},
  },

  -- Diagnostics configuration (for vim.diagnostics.config({}))
  diagnostics = {},

  -- Mapping data with "desc" stored directly by vim.keymap.set().
  --
  -- Please use this mappings table to set keyboard mapping since this is the
  -- lower level configuration and more robust one. (which-key will
  -- automatically pick-up stored data by this setting.)
  mappings = {
    -- first key is the mode
    i = {
      -- code navigation
      ["<A-Left>"]  = { "<C-o>^", desc = "Jump to Start of Line" },
      ["<A-Right>"] = { "<End>",  desc = "Jump to End of Line" },
      -- find utilities
      ["<C-f>"]  = { telescope_grep,     desc = "Grep current buffer" },
      ["<CA-f>"] = { telescope_grep_all, desc = "Grep project files" },
    },
    t = {
      -- improved terminal controls
      ["<C-l>"] = { '<C-l>', desc = "Clear Terminal Screen" },
      -- improved terminal window navigation
      ["<C-q>"]     = { term_shutdown_active, desc = "Close Current Terminal" },
      ["<C-t>"]     = { term_new,             desc = "Spawn Additional Terminal(s)" },
      ["<C-Up>"]    = { WindowUp,             desc = "Move to upper window" },
      ["<C-Down>"]  = { WindowDown,           desc = "Move to lower window" },
      ["<C-Left>"]  = { WindowLeft,           desc = "Move to left window"  },
      ["<C-Right>"] = { WindowRight,          desc = "Move to right window" },
    },
    n = {
      -- quit shortcut
      ["<C-c>"] = { "<cmd>q<CR>" },
      -- terminal shortcuts
      ["ta"]       = { term_toggle_all,       desc = "Toggle All Terminals" },
      ["tq"]       = { term_shutdown_all,     desc = "Shutdown All Terminals" },
      ["t<Right>"] = { term_bind_toggle('v'), desc = "Toggle Vertical Term" },
      ["t<Down>"]  = { term_bind_toggle('h'), desc = "Toggle Horizonal Term" },
      -- telescope search navigation
      ["<C-f>"]  = { telescope_grep,     desc = "Grep current buffer" },
      ["<CS-f>"] = { telescope_grep_all, desc = "Grep project files" },
      -- code navigation
      ["<A-Left>"]  = { "^", desc = "Jump to Start of Line" },
      ["<A-Right>"] = { "<End>",  desc = "Jump to End of Line" },
      -- tab (buffer) navigation
      ["<Tab>"]    = { NextBuffer,         desc = "Focus Next Buffer" },
      ["<C-Tab>"]  = { PrevBuffer,         desc = "Focus Prev Buffer" },
      ["<C-x>"]    = { CloseBuffer,        desc = "Close Current Tab" },
      ["<CS-Tab>"] = { "<cmd>vert sb<CR>", desc = "Move to Vertical Split" },
      -- menu nagivation controls rework
      ["!"]         = { "<cmd>1wincmd w <CR>", desc = "Move to first window" },
      ["@"]         = { "<cmd>2wincmd w<CR>", desc = "Move to window #2" },
      ["#"]         = { "<cmd>3wincmd w<CR>", desc = "Move to window #3" },
      ["$"]         = { "<cmd>4wincmd w<CR>", desc = "Move to window #4" },
      ["%"]         = { "<cmd>5wincmd w<CR>", desc = "Move to window #5" },
      ["<C-Up>"]    = { WindowUp,    desc = "Move to upper split" },
      ["<C-Down>"]  = { WindowDown,  desc = "Move to lower split" },
      ["<C-Left>"]  = { WindowLeft,  desc = "Move to left split"  },
      ["<C-Right>"] = { WindowRight, desc = "Move to right split" },
      ["<S-Up>"]    = { "<cmd>resize +2<CR>",          desc = "Resize split up" },
      ["<S-Down>"]  = { "<cmd>resize -2<CR>",          desc = "Resize split down" },
      ["<S-Left>"]  = { "<cmd>vertical resize -2<CR>", desc = "Resize split left" },
      ["<S-Right>"] = { "<cmd>vertical resize +2<CR>", desc = "Resize split right" },
      -- debugger commands
      ["<F4>"] = { dap_continue,          desc = "Debugger Continue"},
      ["<F5>"] = { dap_toggle_breakpoint, desc = "Debugger Toggle Breakpoint" },
      ["<F6>"] = { dapui_eval,            desc = "Debugger UI Eval" },
      ["<F8>"] = { dap_step_over,         desc = "Debuffer Step Over" }, 
      ["<F9>"] = { dap_step_into,         desc = "Debugger Step Into"},
      -- plugin commands
      ["<A-m>"] = { "<cmd>ComposerStart<CR>", desc = "Open Markdown Preview" },
      ["<A-s>"] = { "<cmd>SessionManager save_current_session<CR>", desc = "Save Session" },
      ["<A-l>"] = { "<cmd>SessionManager load_session<CR>", desc = "Load Dir Session" },
    },
  },

  -- Modify which-key registration (Use this with mappings table in the above.)
  ["which-key"] = {
    -- Add bindings which show up as group name
    register_mappings = {
      -- first key is the mode, n == normal mode
      n = {},
    },
  },

  -- This function is run last
  -- good place to configuring augroups/autocommands and custom filetypes
  polish = function()
    -- configure and enable available debuggers
    setup('dap', function(dap)
      -- setup dapui
      setup('dapui', function(dapui)
        dapui.setup()
        local after = dap.listeners.after
        local before = dap.listeners.before
        after.event_initialized["dapui_config"] = dapui.open
        before.event_terminated["dapui_config"] = dapui.close
        before.event_exited["dapui_config"]     = dapui.close
      end)
      -- setup dap-python if available
      setup('dap-python', function(python) 
        python.setup('~/.virtualenvs/debugpy/bin/python')
      end)
    end)
    -- update function keymapping for better-quick-fix
    setup('bqf', function(bqf) 
      bqf.setup({ func_map = {
        filter  = "<C-f>",
        filterr = "<C-d>",
      }})
    end)
    -- disable markdown-preview autostart
    vim.cmd("let g:markdown_composer_autostart = 0")
  end,
}
return config
