require("core.basic")
require("core.keymap") 
require("core.lazy")   


vim.opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function()
      return { vim.fn.getreg(""), vim.fn.getregtype("") }
    end,
    ["*"] = function()
      return { vim.fn.getreg(""), vim.fn.getregtype("") }
    end,
  },
}
