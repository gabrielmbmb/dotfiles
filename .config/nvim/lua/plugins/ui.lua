local dashboard_rainbow_timers = {}

local function get_nvim_version()
	local v = vim.version()
	if not v or not v.major then
		return "unknown"
	end
	local suffix = v.prerelease and "-dev" or ""
	return string.format("v%d.%d.%d%s", v.major, v.minor, v.patch, suffix)
end

local function get_lazy_version()
	local ok, config = pcall(require, "lazy.core.config")
	if not ok or not config or not config.version then
		return "unknown"
	end
	local version = tostring(config.version)
	if not version:match("^v") then
		version = "v" .. version
	end
	return version
end

local function get_lazy_updates()
	local ok, checker = pcall(require, "lazy.manage.checker")
	if not ok or not checker then
		return nil
	end
	pcall(function()
		checker.fast_check({ report = false })
	end)
	if type(checker.updated) ~= "table" then
		return nil
	end
	return #checker.updated
end

local function get_footer_lines()
	local nvim_version = get_nvim_version()
	local lazy_version = get_lazy_version()
	local updates = get_lazy_updates()
	local updates_text = updates == nil and "?" or tostring(updates)

	return {
		string.format("Neovim %s", nvim_version),
		string.format("lazy.nvim %s", lazy_version),
		string.format("Lazy updates: %s", updates_text),
	}
end

local function setup_dashboard_option_highlights()
	if vim.g.dashboard_option_highlights_setup then
		return
	end

	vim.g.dashboard_option_highlights_setup = true

	local function apply()
		local set_hl = vim.api.nvim_set_hl

		set_hl(0, "DashboardShortCut", { fg = "#565f89", italic = true })

		set_hl(0, "DashboardOptionIconBlue", { fg = "#7aa2f7", bold = true })
		set_hl(0, "DashboardOptionDescBlue", { fg = "#c0caf5", bg = "#1f2335", bold = true })
		set_hl(0, "DashboardOptionKeyBlue", { fg = "#7aa2f7", bg = "#16161e", bold = true })

		set_hl(0, "DashboardOptionIconCyan", { fg = "#7dcfff", bold = true })
		set_hl(0, "DashboardOptionDescCyan", { fg = "#c0caf5", bg = "#17283b", bold = true })
		set_hl(0, "DashboardOptionKeyCyan", { fg = "#7dcfff", bg = "#16161e", bold = true })

		set_hl(0, "DashboardOptionIconGreen", { fg = "#9ece6a", bold = true })
		set_hl(0, "DashboardOptionDescGreen", { fg = "#c0caf5", bg = "#1a2d22", bold = true })
		set_hl(0, "DashboardOptionKeyGreen", { fg = "#9ece6a", bg = "#16161e", bold = true })

		set_hl(0, "DashboardOptionIconPurple", { fg = "#bb9af7", bold = true })
		set_hl(0, "DashboardOptionDescPurple", { fg = "#c0caf5", bg = "#2a203d", bold = true })
		set_hl(0, "DashboardOptionKeyPurple", { fg = "#bb9af7", bg = "#16161e", bold = true })

		set_hl(0, "DashboardOptionIconOrange", { fg = "#ff9e64", bold = true })
		set_hl(0, "DashboardOptionDescOrange", { fg = "#c0caf5", bg = "#35261a", bold = true })
		set_hl(0, "DashboardOptionKeyOrange", { fg = "#ff9e64", bg = "#16161e", bold = true })

		set_hl(0, "DashboardOptionIconRed", { fg = "#f7768e", bold = true })
		set_hl(0, "DashboardOptionDescRed", { fg = "#c0caf5", bg = "#3a1f2a", bold = true })
		set_hl(0, "DashboardOptionKeyRed", { fg = "#f7768e", bg = "#16161e", bold = true })
	end

	apply()

	local group = vim.api.nvim_create_augroup("DashboardOptionHighlights", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = apply,
	})
end

