return require('packer').startup(function()
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    -- Theme
    use {'folke/tokyonight.nvim'}

    -- Status and buffer lines
    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }

    use {
        'akinsho/nvim-bufferline.lua',
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    -- File tree
    use {'kyazdani42/nvim-tree.lua'}

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

    -- Indent guides
    use {
        'lukas-reineke/indent-blankline.nvim',
        branch = 'lua',
    }

    -- Show keybindings cheatsheet in a popup
    use {
        'folke/which-key.nvim',
        config = function()
        require("which-key").setup {}
        end
    }

    -- Markdown preview
    use {
        'npxbr/glow.nvim',
        branch = 'main',
        run = ':GlowInstall',
    }

    -- Commentaries
    use {'b3nj5m1n/kommentary'}

    -- Vimpeccable
    use {'svermeulen/vimpeccable'}

    -- Diffview
    use {'sindrets/diffview.nvim'}

    -- Neovim Lua Development
    use {'tjdevries/nlua.nvim'}
end)
