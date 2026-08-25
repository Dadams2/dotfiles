require("mason").setup()

vim.lsp.enable("pyright")
vim.lsp.enable("lua_ls")

vim.diagnostic.config({
    virtual_lines = true, -- this enables multi line diagnostics
    severity_sort = true,

    -- virtual_text = true, -- this enables inline diagnostics signs = true,
    underline = true,
    update_in_insert = false,
})


-- TODO document what these do for which key
-- Keymaps to supress and unsupress diagnostics
vim.keymap.set("n", "<leader><leader>r", function()
	vim.diagnostic.enable(false, { bufnr = 0 })
end)
vim.keymap.set("n", "<leader><leader>e", function()
	vim.diagnostic.enable(true, { bufnr = 0 })
end)
