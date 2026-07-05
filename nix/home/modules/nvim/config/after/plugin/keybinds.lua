-- Move lines up/down
vim.keymap.set('n', '<A-Down>', ':m .+1<CR>==',        { silent = true })
vim.keymap.set('n', '<A-Up>',   ':m .-2<CR>==',        { silent = true })
vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv",    { silent = true })
vim.keymap.set('v', '<A-Up>',   ":m '<-2<CR>gv=gv",    { silent = true })
vim.keymap.set('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('i', '<A-Up>',   '<Esc>:m .-2<CR>==gi', { silent = true })

