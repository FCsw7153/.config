require("core.basic")
require("core.keymap")
require("core.lazy")

vim.opt.clipboard = "unnamedplus"

if vim.fn.has("macunix") == 1 then
  vim.g.clipboard = {
    name = "macOS",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
else
  local osc52 = require("vim.ui.clipboard.osc52")

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = function()
        return { vim.fn.getreg("+"), vim.fn.getregtype("+") }
      end,
      ["*"] = function()
        return { vim.fn.getreg("*"), vim.fn.getregtype("*") }
      end,
    },
    cache_enabled = 0,
  }
end
