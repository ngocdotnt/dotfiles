require('img-clip').setup({
  default = {
    prompt_for_file_name = false,
    file_name = '%y%m%d-%H%M%S',
    extension = 'webp',
    process_cmd = 'convert - -quality 75 webp:-',
  },

  filetypes = {
    markdown = {
      url_encode_path = true,

      template = '![Image]($FILE_PATH)',
    },
  },
})
