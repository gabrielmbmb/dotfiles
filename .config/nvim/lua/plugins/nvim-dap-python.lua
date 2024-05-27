return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      keys = {
        {
          "<leader>dPt",
          function()
            require("dap-python").test_method()
          end,
          desc = "Debug Method",
        },
        {
          "<leader>dPc",
          function()
            require("dap-python").test_class()
          end,
          desc = "Debug Class",
        },
      },
      config = function()
        -- do nothing to override default configuration
      end,
    },
    opts = function()
      -- Load VSCode configurations
      require("dap.ext.vscode").load_launchjs()
    end,
  },
}
