vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false

vim.o.splitright = true
vim.o.splitbelow = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Default indentation for new/empty files; guess-indent overrides it per buffer
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250

-- Prevent bare Space from falling back to its default Normal-mode motion
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.cursorline = true
vim.o.scrolloff = 10

vim.o.signcolumn = "yes"

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Show diagnostics as virtual text, open float automatically when navigating with [d and ]d
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	virtual_text = true,

	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({
				bufnr = bufnr,
				scope = "cursor",
				focus = false,
			})
		end,
	},
})

-- Highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("yank-highlight", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("autoreload", { clear = true }),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({ gh("folke/tokyonight.nvim") })
require("tokyonight").setup()
vim.cmd.colorscheme("tokyonight-night")

vim.pack.add({ gh("nvim-mini/mini.nvim") })

-- Icons
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- Statusline
do
	vim.o.showcmd = true
	vim.o.showcmdloc = "statusline"
	vim.pack.add({ gh("nvim-lualine/lualine.nvim") })
	local function macro_recording()
		local register = vim.fn.reg_recording()

		if register == "" then
			return ""
		end

		return "Recording " .. register
	end
	require("lualine").setup({
		options = { section_separators = "", component_separators = "" },
		sections = {
			lualine_c = { { "filename", path = 1 } },
			lualine_x = { macro_recording, "%S" },
		},
	})
	vim.api.nvim_create_autocmd({
		"RecordingEnter",
		"RecordingLeave",
	}, {
		group = vim.api.nvim_create_augroup("lualine-macro", { clear = true }),
		callback = function()
			vim.schedule(function()
				require("lualine").refresh({
					scope = "all",
					place = { "statusline" },
					force = true,
				})
			end)
		end,
	})
end

-- s for flash
vim.pack.add({ gh("folke/flash.nvim") })
require("flash").setup({
	modes = {
		search = { enabled = false },
		char = { enabled = false },
	},
})
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })

-- For the picker
vim.pack.add({ gh("folke/snacks.nvim") })
require("snacks").setup({
	picker = { ui_select = true },
})

-- Pickers
do
	local function diagnostics()
		local current_buf = vim.api.nvim_get_current_buf()

		Snacks.picker({
			title = "Diagnostics",
			multi = {
				"diagnostics_buffer",
				{
					source = "diagnostics",
					filter = {
						cwd = true,
						filter = function(item)
							return item.buf ~= current_buf
						end,
					},
				},
			},
			matcher = { sort_empty = true },
			sort = {
				fields = { "source_id", "score:desc", "severity", "file", "lnum" },
			},
		})
	end

	vim.keymap.set("n", "<leader>f", Snacks.picker.smart)
	vim.keymap.set("n", "<leader>b", Snacks.picker.buffers)
	vim.keymap.set("n", "<leader>/", Snacks.picker.lines)
	vim.keymap.set("n", "<leader>?", Snacks.picker.grep)
	vim.keymap.set("n", "<leader>!", diagnostics)
	vim.keymap.set("n", "<leader>s", Snacks.picker.lsp_symbols)
	vim.keymap.set("n", "<leader>S", Snacks.picker.lsp_workspace_symbols)
	vim.keymap.set("n", "<leader>d", Snacks.picker.lsp_definitions)
	vim.keymap.set("n", "<leader>i", Snacks.picker.lsp_implementations)
	vim.keymap.set("n", "<leader>u", Snacks.picker.lsp_references)
	vim.keymap.set("n", "<leader><leader>", Snacks.picker.resume)
end

-- Find and replace
do
	vim.pack.add({ gh("MagicDuck/grug-far.nvim") })
	require("grug-far").setup({})

	vim.keymap.set({ "n", "x" }, "<leader>R", function()
		require("grug-far").open({
			transient = true,
			visualSelectionUsage = "auto-detect",
		})
	end, { desc = "Find and replace" })
end

-- Jumplist
do
	vim.keymap.set("n", "<leader>j", Snacks.picker.jumps)
end

-- Noice notifications, vim.notify, LSP messages, cmdline, etc
do
	-- Used by noice
	vim.pack.add({ gh("MunifTanjim/nui.nvim") })

	-- Display cmdline, vim.notify, and LSP in a nicer way
	vim.pack.add({ gh("folke/noice.nvim") })
	require("noice").setup({})
end

-- LSP
do
	vim.pack.add({
		gh("mason-org/mason.nvim"),
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})
	require("mason").setup()
	require("mason-lspconfig").setup()
	require("mason-tool-installer").setup({
		ensure_installed = { "ty", "ruff", "lua_ls", "stylua", "gopls" },
	})

	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				workspace = {
					library = { vim.env.VIMRUNTIME },
					checkThirdParty = false,
				},
				format = { enable = false },
			},
		},
	})

	-- LSP actions live on <leader>{r,a,u,i,d}, so remove Neovim's built-in LSP
	-- keybindings. Unlike native commands (gd, S, ...), these are shipped as
	-- actual mappings since 0.11, so they can be deleted. pcall because the set
	-- varies by version (grt is 0.12+); missing ones just no-op. Side benefit:
	-- with no gr* mappings left, plain gr (native replace-char) responds
	-- instantly instead of waiting on the mapping timeout.
	pcall(vim.keymap.del, "n", "grn")
	pcall(vim.keymap.del, { "n", "x" }, "gra")
	pcall(vim.keymap.del, "n", "grr")
	pcall(vim.keymap.del, "n", "gri")
	pcall(vim.keymap.del, "n", "grt")
	pcall(vim.keymap.del, "n", "gO")

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(event)
			local buf = event.buf
			vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = buf })
			vim.keymap.set({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, { buffer = buf })
		end,
	})
