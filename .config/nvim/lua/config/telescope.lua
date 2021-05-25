local vimp = require('vimp')

vimp.nnoremap('<leader>ff', '<cmd>Telescope find_files theme=get_dropdown previewer=false<cr>')
vimp.nnoremap('<leader>fg', '<cmd>Telescope git_files<cr>')
vimp.nnoremap('<leader>fp', '<cmd>Telescope live_grep<cr>')
vimp.nnoremap('<leader>fb', '<cmd>Telescope buffers show_all_buffers=true sort_lastused=true<cr>')
vimp.nnoremap('<leader>fh', '<cmd>Telescope help_tags<cr>')
