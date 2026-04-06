local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

if vim.fn.has("nvim-0.9") == 1 then
  opt.statuscolumn = "%C%s%=%{v:relnum?v:relnum:v:lnum} "
end

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Sync Neovim yanks/deletes with the system clipboard.
opt.clipboard = "unnamedplus"

-- Auto-reload files changed outside of Neovim.
opt.autoread = true
local autoread_group = vim.api.nvim_create_augroup("AutoRead", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoread_group,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})
