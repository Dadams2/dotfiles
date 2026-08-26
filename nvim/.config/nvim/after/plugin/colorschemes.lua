-- Holds all the colour schemes (The ones to rotate through)

local colourSchemes = {
	"catppuccin",
	"nord",
	"kanagawa",
	"tokyonight",
	"ashen",
	"onedark",
	"evergarden",
	"elflord",
	"edge",
}

vim.o.winblend = 0
-- Make cattpucing work a bit better
require("catppuccin").setup({
	flavour = "frappe",
	transparent_background = true,
	term_colors = false,
	integrations = {
		treesitter = true,
		native_lsp = {
			enabled = true,
			virtual_text = { errors = "italic", hints = "italic", warnings = "italic", information = "italic" },
			underlines = {
				errors = "underline",
				hints = "underline",
				warnings = "underline",
				information = "underline",
			},
		},
		lsp_trouble = false,
		lsp_saga = false,
		gitgutter = false,
		gitsigns = true,
		telescope = true,
		nvimtree = true,
		which_key = true,
		indent_blankline = { enabled = true, colored_indent_levels = true },
		dashboard = true,
		neogit = false,
		vim_sneak = false,
		fern = false,
		barbar = false,
		bufferline = true,
		markdown = false,
		lightspeed = false,
		ts_rainbow = true,
		hop = false,
	},
})

local currentColour = 1
local transparent = true

local function setIndentColour()
	vim.cmd.highlight("IndentLine guifg=#4c4b59") -- Sets the indent colour (unselected)
end

local function makeTransparent()
	-- Removed "NormalFloat" from the list to keep highlighting
	local groups = { "Normal", "FloatBorder", "Pmenu" }
	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, { bg = "NONE" })
	end
end

-- Initial Setup
vim.cmd([[colorscheme ]] .. colourSchemes[currentColour])
setIndentColour()

vim.keymap.set("n", "<leader>n", function()
	currentColour = currentColour % #colourSchemes + 1
	vim.cmd("colorscheme " .. colourSchemes[currentColour])
	if transparent then
		makeTransparent()
	end
	setIndentColour()
end)

vim.keymap.set("n", "<leader><leader>n", function()
	if not transparent then
		makeTransparent()
		setIndentColour()
	else
		vim.cmd("colorscheme " .. colourSchemes[currentColour])
	end
	transparent = not transparent
end)
