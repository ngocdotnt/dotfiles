require('peek').setup({ theme = 'light', filetype = { 'markdown' }, app = 'browser' })

vim.keymap.set('n', '<leader>np', function()
  local peek = require('peek')
  if peek.is_open() then
    peek.close()
  else
    peek.open()
  end
end, { desc = 'Peek Markdown Preview', silent = true })
