local M = {}

-- Virtualenv directory names to search for (in order of preference)
M.venv_names = { ".venv", "venv" }

-- Cache the current virtualenv path
M.current_venv = nil

-- Cache the base PATH before activating any venv
M.base_path = nil
M.current_bin = nil
M.path_sep = package.config:sub(1, 1) == "\\" and ";" or ":"

local function strip_path_entry(path, entry, sep)
  if not path or path == "" or not entry then
    return path
  end
  local parts = vim.split(path, sep, { plain = true, trimempty = true })
  local kept = {}
  for _, part in ipairs(parts) do
    if part ~= entry then
      table.insert(kept, part)
    end
  end
  return table.concat(kept, sep)
end

--- Find the nearest virtualenv directory by traversing up from start_path
--- @param start_path string|nil Starting directory (defaults to cwd)
--- @return string|nil path to the virtualenv directory, or nil if not found
function M.find_venv(start_path)
  start_path = start_path or vim.fn.getcwd()

  for _, venv_name in ipairs(M.venv_names) do
    local found = vim.fs.find(venv_name, {
      upward = true,
      path = start_path,
      type = "directory",
    })

    if #found > 0 then
      local venv_path = found[1]
      -- Verify it's actually a virtualenv (has bin/python or Scripts/python.exe)
      local python_path = venv_path .. "/bin/python"
      if vim.fn.executable(python_path) == 1 then
        return venv_path
      end
      -- Windows fallback
      python_path = venv_path .. "/Scripts/python.exe"
      if vim.fn.executable(python_path) == 1 then
        return venv_path
      end
    end
  end

  return nil
end

--- Get the Python executable path for a virtualenv
--- @param venv_path string Path to the virtualenv directory
--- @return string|nil path to the Python executable
function M.get_python_path(venv_path)
  if not venv_path then
    return nil
  end

  -- Unix-like systems
  local python_path = venv_path .. "/bin/python"
  if vim.fn.executable(python_path) == 1 then
    return python_path
  end

  -- Windows
  python_path = venv_path .. "/Scripts/python.exe"
  if vim.fn.executable(python_path) == 1 then
    return python_path
  end

  return nil
end

--- Get the bin directory for a virtualenv
--- @param venv_path string Path to the virtualenv directory
--- @return string|nil path to the bin/Scripts directory
function M.get_bin_path(venv_path)
  if not venv_path then
    return nil
  end

  local bin_path = venv_path .. "/bin"
  if vim.fn.isdirectory(bin_path) == 1 then
    return bin_path
  end

  bin_path = venv_path .. "/Scripts"
  if vim.fn.isdirectory(bin_path) == 1 then
    return bin_path
  end

  return nil
end

--- Update basedpyright configuration with the new Python path
--- @param python_path string Path to the Python executable
function M.notify_lsp(python_path)
  if not python_path then
    return
  end

  -- Update the default config so new clients inherit the python path.
  vim.lsp.config("basedpyright", {
    settings = {
      python = {
        pythonPath = python_path,
      },
    },
  })

  -- Update existing clients in-place (mirrors PyrightSetPythonPath behavior).
  local clients = vim.lsp.get_clients({ name = "basedpyright" })
  local python_settings = { python = { pythonPath = python_path } }
  for _, client in ipairs(clients) do
    if client.settings then
      client.settings = vim.tbl_deep_extend("force", client.settings, python_settings)
    else
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, python_settings)
    end
    client.notify("workspace/didChangeConfiguration", { settings = nil })
  end
end

--- Activate a virtualenv
--- @param venv_path string|nil Path to the virtualenv (nil to auto-detect)
--- @param silent boolean|nil Suppress notifications
function M.activate(venv_path, silent)
  venv_path = venv_path or M.find_venv()

  if not venv_path then
    if not silent then
      vim.notify("No virtualenv found", vim.log.levels.WARN)
    end
    return
  end

  local python_path = M.get_python_path(venv_path)
  if not python_path then
    if not silent then
      vim.notify("Invalid virtualenv: " .. venv_path, vim.log.levels.ERROR)
    end
    return
  end

  M.current_venv = venv_path

  local previous_env = vim.env.VIRTUAL_ENV
  local bin_path = M.get_bin_path(venv_path)

  if not M.base_path then
    M.base_path = vim.env.PATH or ""
    local previous_bin = previous_env and M.get_bin_path(previous_env) or nil
    if previous_bin then
      M.base_path = strip_path_entry(M.base_path, previous_bin, M.path_sep)
    end
  end

  -- Set environment variable and PATH (useful for tools that rely on PATH)
  vim.env.VIRTUAL_ENV = venv_path
  if bin_path then
    vim.env.PATH = bin_path .. M.path_sep .. (M.base_path or "")
    M.current_bin = bin_path
  end

  -- Notify LSP clients
  M.notify_lsp(python_path)

  if not silent then
    vim.notify("Activated: " .. venv_path, vim.log.levels.INFO)
  end
