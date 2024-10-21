-- preconfig ==================================================================
local lspconfig = require('lspconfig')
local diagnostic_opts = {
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
}
vim.diagnostic.config(diagnostic_opts)

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          -- Get the language server to recognize common globals
          globals = { 'vim', 'describe', 'it', 'before_each', 'after_each' },
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
  },
  marksman = {},
  pyright = {
    -- capabilities = capabilities,
    settings = {
      pyright = {
        disableOrganizeImports = true,
        disableTaggedHints = true,
      },
      python = {
        analysis = {
          ignore = { '*' },
        },
      },
    },
  },
  r_language_server = {
    settings = {
      r = {
        lsp = {
          rich_documentation = false,
        },
      },
    },
  },
}

-- list server not need config
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  'stylua',
  'prettierd',
  'markdownlint',
})

-- global handlers
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
-- local handlers
local handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
}

-- capabilities: used to enable autocompletion (assign to every lsp server config)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
capabilities = vim.tbl_deep_extend('force', capabilities, {
  workspace = {
    fileOperations = {
      didRename = true,
      willRename = true,
    },
  },
})

-- auto config =================================================================
require('lazydev').setup()
require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      server.handlers = vim.tbl_deep_extend('force', {}, handlers, server.handlers or {})
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      lspconfig[server_name].setup(server)
    end,
  },
})

-- manual config ===============================================================
local mason_registry = require('mason-registry')

-- zk
lspconfig.zk.setup({
  handlers = handlers,
  cmd = { 'zk', 'lsp' },
  name = 'zk',
})

-- pwsh
local bundle_path = mason_registry.get_package('powershell-editor-services'):get_install_path()
lspconfig.powershell_es.setup({
  handlers = handlers,
  bundle_path = bundle_path,
  settings = {
    powershell = {
      codeFormatting = { Preset = 'Stroustrup' },
    },
  },
})
