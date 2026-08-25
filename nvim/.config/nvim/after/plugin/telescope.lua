require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous"
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}



local builtin = require("telescope.builtin")

-- Telescope
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>r", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })


vim.api.nvim_create_autocmd('LspAttach', {
group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
callback = function(event)
  local buf = event.buf

  -- Find references for the word under your cursor.
  vim.keymap.set('n', 'gR', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

  -- Jump to the implementation of the word under your cursor.
  -- Useful when your language has ways of declaring types without an actual implementation.
  vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

  -- Jump to the definition of the word under your cursor.
  -- This is where a variable was first declared, or where a function is defined, etc.
  -- To jump back, press <C-t>.
  vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

  -- Fuzzy find all the symbols in your current document.
  -- Symbols are things like variables, functions, types, etc.
  vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

  -- Fuzzy find all the symbols in your current workspace.
  -- Similar to document symbols, except searches over your entire project.
  vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

  -- Jump to the type of the word under your cursor.
  -- Useful when you're not sure what type a variable is and you want to see
  -- the definition of its *type*, not where it was *defined*.
  vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
end,
})

-- Other searchers courtesy of kickstart.nvim
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
-- vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
-- vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
-- vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
-- vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
-- vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
-- vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
