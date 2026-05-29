local M = {}

-- rustfmt's default `max_width` is 100, the most common Rust column length.
M.colorcolumn = "100"

--- Setup function to initialize Rust-specific filetype behaviour
function M.setup()
  local group = vim.api.nvim_create_augroup("RustConfig", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "rust",
    callback = function()
      vim.opt_local.colorcolumn = M.colorcolumn
    end,
  })
end

return M
