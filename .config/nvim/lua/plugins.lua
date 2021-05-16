return require('packer').startup(function()
    
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    -- Theme
    use {'folke/tokyonight.nvim'}

    -- Status line
    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }

    -- File tree
    use {'kyazdani42/nvim-tree.lua'}

    -- Tabs
    -- use {'romgrk/barbar.nvim'}

    -- Tmux
    use {'christoomey/vim-tmux-navigator'}

    -- Fuzzy finder
    use {'nvim-lua/popup.nvim'}
    use {'nvim-lua/plenary.nvim'}
    use {'nvim-telescope/telescope.nvim'}

   -- TODOs
    use {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim"
    }

    -- Completion and make vim like VSCode
    use {
        'neoclide/coc.nvim',
        branch = 'release'
    }

    -- Git
    use {'airblade/vim-gitgutter'}

    -- Signs
    use {
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'}
    }

    -- Vue
    use {'posva/vim-vue'}

    -- Go
    use {
        'fatih/vim-go',
        run = ':GoUpdateBinaries'
    }

    -- HTML
    use {'alvan/vim-closetag'}
end)
