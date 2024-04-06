
-- Variables --

local LAZY_GIT = "https://github.com/folke/lazy.nvim.git"

-- Functions --

-- install `lazy.nvim` and ensure its importable
local function install_lazy()
  -- ensure `lazy.nvim` is installed
  local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
  if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      LAZY_GIT,
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
  -- validate that lazy is available
  if not pcall(require, "lazy") then
    vim.api.nvim_echo({
      { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" },
      { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

-- initialize configuration and setup
local function init()
  require "lazy_setup"
  require "keymap"
  require "polish"
end

-- Init --
install_lazy()
init()
