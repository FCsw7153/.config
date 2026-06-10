vim.pack.add({
  {
    src = "https://github.com/catppuccin/nvim",
    name = "catppuccin",
  },
})

vim.opt.termguicolors = true
vim.opt.background = "dark"

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
})

vim.cmd.colorscheme("catppuccin-mocha")