local function setup_dashboard_rainbow(header_len)
	if vim.g.dashboard_rainbow_setup then
		return
	end

	if not header_len or header_len == 0 then
		return
	end

	vim.g.dashboard_rainbow_setup = true

	local rainbow = {
		{ fg = "#ff5f5f", bg = "#2a0f0f" },
		{ fg = "#ff9f43", bg = "#2a1a0a" },
		{ fg = "#ffe66d", bg = "#2a240c" },
		{ fg = "#7dff9e", bg = "#0f2a1a" },
		{ fg = "#5ee6ff", bg = "#0f232a" },
		{ fg = "#5fa8ff", bg = "#0f1a2a" },
		{ fg = "#b28dff", bg = "#1e0f2a" },
	}

	local groups = {}
	for i, color in ipairs(rainbow) do
		local name = "DashboardRainbow" .. i
		groups[i] = name
		vim.api.nvim_set_hl(0, name, { fg = color.fg, bg = color.bg, bold = true })
	end

	local ns = vim.api.nvim_create_namespace("dashboard_rainbow")

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dashboard",
		callback = function(args)
			local buf = args.buf
			if vim.b[buf].dashboard_rainbow_started then
				return
			end
			vim.b[buf].dashboard_rainbow_started = true

			local uv = vim.uv or vim.loop
			local frame = 0
			local timer = uv.new_timer()
			dashboard_rainbow_timers[buf] = timer

			local function render()
				if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
					if timer and not timer:is_closing() then
						timer:stop()
						timer:close()
					end
					return
				end

				vim.api.nvim_buf_clear_namespace(buf, ns, 0, header_len)

				for row = 0, header_len - 1 do
					local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
					if line and line ~= "" then
						local char_count = vim.fn.strchars(line)
						for i = 0, char_count - 1 do
							local char = vim.fn.strcharpart(line, i, 1)
							if char ~= " " then
								local byte_col = vim.fn.byteidx(line, i)
								local group = groups[((i + row + frame) % #groups) + 1]
								vim.api.nvim_buf_set_extmark(buf, ns, row, byte_col, {
									end_col = byte_col + #char,
									hl_group = group,
								})
							end
						end
					end
				end

				frame = frame + 1
			end

			timer:start(0, 80, vim.schedule_wrap(render))

			vim.api.nvim_create_autocmd({ "BufHidden", "BufWipeout" }, {
				buffer = buf,
				once = true,
				callback = function()
					if timer and not timer:is_closing() then
						timer:stop()
						timer:close()
					end
					dashboard_rainbow_timers[buf] = nil
					if vim.api.nvim_buf_is_valid(buf) then
						vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
					end
				end,
			})
		end,
	})
