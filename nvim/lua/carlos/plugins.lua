-- Plugins will be added here accordingly.

--[[
	[X] lazy
		https://github.com/folke/lazy.nvim
	[X] telescope
		https://github.com/nvim-telescope/telescope.nvim
	[X] telescope-fzf-native
		https://github.com/nvim-telescope/telescope-fzf-native.nvim
	[X] nvim-treesitter
		https://github.com/nvim-treesitter/nvim-treesitter
	[X] lspconfig
		https://github.com/neovim/nvim-lspconfig
	[X] neotree
		https://github.com/nvim-neo-tree/neo-tree.nvim
	[X] ripgrep
		https://github.com/BurntSushi/ripgrep
	[X] fd
		https://github.com/sharkdp/fd
	[X] nvim-cmp
		https://www.lazyvim.org/plugins/coding
		https://github.com/hrsh7th/nvim-cmp
	[ ] comment
		https://github.com/numToStr/Comment.nvim
	[X] neodev
		https://github.com/folke/neodev.nvim
	[X] which-key
		https://github.com/folke/which-key.nvim
	[X] alpha-nvim
		https://github.com/goolord/alpha-nvim
	[X] toggleterm
		https://github.com/akinsho/toggleterm.nvim
	[X] typescript + jsx better syntax
		https://github.com/leafgarland/typescript-vim
	[ ] formatter
		https://github.com/mhartington/formatter.nvim
	[ ] open markdown file in markdown-preview.com
		https://github.com/iamcco/markdown-preview.nvim
	[ ] bookmarking files
		https://github.com/otavioschwanck/arrow.nvim
	[ ] toggleterm
		https://github.com/willothy/flatten.nvim
--]]


--[[
	MORE: https://github.com/topics/neovim-colorscheme
	[X] https://github.com/catppuccin/nvim
	[ ] https://github.com/folke/tokyonight.nvim
--]]


return {
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim'
		}
	},
	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release &&' ..
				'cmake --build build --config Release &&' ..
				'cmake --install build --prefix build'
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function () 
		local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = {
					"c",
					"rust",
					"lua",
					"python",
					"javascript",
					"typescript",
					-- "html"
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },  
			})
		end 
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		}
	},
	{
		"neovim/nvim-lspconfig"
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts) require'lsp_signature'.setup(opts) end
	},
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function()
			vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
			local cmp = require("cmp")
			local defaults = require("cmp.config.default")()
			return {
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<S-CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<C-CR>"] = function(fallback)
						cmp.abort()
						fallback()
					end,
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				--[[ formatting = {
					format = function(_, item)
						local icons = require("lazyvim.config").icons.kinds
						if icons[item.kind] then
							item.kind = icons[item.kind] .. item.kind
						end
						return item
					end,
				},
				--]]
				experimental = {
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
				sorting = defaults.sorting,
			}
		end,
		---@param opts cmp.ConfigSchema
		config = function(_, opts)
			for _, source in ipairs(opts.sources) do
				source.group_index = source.group_index or 1
			end
			require("cmp").setup(opts)
		end,
	},
	{ "folke/neodev.nvim", opts = {} },
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},
	{
		'goolord/alpha-nvim',
		-- dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function ()
			-- require'alpha'.setup(require'alpha.themes.startify'.config)
			require'alpha'.setup(require'alpha.themes.dashboard'.config)
		end
	},
	{
		-- amongst your other plugins
		{'akinsho/toggleterm.nvim', version = "*", config = true}
	},
	{
		"leafgarland/typescript-vim",
	},
}
