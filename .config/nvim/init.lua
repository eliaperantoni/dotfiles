vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Remove default keymap by vscode-neovim
vim.keymap.del({'n', 'x'}, 'gq')
vim.keymap.del('n', 'gqq')
vim.keymap.del({'n', 'x'}, '=')
vim.keymap.del('n', '==')
-- We like this one, we keep it
-- vim.keymap.del({'n', 'x'}, 'K')
vim.keymap.del({'n', 'x'}, 'gh')
vim.keymap.del({'n', 'x'}, 'gf')
vim.keymap.del({'n', 'x'}, 'gd')
vim.keymap.del({'n', 'x'}, '<C-]>')
vim.keymap.del({'n', 'x'}, 'gO')
vim.keymap.del({'n', 'x'}, 'gF')
vim.keymap.del({'n', 'x'}, 'gD')
vim.keymap.del({'n', 'x'}, 'gH')
vim.keymap.del('n', 'z=')
vim.keymap.del({'n', 'x'}, '<C-w>gf')
vim.keymap.del({'n', 'x'}, '<C-w>gd')

-- Remove default keymap by nvim
vim.keymap.del('n', 'grt')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gra')
vim.keymap.del('n', 'grn')

-- Keymaps
vim.keymap.set('n', 'gd', [[<Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>]])
vim.keymap.set('n', 'gy', [[<Cmd>call VSCodeNotify('editor.action.goToTypeDefinition')<CR>]])
vim.keymap.set('n', 'gr', [[<Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>]])
vim.keymap.set('n', '<leader>r', [[<Cmd>call VSCodeNotify('editor.action.rename')<CR>]])
vim.keymap.set('n', '<leader>f', [[<Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>]])
vim.keymap.set('n', '<leader>w', [[<Cmd>call VSCodeNotify('workbench.action.switchWindow')<CR>]])

-- Move tabs
vim.keymap.set("n", "<S-h>", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
vim.keymap.set("n", "<S-l>", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {
        clear = true
    }),
    callback = function()
        vim.hl.on_yank({
            higroup = "IncSearch"
        })
    end
})


-- Clipboard
-- Keep undo/redo lists in sync with VsCode
vim.keymap.set("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>")
vim.keymap.set("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>")
vim.opt.clipboard = 'unnamedplus'

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Minimal number of screen lines to keep above and below the cursor
-- TODO I'm not sure this actually works in VsCode.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- Make line numbers default
vim.o.number = true

-- Bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {out, "WarningMsg"},
                           {"\nPress any key to exit..."}}, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {{
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        -- stylua: ignore
        keys = {{
            "s",
            mode = {"n", "x", "o"},
            function()
                require("flash").jump()
            end,
            desc = "Flash"
        }, {
            "S",
            mode = {"n", "x", "o"},
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter"
        }}
    }, {
        'nvim-mini/mini.surround',
        version = '*',
        event = "VeryLazy",
        opts = {
            mappings = {
                add = 'ma', -- Add surrounding in Normal and Visual modes
                delete = 'md', -- Delete surrounding
                find = '', -- Find surrounding (to the right)
                find_left = '', -- Find surrounding (to the left)
                highlight = '', -- Highlight surrounding
                replace = 'mr', -- Replace surrounding
                update_n_lines = '', -- Update `n_lines`

                suffix_last = '', -- Suffix to search with "prev" method
                suffix_next = '' -- Suffix to search with "next" method
            }
        }
    }, { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',
        lazy = false,
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs', -- Sets main module to use for opts
        opts = {
            -- Autoinstall languages that are not installed
            auto_install = true,
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-k>", -- set to `false` to disable one of the mappings
                    node_incremental = "<C-k>",
                    scope_incremental = false,
                    node_decremental = "<C-j>"
                }
            },
            textobjects = {
                select = {
                    enable = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                    }
                }
            }
        }
    }, {'nvim-treesitter/nvim-treesitter-textobjects'}}
})

