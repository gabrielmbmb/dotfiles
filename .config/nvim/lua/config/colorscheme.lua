local utils = require('utils')
local cmd = vim.cmd

utils.opt('o', 'termguicolors', true)
vim.g.tokyonight_style = 'night'
cmd 'colorscheme tokyonight'
