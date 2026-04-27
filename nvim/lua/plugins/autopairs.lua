-- lua/plugins/autopairs.lua
vim.pack.add({
  {
    src = "https://github.com/windwp/nvim-autopairs",
    name = "nvim-autopairs",
  },
}, {
  confirm = false,
  load = true,
})

require("nvim-autopairs").setup({})
