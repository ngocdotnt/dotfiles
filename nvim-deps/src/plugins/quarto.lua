require('quarto').setup({
  debug = false,
  lspFeatures = {
    enabled = true,
    languages = { 'r', 'python', 'julia', 'lua' },
    diagnostics = {
      enabled = true,
      triggers = { 'BufWrite' },
    },
  },
  completion = {
    enabled = true,
  },
  keymap = {
    hover = 'K',
    definition = 'gd',
  },
})

require('jupytext').setup({
  custom_language_formatting = {
    python = {
      extension = 'qmd',
      style = 'quarto',
      force_ft = 'quarto,',
    },
    r = {
      extension = 'qmd',
      style = 'quarto',
      force_ft = 'quarto',
    },
  },
})