end

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			local footer_lines = get_footer_lines()
			local header = {
				"",
				"",
				"    ▄▄▄▄███▄▄▄▄    ▄██████▄      ███        ▄█    █▄       ▄████████    ▄████████",
				" ▄██▀▀▀███▀▀▀██▄ ███    ███ ▀█████████▄   ███    ███     ███    ███   ███    ███",
				" ███   ███   ███ ███    ███    ▀███▀▀██   ███    ███     ███    █▀    ███    ███",
				" ███   ███   ███ ███    ███     ███   ▀  ▄███▄▄▄▄███▄▄  ▄███▄▄▄      ▄███▄▄▄▄██▀",
				" ███   ███   ███ ███    ███     ███     ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ▀▀███▀▀▀▀▀",
				" ███   ███   ███ ███    ███     ███       ███    ███     ███    █▄  ▀███████████",
				" ███   ███   ███ ███    ███     ███       ███    ███     ███    ███   ███    ███",
				"  ▀█   ███   █▀   ▀██████▀     ▄████▀     ███    █▀      ██████████   ███    ███",
				"                                                                      ███    ███",
				"████████▄   ███    █▄     ▄████████  ▄████████    ▄█   ▄█▄    ▄████████    ▄████████",
				"███    ███  ███    ███   ███    ███ ███    ███   ███ ▄███▀   ███    ███   ███    ███",
				"███    ███  ███    ███   ███    ███ ███    █▀    ███▐██▀     ███    █▀    ███    ███",
				"███    ███  ███    ███   ███    ███ ███         ▄█████▀     ▄███▄▄▄      ▄███▄▄▄▄██▀",
				"███    ███  ███    ███ ▀███████████ ███        ▀▀█████▄    ▀▀███▀▀▀     ▀▀███▀▀▀▀▀",
				"███    ███  ███    ███   ███    ███ ███    █▄    ███▐██▄     ███    █▄  ▀███████████",
				"███  ▀ ███  ███    ███   ███    ███ ███    ███   ███ ▀███▄   ███    ███   ███    ███",
				" ▀██████▀▄█ ████████▀    ███    █▀  ████████▀    ███   ▀█▀   ██████████   ███    ███",
				"                                                 ▀                        ███    ███",
				"",
			}

			return {
				theme = "doom",
				config = {
					header = header,
					center = {
						{
							icon = "󰱼  ",
							icon_hl = "DashboardOptionIconBlue",
							desc = " Explore Project Files ",
							desc_hl = "DashboardOptionDescBlue",
							key = "f",
							keymap = "FZF",
							key_hl = "DashboardOptionKeyBlue",
							key_format = "  < %s >",
							action = "lua require('fzf-lua').files()",
						},
						{
							icon = "󰋚  ",
							icon_hl = "DashboardOptionIconCyan",
							desc = " Resume Recent Files ",
							desc_hl = "DashboardOptionDescCyan",
							key = "r",
							keymap = "MRU",
							key_hl = "DashboardOptionKeyCyan",
							key_format = "  < %s >",
							action = "lua require('fzf-lua').oldfiles()",
						},
						{
							icon = "󰍉  ",
							icon_hl = "DashboardOptionIconGreen",
							desc = " Search Project Text ",
							desc_hl = "DashboardOptionDescGreen",
							key = "g",
							keymap = "GREP",
							key_hl = "DashboardOptionKeyGreen",
							key_format = "  < %s >",
							action = "lua require('fzf-lua').live_grep()",
						},
						{
							icon = "  ",
							icon_hl = "DashboardOptionIconPurple",
							desc = " Create New Buffer ",
							desc_hl = "DashboardOptionDescPurple",
							key = "n",
							keymap = "NEW",
							key_hl = "DashboardOptionKeyPurple",
							key_format = "  < %s >",
							action = "enew",
						},
						{
							icon = "  ",
							icon_hl = "DashboardOptionIconOrange",
							desc = " Open Neovim Config ",
							desc_hl = "DashboardOptionDescOrange",
							key = "c",
							keymap = "INIT",
							key_hl = "DashboardOptionKeyOrange",
							key_format = "  < %s >",
							action = "e $MYVIMRC",
						},
						{
							icon = "󰩈  ",
							icon_hl = "DashboardOptionIconRed",
							desc = " Quit Session ",
							desc_hl = "DashboardOptionDescRed",
							key = "q",
							keymap = "EXIT",
							key_hl = "DashboardOptionKeyRed",
							key_format = "  < %s >",
							action = "qa",
						},
					},
					footer = footer_lines,
				},
			}
		end,
		config = function(_, opts)
			setup_dashboard_option_highlights()
			require("dashboard").setup(opts)
			setup_dashboard_rainbow(#(opts.config.header or {}))

			if vim.fn.argc() == 1 then
				local arg = vim.fn.argv(0)
				if vim.fn.isdirectory(arg) == 1 then
					vim.cmd.cd(arg)
					vim.cmd("Dashboard")
				end
			end

			local dashboard_group = vim.api.nvim_create_augroup("DashboardAutoClose", { clear = true })
			vim.api.nvim_create_autocmd("BufEnter", {
				group = dashboard_group,
				callback = function()
					if vim.bo.filetype == "dashboard" or vim.bo.buftype ~= "" then
						return
					end

					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].filetype == "dashboard" then
							vim.api.nvim_win_close(win, true)
						end
					end
				end,
			})
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy", "dashboard" },
			filesystem = {
				use_libuv_file_watcher = true,
				follow_current_file = { enabled = true },
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)
		end,
		keys = {
			{ "<leader>fe", "<cmd>Neotree toggle<cr>", desc = "Explorer (Neo-tree)" },
		},
	},
}
