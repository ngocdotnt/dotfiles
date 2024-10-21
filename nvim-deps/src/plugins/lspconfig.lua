-- base on gfvioli and scottmckendry
-- Declaration ================================================================
local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local mason_lspconfig = require('mason-lspconfig')

-- Keymap -> src/keymappings.lua or after/plugin/lspkeymaps.lua ===============

-- Preconfig ==================================================================
-- Diagnostic configs
vim.diagnostic.config({
  float = { border = 'double' },
  -- Show gutter sings
  signs = {
    -- With highest priority
    priority = 9999,
    -- Only for warnings and errors
    severity = { min = 'WARN', max = 'ERROR' },
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = '󰠠 ',
      [vim.diagnostic.severity.INFO] = ' ',
    },
    texthl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarning',
      [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
      [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
    },
  },
  -- Show virtual text only for errors
  virtual_text = { severity = { min = 'ERROR', max = 'ERROR' } },
  -- Don't update diagnostics when typing
  update_in_insert = false,
})

-- Handlers settings (border)
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

-- Capabilities settings
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
capabilities = vim.tbl_deep_extend('force', capabilities, {
  workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = false,
    },
    fileOperations = {
      didRename = true,
      willRename = true,
    },
  },
})

-- LSP config for server installed via mason ==================================
mason_lspconfig.setup_handlers({
  -- default handler for installed servers (no need config)
  function(server_name)
    lspconfig[server_name].setup({
      capabilities = capabilities,
    })
  end,
  -- servers need addition configs
  ['lua_ls'] = function()
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            -- Get the language server to recognize common globals
            globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'Mini*' },
            disable = { 'need-check-nil', 'missing-fields' },
            -- Don't make workspace diagnostic, as it consumes too much CPU and RAM
            workspaceDelay = -1,
          },
          completion = {
            callSnippet = 'Replace',
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
        },
      },
    })
  end,

  ['ruff'] = function()
    lspconfig.ruff.setup({
      capabilities = capabilities,
      init_options = {
        settings = {
          -- Any extra CLI arguments for `ruff` go here.
          args = {
            organizeImports = true,
          },
        },
      },
    })
  end,

  ['pyright'] = function()
    lspconfig.pyright.setup({
      capabilities = capabilities,
      settings = {
        pyright = {
          disableOrganizeImports = true,
          disableTaggedHints = true,
        },
        python = {
          analysis = {
            ignore = { '*' },
            -- typeCheckingMode = 'off',
          },
        },
      },
    })
  end,

  -- ['r_language_server'] = function()
  --   lspconfig.r_language_server.setup({
  --     capabilities = capabilities,
  --     settings = {
  --       r = {
  --         lsp = {
  --           rich_documentation = false,
  --         },
  --       },
  --     },
  --   })
  -- end,
})

-- LSP config for servers installed via other package managers
local mason_registry = require('mason-registry')
local bundle_path = mason_registry.get_package('powershell-editor-services'):get_install_path()

lspconfig.powershell_es.setup({
  bundle_path = bundle_path,
  settings = {
    powershell = {
      codeFormatting = { Preset = 'Stroustrup' },
    },
  },
})

lspconfig.zk.setup({
  -- capabilities = capabilities,
  -- name = 'zk',
  cmd = { 'zk', 'lsp' },
  filetypes = { 'markdown' },
  root_dir = '.zk',
})
