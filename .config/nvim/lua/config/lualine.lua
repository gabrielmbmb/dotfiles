require('lualine').setup {
    options = {
        theme = 'tokyonight'
    },
    sections = {
        lualine_c = {'filename', 'diff', 'g:coc_status'}
    }
}
