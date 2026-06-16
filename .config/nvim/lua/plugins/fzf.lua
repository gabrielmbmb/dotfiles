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

local function git_worktrees()
  local out = vim.fn.systemlist({ "git", "worktree", "list", "--porcelain" })
  if vim.v.shell_error ~= 0 then
    return nil, table.concat(out, "\n")
  end

  local worktrees = {}
  local current = nil

  for _, line in ipairs(out) do
    if line:match("^worktree ") then
      current = { path = line:sub(#"worktree " + 1) }
      table.insert(worktrees, current)
    elseif current then
      if line:match("^branch ") then
        current.branch = line:sub(#"branch " + 1):gsub("^refs/heads/", "")
      elseif line == "detached" then
        current.detached = true
      elseif line:match("^HEAD ") then
        current.head = line:sub(#"HEAD " + 1, #"HEAD " + 8)
      end
    end
  end

  return worktrees
end

local function pick_worktree()
  local fzf = require("fzf-lua")

  local worktrees, err = git_worktrees()
  if not worktrees then
    vim.notify("Not a git repository" .. (err and (": " .. err) or ""), vim.log.levels.WARN)
    return
  end

  if #worktrees == 0 then
    vim.notify("No worktrees found", vim.log.levels.WARN)
    return
  end

  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):gsub("/$", "")
  local by_display = {}
  local entries = {}

  for _, wt in ipairs(worktrees) do
    local ref = wt.branch or (wt.detached and (wt.head and ("(detached " .. wt.head .. ")") or "(detached)")) or "(bare)"
    local is_current = vim.fn.fnamemodify(wt.path, ":p"):gsub("/$", "") == cwd
    local display = string.format("%s %-24s %s", is_current and "*" or " ", ref, wt.path)
    by_display[display] = wt.path
    table.insert(entries, display)
  end

  fzf.fzf_exec(entries, {
    prompt = "Worktree> ",
    fzf_opts = {
      ["--header"] = "ENTER cd + find files",
    },
    actions = {
      ["enter"] = function(selected)
        if not selected or #selected == 0 then
          return
        end

        local path = by_display[selected[1]]
        if not path then
          return
        end

        vim.cmd.cd(vim.fn.fnameescape(path))
        vim.notify("cwd -> " .. path)
        fzf.files({ cwd = path })
      end,
    },
  })
end

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
      { "<leader>gw", pick_worktree, desc = "Git Worktrees" },
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
