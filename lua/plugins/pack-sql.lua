local utils = require "astrocore"

local function create_sqlfluff_config_file()
  local source_file = vim.fn.stdpath "config" .. "/.sqlfluff"
  local target_file = vim.fn.getcwd() .. "/.sqlfluff"
  local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
  local cmd = is_windows
      and string.format("copy %s %s", vim.fn.shellescape(source_file, true), vim.fn.shellescape(target_file, true))
    or string.format("cp %s %s", vim.fn.shellescape(source_file), vim.fn.shellescape(target_file))
  os.execute(cmd)
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "sql")
      end
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, "sqlfluff")

      if not opts.handlers then opts.handlers = {} end

      opts.handlers.sqlfluff = function()
        local null_ls = require "null-ls"
        null_ls.register(null_ls.builtins.formatting.sqlfluff.with {
          extra_args = { "--dialect", "postgres" },
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        desc = "create completion",
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set(
            "n",
            "<Leader>uA",
            create_sqlfluff_config_file,
            { silent = true, noremap = true, buffer = true, desc = "Create sqlfluff config file" }
          )
        end,
      })
    end,
  },
}