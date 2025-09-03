if vim.g.vscode then
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimKeymapsDefaults",
        callback = function()
            vim.keymap.set("n", "<leader>w", [[<cmd>lua require('vscode').action('workbench.action.switchWindow')<cr>]],
                {
                    nowait = true
                })
            vim.keymap.set("n", "<leader>f", [[<cmd>lua require('vscode').action('editor.action.formatDocument')<cr>]],
                {
                    nowait = true
                })
        end
    })
end

return {}
