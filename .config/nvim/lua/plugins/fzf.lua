local function has_lsp_client()
  return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end

local symbol_kinds = {
  "All",
  "File",
  "Module",
  "Namespace",
  "Package",
  "Class",
  "Method",
  "Property",
  "Field",
  "Constructor",
  "Enum",
  "Interface",
  "Function",
  "Variable",
  "Constant",
  "String",
  "Number",
  "Boolean",
  "Array",
  "Object",
  "Key",
  "Null",
  "EnumMember",
  "Struct",
  "Event",
  "Operator",
  "TypeParameter",
}

local function pick_lsp_symbol_kinds(title, picker)
  local fzf = require("fzf-lua")

  fzf.fzf_exec(symbol_kinds, {
    prompt = title .. " kind> ",
    fzf_opts = {
      ["--multi"] = true,
      ["--header"] = "TAB select multiple, ENTER confirm",
    },
    actions = {
      ["enter"] = function(selected)
        if not selected or #selected == 0 then
          return
        end

        local wanted = {}

        for _, kind in ipairs(selected) do
          if kind == "All" then
            picker()
            return
          end

          wanted[kind] = true
        end

        picker({
          regex_filter = function(item)
            return wanted[item.kind] == true
          end,
        })
      end,
    },
  })
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
            pick_lsp_symbol_kinds("Document Symbols", require("fzf-lua").lsp_document_symbols)
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
            pick_lsp_symbol_kinds("Workspace Symbols", require("fzf-lua").lsp_live_workspace_symbols)
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
