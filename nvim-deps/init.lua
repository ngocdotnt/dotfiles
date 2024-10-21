-- Initialization ==============================================================
pcall(function() vim.loader.enable() end)
vim.g.mapleader = ' '

-- Define main config table
_G.Config = {
  path_package = vim.fn.stdpath('data') .. '/site/',
  path_source = vim.fn.stdpath('config') .. '/src/',
}
-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
-- local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = Config.path_package .. 'pack/deps/start/mini.nvim'
if not (vim.uv or vim.loop).fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = Config.path_package } })

-- Define helpers
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local src = function(path) dofile(Config.path_source .. path) end

-- Settings and mappings =======================================================
now(function()
  src('settings.lua')
  src('keymaps.lua')
  src('functions.lua')
end)
-- Mini.nvim ===================================================================
add({ name = 'mini.nvim', checkout = 'HEAD' })

-- Add & Config plugin ==============================================================
-- step one
now(function() -- UI
  add('folke/tokyonight.nvim')
  require('tokyonight').setup({
    transparent = true,
    styles = {
      sidebars = 'transparent',
      floats = 'transparent',
    },
  })
  vim.cmd('colorscheme tokyonight')
  -- mini.notify
  local filterout_lua_diagnosing = function(notif_arr)
    local not_diagnosing = function(notif) return not vim.startswith(notif.msg, 'lua_ls: Diagnosing') end
    notif_arr = vim.tbl_filter(not_diagnosing, notif_arr)
    return MiniNotify.default_sort(notif_arr)
  end
  require('mini.notify').setup({
    content = { sort = filterout_lua_diagnosing },
    window = { config = { border = 'double' } },
  })
  vim.notify = MiniNotify.make_notify()
  require('mini.sessions').setup()
  require('mini.starter').setup()
  require('mini.statusline').setup()
  require('mini.tabline').setup()
  require('mini.icons').setup({
    use_file_extension = function(ext, _)
      local suf3, suf4 = ext:sub(-3), ext:sub(-4)
      return suf3 ~= 'scm' and suf3 ~= 'txt' and suf3 ~= 'yml' and suf4 ~= 'json' and suf4 ~= 'yaml'
    end,
  })
  MiniIcons.mock_nvim_web_devicons()
  later(MiniIcons.tweak_lsp_kind)
end)

-- step two ====================================================================
later(function()
  require('mini.extra').setup()
  local ai = require('mini.ai')
  ai.setup({
    custom_textobjects = {
      B = MiniExtra.gen_ai_spec.buffer(),
      F = ai.gen_spec.treesitter({
        a = '@function.outer',
        i = '@function.inner',
      }),
    },
  })
  require('mini.align').setup()
  require('mini.basics').setup({
    options = {
      -- Manage options manually
      basic = false,
    },
    mappings = {
      windows = true,
      move_with_alt = true,
    },
    autocommands = {
      relnum_in_visual_mode = true,
    },
  })
  vim.o.pumblend = 0
  vim.o.winblend = 0
  require('mini.bracketed').setup()
  require('mini.bufremove').setup()
  local miniclue = require('mini.clue')

  miniclue.setup({
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = 'n', keys = '<Leader>' }, -- Leader triggers
      { mode = 'x', keys = '<Leader>' },
      { mode = 'n', keys = [[\]] }, -- mini.basics
      { mode = 'n', keys = '[' }, -- mini.bracketed
      { mode = 'n', keys = ']' },
      { mode = 'x', keys = '[' },
      { mode = 'x', keys = ']' },
      { mode = 'i', keys = '<C-x>' }, -- Built-in completion
      { mode = 'n', keys = 'g' }, -- `g` key
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" }, -- Marks
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' }, -- Registers
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' }, -- Window commands
      { mode = 'n', keys = 'z' }, -- `z` key
      { mode = 'x', keys = 'z' },
    },
    window = { config = { border = 'double' } },
  })
  --
  require('mini.comment').setup()
  require('mini.cursorword').setup()
  require('mini.diff').setup()
  require('mini.doc').setup()
  -- mini.files
  require('mini.files').setup({ windows = { preview = true } })
  local minifiles_augroup = vim.api.nvim_create_augroup('ec-mini-files', {})
  vim.api.nvim_create_autocmd('User', {
    group = minifiles_augroup,
    pattern = 'MiniFilesWindowOpen',
    callback = function(args) vim.api.nvim_win_set_config(args.data.win_id, { border = 'double' }) end,
  })
  vim.api.nvim_create_autocmd('User', {
    group = minifiles_augroup,
    pattern = 'MiniFilesExplorerOpen',
    callback = function()
      MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
      MiniFiles.set_bookmark('m', vim.fn.stdpath('data') .. '/site/pack/deps/start/mini.nvim', { desc = 'mini.nvim' })
      MiniFiles.set_bookmark('p', vim.fn.stdpath('data') .. '/site/pack/deps/opt', { desc = 'Plugins' })
      MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
    end,
  })
  --
  require('mini.git').setup()
  -- hipatterns
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
  --
  require('mini.indentscope').setup()
  require('mini.jump').setup()
  local jump2d = require('mini.jump2d')
  jump2d.setup({
    spotter = jump2d.gen_pattern_spotter('[^%s%p]+'),
    view = { dim = true, n_steps_ahead = 2 },
  })

  require('mini.misc').setup({ make_global = { 'put', 'put_text', 'stat_summary', 'bench_time' } })
  MiniMisc.setup_auto_root()
  -- MiniMisc.setup_termbg_sync()

  -- mini.pick
  require('mini.pick').setup({ window = { config = { border = 'double' } } })
  vim.ui.select = MiniPick.ui_select
  src('mini/pick.lua')
  -- vim.keymap.set('n', ',', [[<Cmd>Pick buf_lines scope='current' preserve_order=true<CR>]], { nowait = true })

  MiniPick.registry.projects = function()
    local cwd = vim.fn.expand('~/repos')
    local choose = function(item)
      vim.schedule(function() MiniPick.builtin.files(nil, { source = { cwd = item.path } }) end)
    end
    return MiniExtra.pickers.explorer({ cwd = cwd }, { source = { choose = choose } })
  end

  require('mini.splitjoin').setup()
  require('mini.move').setup()

  -- Surround
  require('mini.surround').setup({ search_method = 'cover_or_next' })
  -- Disable `s` shortcut (use `cl` instead) for safer usage of 'mini.surround'
  vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')
  --
  require('mini.trailspace').setup()
  require('mini.visits').setup()
