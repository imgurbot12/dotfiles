--
-- AstroNvim Custom Configuration
--

-- Stop LSP Bitching about global vim
local vim = vim

-- Variables --

local WinUp     = '<cmd>wincmd k<CR>'
local WinDown   = '<cmd>wincmd j<CR>'
local WinLeft   = '<cmd>wincmd h<CR>'
local WinRight  = '<cmd>wincmd l<CR>'
local WinGrow   = '<cmd>resize +2<CR>'
local WinShrink = '<cmd>resize -2<CR>'

local VertSplit  = '<cmd>vert sb<CR>'
local VertGrow   = '<cmd>vertical resize +2<CR>'
local VertShrink = '<cmd>vertical resize -2<CR>' 

local NextBuffer  = ']b'
local PrevBuffer  = '[b'
local CloseBuffer = '<cmd>bp<bar>sp<bar>bn<bar>bd<CR>'

local MardownPreview = '<cmd>ComposerStart<CR>'
local SessionSave    = '<cmd>SessionManager save_current_session<CR>' 
local SessionLoad    = '<cmd>SessionManager load_session<CR>'

-- Functions --

-- generate simple keybind w/ the specified settings
local function keymap(mode, lhs, rhs, options)
  vim.keymap.set(mode, lhs, rhs, options or {})
end

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
        require('notify')('not found!?')
        if not silent then
          require('notify')(string.format('module not found: %s', pkg), 'error')
        end
      end) 
  end
  return library
end

-- configure transparency for `xiyaowong/transparent.nvim` 
local function set_transparency()
  -- assign transparent groups for heirline
  vim.g.transparent_groups = vim.list_extend(
    vim.g.transparent_groups or {}, 
    vim.tbl_map(
      function(v) return v end,
      vim.tbl_keys(require('heirline.highlights').get_highlights())))
  -- assign transparent groups for neo-tree
  vim.g.transparent_groups = vim.list_extend(
    vim.g.transparent_groups or {}, 
    vim.tbl_map(
      function(v) return v end, 
      vim.tbl_values(require('neo-tree.ui.highlights'))))
end

-- Function Wrappers --

local function nextbuf()
  vim.api.nvim_feedkeys(NextBuffer, 'm', false)
end

local function prevbuf()
  vim.api.nvim_feedkeys(PrevBuffer, 'm', false)
end

local function ts_grep()
  use('telescope.builtin').current_buffer_fuzzy_find()
end

local function ts_grepall()
  use('telescope.builtin').live_grep()
end

local function term_new()
  use('terminal').new_term()
end

local function term_toggleall()
  use('terminal').toggle_all()
end

local function term_close()
  use('terminal').shutdown_active()
end

local function term_closeall()
  use('terminal').shutdown_all()
end

local function term_toggle(direction)
  return function()
    use('terminal').new_term({ direction = direction })
  end
end

-- Additonal Mappings --

-- Buffer Navigation
keymap('n', '<Tab>',   nextbuf,     { desc = 'Focus Next Buffer' })
keymap('n', '<C-Tab>', prevbuf,     { desc = 'Focus Previous Buffer' })
keymap('n', '<C-x>',   CloseBuffer, { desc = 'Close Current Tab' })
keymap('n', '<S-Tab>', VertSplit,   { desc = 'Move to Vertical Split' })

-- Window Navigation
keymap('n', '<S-Up>',    WinUp,    { desc = 'Move to upper Window' })
keymap('n', '<S-Down>',  WinDown,  { desc = 'Move to lower Window' })
keymap('n', '<S-Left>',  WinLeft,  { desc = 'Move to left Window' })
keymap('n', '<S-Right>', WinRight, { desc = 'Move to right Window' })

keymap('t', '<S-Up>',    WinUp,    { desc = 'Move to upper Window' })
keymap('t', '<S-Down>',  WinDown,  { desc = 'Move to lower Window' })
keymap('t', '<S-Left>',  WinLeft,  { desc = 'Move to left Window' })
keymap('t', '<S-Right>', WinRight, { desc = 'Move to right Window' })

-- Window Resize
keymap('n', '<C-Up>',    WinGrow,    { desc = 'Resize split Up' })
keymap('n', '<C-Down>',  WinShrink,  { desc = 'Resize split Down' })
keymap('n', '<C-Left>',  VertShrink, { desc = 'Resize split Left' })
keymap('n', '<C-Right>', VertGrow,   { desc = 'Resize split Left' })

-- Jump around line w/ Alt + Left/Right
keymap('n', '<A-Left>',  '^',      { desc = 'Jump Start of Line' })
keymap('n', '<A-Right>', '<End>',  { desc = 'Jump End of Line' })
keymap('i', '<A-Left>',  '<C-o>^', { desc = 'Jump Start of Line' })
keymap('i', '<A-Right>', '<End>',  { desc = 'Jump End of Line' })

-- Telescope Search Utility Rebinds
keymap('n', '<C-f>',  ts_grep,    { desc = 'Grep current buffer' })
keymap('n', '<CA-f>', ts_grepall, { desc = 'Grep project files' })
keymap('i', '<C-f>',  ts_grep,    { desc = 'Grep current buffer' })
keymap('i', '<CA-f>', ts_grepall, { desc = 'Grep project files' })

-- Terminal Navigation and Shortcuts
keymap('n', 'ta',        term_toggleall,   { desc = 'Toggle All Terms' })
keymap('n', 'tq',        term_closeall,    { desc = 'Close All Terms' })
keymap('n', 't<Right>',  term_toggle('v'), { desc = 'Toggle Verticle Term' })
keymap('n', 't<Down>',   term_toggle('h'), { desc = 'Toggle Horizontal Term' })
keymap('t', '<C-q>',     term_close,       { desc = 'Close Active Term' })
keymap('t', '<C-t>',     term_new,         { desc = 'Spawn New Term' })
keymap('t', '<S-l>',     '<C-l>',          { desc = 'Clear Term Screen' })

-- Misc Plugin Bindings
keymap('n', '<A-m>', MardownPreview, { desc = 'Open Markdown Preview' })
keymap('n', '<A-s>', SessionSave,    { desc = 'Save Current Session' })
keymap('n', '<A-l>', SessionLoad,    { desc = 'Load Previous Session' })

-- NeoVide Settings --

vim.g.neovide_transparency = 0.75

-- AstroNvim Config --

return {
  -- colorscheme = 'default_theme',
  updater = {
    remote         = 'origin',
    channel        = 'stable',
    version        = 'latest',
    branch         = 'main',
    pin_plugins    = nil,
    skip_promps    = false,
    show_changelog = true,
  },
  plugins = {
    -- additional plugins
    { 'imgurbot12/essentials.nvim' },
    { 'xiyaowong/transparent.nvim', lazy = false },
    { 'euclio/vim-markdown-composer', build = 'cargo build --release' },
    {
      'AstroNvim/astrocommunity',
      { import = 'astrocommunity.utility.noice-nvim' },
    }, 
    -- overrides
    { 'rebelot/heirline.nvim', lazy = false },
    { 'akinsho/toggleterm.nvim', start_in_insert = true }
  },
  polish = function()
    use('telescope').load_extension('noice')
    vim.defer_fn(set_transparency, 100)
  end
}
