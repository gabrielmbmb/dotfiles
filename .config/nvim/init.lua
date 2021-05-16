vim.g.mapleader = ' '

local fn = vim.fn
local execute = vim.api.nvim_command

-- Auto install vim-plug
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua

-- Tell Nvim which virtualenv has installed the package 'neovim'
vim.g.python_host_prog = '$HOME/.pyenv/versions/neovim2/bin/python'
vim.g.python3_host_prog = '$HOME/.pyenv/versions/neovim/bin/python'

-- Sensible defaults
require('settings')

-- Key mappings
require('keymappings')

-- Plugin config
require('config')
