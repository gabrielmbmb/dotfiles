require('nvim-treesitter.configs').setup {
    ensure_install = 'all',
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = { 'python' }
    },
    context_commentstring = { enable = true }
}
