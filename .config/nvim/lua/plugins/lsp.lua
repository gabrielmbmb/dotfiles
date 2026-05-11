return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				vim.env.VIMRUNTIME,
			},
		},
	},

	-- Mason manages LSP servers
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	-- Bridges mason <-> lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"basedpyright",
				"ruff",
				"ty",
				"vtsls",
				"zls",
				"svelte",
				"clangd",
				"cmake",
			},
			automatic_enable = { exclude = { "stylua" } },
		},
	},

	-- LSP config
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"folke/lazydev.nvim",
		},
		config = function()
			local lspconfig = vim.lsp.config
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local ts_root_files = { "bun.lockb", "package.json", "tsconfig.json", "jsconfig.json", ".git" }

			local function mason_bin(name)
				local path = vim.fn.stdpath("data") .. "/mason/bin/" .. name
				return vim.fn.executable(path) == 1 and path or name
			end

			lspconfig("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
							},
						},
						telemetry = { enable = false },
					},
				},
			})

			lspconfig("rust_analyzer", {
				capabilities = capabilities,
				cmd = { mason_bin("rust-analyzer") },
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allTargets = true,
							autoreload = true,
						},
						check = {
							allTargets = true,
							command = "check",
							workspace = true,
						},
						diagnostics = {
							enable = true,
						},
						procMacro = {
							enable = true,
						},
					},
				},
			})

			lspconfig("basedpyright", {
				capabilities = capabilities,
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "off",
						},
					},
					python = {
						pythonPath = (function()
							local py = require("config.python")
							local venv = py.find_venv()
							return venv and py.get_python_path(venv) or nil
						end)(),
					},
				},
			})

			lspconfig("vtsls", {
				capabilities = capabilities,
				root_dir = function(bufnr, cb)
					cb(vim.fs.root(bufnr, ts_root_files))
				end,
			})

			lspconfig("svelte", {
				capabilities = capabilities,
			})

			lspconfig("ty", {
				capabilities = capabilities,
				settings = {
					ty = {},
				},
			})

			lspconfig("ruff", {
				capabilities = capabilities,
			})

			lspconfig("zls", {
				capabilities = capabilities,
			})

			lspconfig("clangd", {
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--completion-style=detailed",
					"--header-insertion=iwyu",
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
			})

			lspconfig("cmake", {
				capabilities = capabilities,
			})
		end,
	},
}
