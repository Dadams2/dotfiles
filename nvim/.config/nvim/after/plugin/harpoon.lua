local harpoon = require("harpoon");

harpoon:setup()

vim.keymap.set("n", "<leader>e", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>a", function()
    harpoon:list():add()
end)

for i = 0, 9 do
    vim.keymap.set("n", "<leader>" .. i, function()
        harpoon:list():select(i)
    end)
end