end

--- Deactivate the current virtualenv
function M.deactivate()
  M.current_venv = nil
  vim.env.VIRTUAL_ENV = nil
  if M.base_path then
    vim.env.PATH = M.base_path
  end
  M.current_bin = nil
  vim.notify("Virtualenv deactivated", vim.log.levels.INFO)
end

--- Get the current virtualenv info
--- @return table|nil
function M.get_current()
  if not M.current_venv then
    return nil
  end
  return {
    path = M.current_venv,
    python = M.get_python_path(M.current_venv),
  }
end

--- Select virtualenv using fzf-lua (manual selection)
function M.select()
  local cwd = vim.fn.getcwd()
  local venvs = {}

  -- Find venvs in cwd and subdirectories
  for _, venv_name in ipairs(M.venv_names) do
    local found = vim.fs.find(venv_name, {
      path = cwd,
      type = "directory",
      limit = 10,
    })
    for _, path in ipairs(found) do
      if M.get_python_path(path) then
        table.insert(venvs, path)
      end
    end
  end

  -- Also check parent directories
  local parent_venv = M.find_venv()
  if parent_venv and not vim.tbl_contains(venvs, parent_venv) then
    table.insert(venvs, 1, parent_venv)
  end

  if #venvs == 0 then
    vim.notify("No virtualenvs found", vim.log.levels.WARN)
    return
  end

  -- Use fzf-lua for selection
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.fzf_exec(venvs, {
      prompt = "Select Virtualenv> ",
      actions = {
        ["default"] = function(selected)
          if selected and #selected > 0 then
            M.activate(selected[1])
          end
        end,
      },
    })
  else
    -- Fallback to vim.ui.select
    vim.ui.select(venvs, {
      prompt = "Select Virtualenv:",
    }, function(choice)
      if choice then
        M.activate(choice)
      end
    end)
  end
end

--- Setup function to initialize auto-detection
function M.setup()
  -- Create user commands
  vim.api.nvim_create_user_command("VenvSelect", M.select, {
    desc = "Select Python virtualenv",
  })

  vim.api.nvim_create_user_command("VenvActivate", function(opts)
    M.activate(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Activate Python virtualenv (auto-detect if no path given)",
    complete = "dir",
  })

  vim.api.nvim_create_user_command("VenvDeactivate", M.deactivate, {
    desc = "Deactivate current virtualenv",
  })

  vim.api.nvim_create_user_command("VenvInfo", function()
    local current = M.get_current()
    if current then
      vim.notify(string.format("Venv: %s\nPython: %s", current.path, current.python), vim.log.levels.INFO)
    else
      vim.notify("No virtualenv active", vim.log.levels.INFO)
    end
  end, {
    desc = "Show current virtualenv info",
  })

  -- Auto-detect on DirChanged and VimEnter
  local group = vim.api.nvim_create_augroup("PythonVenv", { clear = true })

  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    group = group,
    callback = function()
      local venv = M.find_venv()
      if venv then
        M.activate(venv, true) -- silent activation
      end
    end,
  })

  -- Also trigger when opening a Python file - search from file's directory
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "python",
    callback = function(event)
      vim.opt_local.colorcolumn = "88,120"

      -- Get the file's directory, not cwd
      local file_path = vim.api.nvim_buf_get_name(event.buf)
      if file_path == "" then
        return
      end
      local file_dir = vim.fn.fnamemodify(file_path, ":h")

      -- Search for venv from the file's directory
      local venv = M.find_venv(file_dir)
      if venv then
        -- Only activate if different from current or no current venv
        if not M.current_venv or M.current_venv ~= venv then
          M.activate(venv, true)
        end
      end
    end,
  })
end

return M
