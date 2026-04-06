return {
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
    opts = {
      -- Floating window configuration
      float = {
        relative = "editor",
        border = "rounded",
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
        row = function()
          return math.floor((vim.o.lines - (vim.o.lines * 0.9)) / 2)
        end,
        col = function()
          return math.floor((vim.o.columns - (vim.o.columns * 0.9)) / 2)
        end,
      },
    },
    config = function()
      local group = vim.api.nvim_create_augroup("LazyGitTerminalMaps", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "lazygit",
        callback = function(args)
          -- Ensure <Esc> is sent to LazyGit/nvim-in-LazyGit (avoid terminal <Esc> escape maps).
          vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = args.buf, nowait = true, silent = true })
        end,
      })
    end,
  },
}
