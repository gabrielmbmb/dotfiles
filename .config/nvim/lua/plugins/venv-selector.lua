return {
  "linux-cultist/venv-selector.nvim",
  cmd = "VenvSelect",
  opts = {
    dap_enabled = true,
    name = {
      "venv",
      ".venv",
    },
    notify_user_on_activate = true,
  },
  keys = {
    { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" },
  },
}
