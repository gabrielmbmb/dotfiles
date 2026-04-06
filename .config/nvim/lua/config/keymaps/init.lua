local map = vim.keymap.set

local function goto_definition_first()
	vim.lsp.buf.definition({
		on_list = function(opts)
			local items = opts.items or {}
			if vim.tbl_isempty(items) then
				vim.notify("No definition found", vim.log.levels.WARN)
				return
			end

			local item = items[1]
			if item.bufnr and vim.api.nvim_buf_is_loaded(item.bufnr) then
				vim.api.nvim_set_current_buf(item.bufnr)
			elseif item.filename then
				vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
			end

			if item.lnum and item.col then
				vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
			end
		end,
	})
end

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

map("n", "<leader>wv", "<cmd>rightbelow vnew<cr>", { silent = true, desc = "New buffer vertical split (right)" })
map("n", "<leader>wh", "<cmd>belowright new<cr>", { silent = true, desc = "New buffer horizontal split (bottom)" })
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "Window: Focus left" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "Window: Focus down" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "Window: Focus up" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "Window: Focus right" })

-- LSP keymaps (buffer-local)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local lsp_map = function(lhs, rhs, desc)
			map("n", lhs, rhs, { buffer = event.buf, desc = desc })
		end

		lsp_map("gd", goto_definition_first, "LSP: Go to definition")
		lsp_map("gy", vim.lsp.buf.type_definition, "LSP: Go to type definition")
		lsp_map("gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
		lsp_map("gr", vim.lsp.buf.references, "LSP: List references")
		lsp_map("gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
		lsp_map("K", vim.lsp.buf.hover, "LSP: Hover documentation")
		lsp_map("<leader>rn", vim.lsp.buf.rename, "LSP: Rename symbol")
		lsp_map("<leader>cr", vim.lsp.buf.rename, "LSP: Rename symbol")
		lsp_map("<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")

		lsp_map("<leader>ds", vim.diagnostic.open_float, "Diagnostics: Line diagnostics")
		lsp_map("[d", vim.diagnostic.goto_prev, "Diagnostics: Previous")
		lsp_map("]d", vim.diagnostic.goto_next, "Diagnostics: Next")
	end,
})

-- Python virtualenv
map("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Venv: Select" })
map("n", "<leader>va", "<cmd>VenvActivate<cr>", { desc = "Venv: Auto-activate" })
map("n", "<leader>vi", "<cmd>VenvInfo<cr>", { desc = "Venv: Info" })