end)

-- Dependencies ==============================================================
-- Install Completion
later(function()
  add('hrsh7th/nvim-cmp')
  add('hrsh7th/cmp-nvim-lsp')
  add('hrsh7th/cmp-nvim-lua')
  add('hrsh7th/cmp-path')
  add('hrsh7th/cmp-buffer')
  add('hrsh7th/cmp-cmdline')
  add('L3MON4D3/LuaSnip')
  add('onsails/lspkind.nvim')
  add('rafamadriz/friendly-snippets')
  add('saadparwaiz1/cmp_luasnip')
  src('plugins/nvim-cmp.lua')
end)

-- Tree-sitter: advanced syntax parsing, highlighting, and text objects
later(function()
  local ts_spec = {
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'master',
    hooks = {
      post_checkout = function() vim.cmd('TSUpdate') end,
    },
  }
  add({ source = 'nvim-treesitter/nvim-treesitter-textobjects', depends = { ts_spec } })
  src('plugins/nvim-treesitter.lua')
end)

-- Install LSP/formatting/linter executables
later(function()
  add({
    source = 'williamboman/mason-lspconfig.nvim',
    depends = {
      'williamboman/mason.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
  })
  add('folke/lazydev.nvim')
  src('plugins/mason.lua')
  -- require('mason').setup()
end)

-- Formatting
later(function()
  add('stevearc/conform.nvim')
  src('plugins/conform.lua')
end)

-- Language server configurations
later(function()
  add({
    source = 'neovim/nvim-lspconfig',
    depends = {
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
    },
  })
  src('plugins/lspconfig.lua')
end)

-- -- Snippets
-- later(function()
--   add('L3MON4D3/LuaSnip')
--   local src_file = vim.fn.has('nvim-0.10') == 1 and 'my_snippets.lua' or 'plugins/luasnip.lua'
--   src(src_file)
-- end)

-- Note Talking
later(function()
  add('zk-org/zk-nvim')
  src('plugins/zk-nvim.lua')
  add('jakewvincent/mkdnflow.nvim')
  src('plugins/mkdnflow.lua')
end)

-- editor
later(function()
  add('windwp/nvim-autopairs')
  require('nvim-autopairs').setup()
  add('akinsho/toggleterm.nvim')
  src('plugins/toggleterm.lua')
end)

-- quarto
later(function()
  add('jmbuhr/otter.nvim')
  require('otter').setup({
    verbose = { no_code_found = false },
  })
  add('GCBallesteros/jupytext.nvim')
  add('quarto-dev/quarto-nvim')
  src('plugins/quarto.lua')
  add('HakonHarnes/img-clip.nvim')
  require('img-clip').setup({
    default = {
      dir_path = 'img',
    },
    filetypes = {
      markdown = {
        url_encode_path = true,
        template = '![$CURSOR]($FILE_PATH)',
        drag_and_drop = {
          download_images = false,
        },
      },
      quarto = {
        url_encode_path = true,
        template = '![$CURSOR]($FILE_PATH)',
        drag_and_drop = {
          download_images = false,
        },
      },
    },
  })
end)

-- markdown render and preview
later(function()
  add('MeanderingProgrammer/render-markdown.nvim')
  src('plugins/render-markdown.lua')

  -- local build = function() vim.cmd('!deno task --quiet build:fast') end
  local function build_peek(params)
    later(function()
      vim.cmd('lcd ' .. params.path)
      vim.cmd('!deno task --quiet build:fast')
      vim.cmd('lcd -')
    end)
  end
  add({
    source = 'saimo/peek.nvim',
    hooks = {
      post_install = build_peek,
      post_checkout = build_peek,
    },
  })
  src('plugins/peek.lua')
end)

-- image paste link & image view
later(function()
  add('HakonHarnes/img-clip.nvim')
  src('plugins/img-clip.lua')

  -- add('3rd/image.nvim') -- not support for windows (ioctl system call)
  -- src('plugins/image.lua')
end)
