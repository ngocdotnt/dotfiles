require('render-markdown').setup({
  file_type = { 'markdown', 'quarto' },
  pipe_table = {
    border = { '╭', '┬', '╮', '├', '┼', '┤', '╰', '┴', '╯', '│', '─' },
  },
  code = {
    width = 'block',
    left_pad = 2,
    right_pad = 2,
  },
})
