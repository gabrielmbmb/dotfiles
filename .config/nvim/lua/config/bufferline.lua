local vimp = require('vimp')

require('bufferline').setup {
    options = {
        view = 'multiwindow',
        numbers = 'both',
        number_style = { 'superscript', 'subscript' },
        mappings = true,
        indicator_icon = '▎',
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        diagnostics = false,
        diagnostics_indicator = function(count, level, diagnostics_dict)
            return '('..count..')'
        end,
        offsets = {{filetype = 'NvimTree', text = 'File Explorer', text_align = 'left'}},
        show_buffer_icons = true, 
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true, 
        separator_style = 'slant',
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        sort_by = 'extension'
    }
}

-- Mappings

-- Navigate through buffers
vimp.nmap(']b', '<cmd>BufferLineCycleNext<CR>')
vimp.nmap('b]', '<cmd>BufferLineCyclePrev<CR>')

-- Move current buffer backwards or forwards
vimp.nmap('<leader>bn', '<cmd>BufferLineMoveNext<CR>')
vimp.nmap('<leader>bp', '<cmd>BufferLineMovePrev<CR>')

-- Sort buffers
vimp.nmap('<leader>be', '<cmd>BufferLineSortByExtension<CR>')
vimp.nmap('<leader>bd', '<cmd>BufferLineSortByDirectory<CR>')
