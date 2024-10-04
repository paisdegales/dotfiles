Telescope = require('telescope.builtin')
Neotree = require('neo-tree.command')
Toggleterm = require('toggleterm')

Telescope_search_all_manpages = function()
	Telescope.man_pages({sections = {'ALL'}})
end

Neotree_edit_myfolder = function()
	local xdg_config_path = os.getenv('XDG_CONFIG_HOME')
	local my_config_path = xdg_config_path .. '/nvim/lua/carlos'
	Neotree.execute({
		dir = my_config_path,
		toggle = true,
	})
end

Neotree_toggle = function()
	Neotree.execute({
		toggle = true
	})
end

vim.keymap.set('n', '<leader>f', Telescope.find_files, {desc = "Perform filename search in cwd"})
vim.keymap.set('n', '<leader>s', Telescope.live_grep, {desc = 'Perform string search in cwd'})
vim.keymap.set('n', '<leader>b', Telescope.buffers, {desc = 'Perform filename search in neovim\'s buffer list'})
vim.keymap.set('n', '<leader>h', Telescope.help_tags, {desc = 'Search for help within neovim help tags'})
vim.keymap.set('n', '<leader>m', Telescope_search_all_manpages, {desc = 'Search for a manpage'})

vim.keymap.set('n', '<leader>e', Neotree_toggle, {desc = 'Toggle Neotree side panel'})
vim.keymap.set('n', '<leader>p', Neotree_edit_myfolder, { desc = 'Edit Lazy\'s plugins file' })

vim.keymap.set('n', '\\', Toggleterm.toggle, {desc = 'Edit Lazy\'s plugins file'})
vim.keymap.set('t', '\\', Toggleterm.toggle, {desc = 'Edit Lazy\'s plugins file'})

-- See `:help vim.diagnostic.*` for more
vim.keymap.set('n', '<space>g', vim.diagnostic.open_float, {desc = 'Open diagnosis floating panel'})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {desc = 'Goto previous error'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {desc = 'Goto next error'})

vim.keymap.set('n', '<leader>i', '<Cmd>edit /home/carlos/.config/nvim/init.lua <CR>', {desc = 'Edit init.lua'})
vim.keymap.set('x', '<leader>y', '"+y', {desc = 'Copy to system clipboard'})
vim.keymap.set('n', '<S-Esc>', ':noh<CR>', {desc = 'Unhighlight previous search highlight'})
