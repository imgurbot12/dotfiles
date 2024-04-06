-- Core AstroNvim Configuration

-- Functions --

local function custom_save()
  require("whitespace-nvim").trim()
  vim.cmd "write"
end

-- Init --

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- override mappings
    mappings = {
      n = {
        ["<C-s>"] = { custom_save, desc = "Save Current Buffer" },
        ["<CS-s>"] = { custom_save, desc = "Save Current Buffer #2" },
      },
    },
  },
}
