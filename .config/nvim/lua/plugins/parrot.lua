return {
  "frankroeder/parrot.nvim",
  tag = "v0.5.0",
  dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim", "rcarriga/nvim-notify" },
  config = function()
    require("parrot").setup({
      -- Providers must be explicitly added to make them available.
      providers = {
        anthropic = {
          api_key = os.getenv("ANTHROPIC_API_KEY"),
        },
      },
    })
  end,
}
