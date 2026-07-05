vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 then
      return
    end

    local arg0 = vim.fn.argv(0)

    if type(arg0) ~= 'string' then
      return
    end

    if vim.fn.isdirectory(arg0) ~= 1 then
      return
    end

    vim.api.nvim_set_current_dir(arg0)

    vim.cmd 'enew'
    vim.cmd 'Neotree filesystem reveal left'
  end,
})