end

-- Treesitter
do
	vim.pack.add({ gh("romus204/tree-sitter-manager.nvim") })
	require("tree-sitter-manager").setup({
		ensure_installed = { "go", "python", "lua" },
		nerdfont = true,
	})
	vim.keymap.set({ "n", "x", "o" }, "<A-o>", function()
		require("vim.treesitter._select").select_parent(vim.v.count1)
	end)

	vim.keymap.set({ "n", "x", "o" }, "<A-i>", function()
		require("vim.treesitter._select").select_child(vim.v.count1)
	end)
end

-- Formatting
do
	vim.pack.add({ gh("stevearc/conform.nvim") })
	require("conform").setup({
		default_format_opts = {
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },
		},
	})
	vim.keymap.set({ "n", "v" }, "<leader>=", function()
		require("conform").format()
	end, { desc = "Format buffer" })

	vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
	require("guess-indent").setup({})
end

-- Lazygit
do
	vim.pack.add({ gh("kdheepak/lazygit.nvim") })
	vim.keymap.set({ "n" }, "<leader>g", "<cmd>LazyGit<cr>")
end

-- Completion
do
	vim.pack.add({
		{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
		gh("zbirenbaum/copilot.lua"),
		gh("fang2hou/blink-copilot"),
	})

	-- Copilot client; inline ghost-text suggestions and the panel are off
	-- because completions are surfaced through blink.cmp instead
	require("copilot").setup({
		suggestion = { enabled = false },
		panel = { enabled = false },
		filetypes = {
			["grug-far"] = false,
			["grug-far-history"] = false,
			["grug-far-help"] = false,
		},
	})

	require("blink.cmp").setup({
		keymap = { preset = "default" },
		fuzzy = { implementation = "prefer_rust_with_warning" },
		signature = { enabled = true },
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 0 },
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "copilot" },
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					async = true,

					-- Do not let late Copilot results outrank normal completions.
					score_offset = -10,

					opts = {
						max_completions = 1,
					},
				},
			},
		},
	})
end

-- Yazi
do
	vim.pack.add({
		gh("mikavilpas/yazi.nvim"),
		gh("nvim-lua/plenary.nvim"),
	})
	require("yazi").setup({
		open_for_directories = true,
	})
	vim.g.loaded_netrwPlugin = 1
	vim.keymap.set("n", "<leader>y", "<Cmd>Yazi cwd<Cr>")
	vim.keymap.set("n", "<leader>Y", "<Cmd>Yazi<Cr>")
end

-- Text objects
do
	vim.pack.add({ gh("nvim-treesitter/nvim-treesitter-textobjects") })
	local spec_treesitter = require("mini.ai").gen_spec.treesitter
	require("mini.ai").setup({
		custom_textobjects = {
			f = spec_treesitter({ a = "@call.outer", i = "@call.inner" }),
			F = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
			c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
			a = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
		},
	})
end

-- Surround
do
	require("mini.surround").setup({
		mappings = {
			add = "Sa",
			delete = "Sd",
			find = "Sf",
			find_left = "SF",
			highlight = "Sh",
			replace = "Sr",
			update_n_lines = "Sn",
		},
	})

	-- Bare S would fall back to built-in change-line when a surround chord
	-- times out; make it do nothing instead
	vim.keymap.set({ "n", "x" }, "S", "<Nop>")
end

-- Comments
do
	vim.keymap.set("n", "<leader>c", "gcc", { remap = true })
	vim.keymap.set("v", "<leader>c", "gc", { remap = true })
end

-- Git signs
do
	vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
	require("gitsigns").setup({
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	})
	vim.keymap.set("n", "<leader>h", function()
		require("gitsigns").preview_hunk_inline()
	end, { desc = "Preview hunk inline" })
	vim.keymap.set("n", "<leader>H", function()
		require("gitsigns").reset_hunk()
	end, { desc = "Reset hunk" })
	vim.keymap.set("v", "<leader>H", function()
		require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { desc = "Reset selected lines" })
	vim.keymap.set("n", "]h", function()
		require("gitsigns").nav_hunk("next")
	end, { desc = "Next hunk" })
	vim.keymap.set("n", "[h", function()
		require("gitsigns").nav_hunk("prev")
	end, { desc = "Previous hunk" })
end

-- Zellij navigation: move between windows, falling through to zellij panes
-- at the edges of the editor
do
	vim.pack.add({ gh("swaits/zellij-nav.nvim") })
	require("zellij-nav").setup()

	vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>ZellijNavigateLeftTab<cr>", { desc = "Navigate left (or tab)" })
	vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>ZellijNavigateDown<cr>", { desc = "Navigate down" })
	vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>ZellijNavigateUp<cr>", { desc = "Navigate up" })
	vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>ZellijNavigateRightTab<cr>", { desc = "Navigate right (or tab)" })
end
