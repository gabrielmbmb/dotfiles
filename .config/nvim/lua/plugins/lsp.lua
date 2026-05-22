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
				"ruff",
				"ty",
				"vtsls",
				"zls",
				"svelte",
				"clangd",
				"cmake",
			},
			automatic_enable = { exclude = { "stylua", "basedpyright" } },
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

			-- Keep auxiliary Python servers from returning duplicate fzf-lua symbols.
			-- Ty remains the Python symbol source.
			local symbol_methods = {
				["textDocument/documentSymbol"] = true,
				["workspace/symbol"] = true,
			}

			local function disable_symbol_providers(client)
				client.server_capabilities.documentSymbolProvider = false
				client.server_capabilities.workspaceSymbolProvider = false

				-- Some servers can dynamically register capabilities after attach. fzf-lua
				-- uses client:supports_method(), so force these methods off as well.
				if client._fzf_symbols_disabled then
					return
				end

				client._fzf_symbols_disabled = true
				local supports_method = client.supports_method
				client.supports_method = function(self, method, ...)
					if type(self) == "string" then
						method = self
						self = client
					end
					if symbol_methods[method] then
						return false
					end
					return supports_method(self, method, ...)
				end
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("PythonLspSymbols", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.name ~= "ty" and vim.bo[event.buf].filetype == "python" then
						disable_symbol_providers(client)
					end
				end,
			})

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
				on_attach = disable_symbol_providers,
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
