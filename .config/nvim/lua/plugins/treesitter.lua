return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua",
        "luadoc",
        "svelte",
        "c",
        "cpp",
        "cuda",
        "cmake",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "json",
        "python",
        "zig",
        "vim",
        "vimdoc",
        "query",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")

      if opts.install_dir then
        ts.setup({ install_dir = opts.install_dir })
      end

      if opts.ensure_installed and #opts.ensure_installed > 0 then
        ts.install(opts.ensure_installed)
      end

      local enable_highlight = opts.highlight and opts.highlight.enable
      local enable_indent = opts.indent and opts.indent.enable
      if enable_highlight or enable_indent then
        local group = vim.api.nvim_create_augroup("NvimTreesitterSetup", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
          group = group,
          callback = function()
            local ok = pcall(vim.treesitter.get_parser, 0)
            if not ok then
              return
            end

            if enable_highlight then
              vim.treesitter.start()
            end

            if enable_indent then
              vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end,
        })
      end
    end,
  },
}
