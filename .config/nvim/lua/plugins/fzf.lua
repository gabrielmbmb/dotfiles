local function has_lsp_client()
  return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find Files" },
      {
        "<leader>/",
        function()
          require("fzf-lua").live_grep({ hidden = true, no_ignore = false })
        end,
        desc = "Grep (All Files)",
      },
      {
        "<leader>fs",
        function()
          if has_lsp_client() then
            require("fzf-lua").lsp_document_symbols()
            return
          end

          require("fzf-lua").treesitter()
        end,
        desc = "Document Symbols",
      },
      {
        "<leader>gr",
        function()
          if has_lsp_client() then
            require("fzf-lua").lsp_references()
            return
          end

          vim.notify("No LSP client attached", vim.log.levels.WARN)
        end,
        desc = "References",
      },
      {
        "<leader>fS",
        function()
          if has_lsp_client() then
            require("fzf-lua").lsp_live_workspace_symbols()
            return
          end

          vim.notify("No LSP client attached", vim.log.levels.WARN)
        end,
        desc = "Workspace Symbols",
      },
    },
    config = function()
      require("fzf-lua").setup({})
    end,
  },
}
