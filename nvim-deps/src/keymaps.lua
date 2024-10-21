-- Create global tables with information about clue groups in certain modes
-- Structure of tables is taken to be compatible with 'mini.clue'.
_G.Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
  { mode = 'n', keys = '<Leader>e', desc = '+Explorer' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
  { mode = 'n', keys = '<Leader>l', desc = '+LSP actions' },
  -- { mode = 'n', keys = '<Leader>L', desc = '+Lua' },
  { mode = 'n', keys = '<Leader>m', desc = '+Map & Image' },
  { mode = 'n', keys = '<Leader>n', desc = '+Notes' }, -- after/ftplugin
  { mode = 'n', keys = '<Leader>o', desc = '+Other' },
  { mode = 'n', keys = '<Leader>r', desc = '+R' },
  { mode = 'n', keys = '<Leader>t', desc = '+Terminal/Minitest' },
  { mode = 'n', keys = '<Leader>T', desc = '+Test' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },
  { mode = 'n', keys = '<Leader>q', desc = '+Quit & Session' },
  { mode = 'n', keys = '<Leader>z', desc = '+Zk notes' },

  { mode = 'x', keys = '<Leader>l', desc = '+LSP' },
  { mode = 'x', keys = '<Leader>r', desc = '+R' },
}

-- Define helpers
local map = function(mode, lhs, rhs, desc, opts)
  opts = opts or { noremap = true, silent = true }
  opts.desc = desc
  vim.keymap.set(mode, lhs, rhs, opts)
end

local L = function(key) return '<leader>' .. key end
local C = function(cmd) return '<Cmd>' .. cmd .. '<CR>' end
-- local E = function(cmd) return "<Cmd>" .. cmd .. "<CR><Esc>" end

-- Basics ======================================================================
map('n', 'H', C([[lua MiniBracketed.buffer('backward')]]), 'Prev buffer')
map('n', 'L', C([[lua MiniBracketed.buffer('forward')]]), 'Next buffer')
-- Move inside completion list with <TAB>
map('i', '<Tab>', [[pumvisible() ? '<C-n>' : '<Tab>']], 'Next with tab', { expr = true })
map('i', '<S-Tab>', [[pumvisible() ? '<C-p>' : '<S-Tab>']], 'Prev with tab', { expr = true })
-- Delete selection in select mode
map('s', [[<BS>]], [[<BS>i]], 'Delete select')
-- Better command history navigation
map('c', '<C-p>', '<Up>', 'Up', { silent = false })
map('c', '<C-n>', '<Down>', 'Down', { silent = false })

-- mini.diff
local rhs = function() return MiniDiff.operator('yank') .. 'gh' end
map('n', 'ghy', rhs, [[Copy hunk's reference lines]], { expr = true, remap = true })

-- mini.pick
map('n', ',', C([[Pick buf_lines scope='current' preserve_order=true]]), 'Current buffer', { nowait = true })

-- Leader ======================================================================
-- b key for buffers
map('n', L('ba'), C('b#'), 'Other buffer')
map('n', L('bd'), C('lua MiniBufremove.delete()'), 'Delete buffer')
map('n', L('bD'), C('%bd|e#|bd#'), 'Delete other buffers')
map('n', L('bu'), C('lua MiniBufremove.unshow()'), 'Unshow')
map('n', L('bw'), C('lua MiniBufremove.wipeout()'), 'Wipeout')

-- c key for code actions

-- e is for 'explore' and 'edit'
map('n', L('ei'), C('edit $MYVIMRC'), 'Edit init.lua')
map('n', L('ec'), C([[lua MiniFiles.open(vim.fn.stdpath('config'))]]), 'Config')
map('n', L('ed'), C('lua MiniFiles.open()'), 'Directory')
map('n', L('ef'), C('lua MiniFiles.open(vim.api.nvim_buf_get_name(0))'), 'File directory')

-- f for fuzzy find
map('n', L('f/'), C([[Pick history scope='/']]), '/ history')
map('n', L('f:'), C([[Pick history scope=':']]), ': history')
map('n', L('fb'), C([[Pick buffers]]), 'Buffers')
map('n', L('fc'), C([[Pick config]]), 'Configs')
map('n', L('fe'), C([[lua MiniExtra.pickers.explorer()]]), 'File Explorer')
map('n', L('ff'), C([[Pick files]]), 'Files')
map('n', L('fg'), C([[Pick grep_live]]), 'Grep live')
map('n', L('fG'), C([[Pick grep pattern='<cword>']]), 'Grep current word')
map('n', L('fh'), C([[Pick help]]), 'Help tags')
map('n', L('fH'), C([[Pick hl_groups]]), 'Highlight groups')
map('n', L('fL'), C([[Pick buf_lines scope='all']]), 'Lines (all)')
map('n', L('fl'), C([[Pick buf_lines scope='current']]), 'Lines (current)')
map('n', L('fv'), C([[Pick visit_paths cwd=""]]), 'Find visited paths (all)')
map('n', L('fV'), C([[Pick visit_paths]]), 'Find visited paths (cwd)')
map('n', L('f?'), C([[Pick oldfiles]]), 'Find recent files')

-- g key for git
map('n', L('gg'), C([[lua lazygit_toggle()]]), 'Toggle lazygit')

-- l key for LSP actions
map('i', '<C-k>', C('lua vim.lsp.buf.signature_help()'), 'Signature help')
map('n', 'K', C([[lua vim.lsp.buf.hover()]]), 'Display documentation')
map('n', 'gd', C([[Pick lsp scope='definition']]), 'Goto to definition')
map('n', L('ld'), C([[Pick lsp scope='declaration']]), 'Gotto [d]eclaration')
map('n', L('lf'), C([[lua vim.lsp.buf.format({async=true})]]), 'Format current file')
-- map('n', L('li'), C([[lua vim.lsp.buf.implementation()]]), 'List all the [i]mplementations')
map('n', L('li'), C([[Pick lsp scope='implementation']]), 'Goto [I]mplementation')
-- map('n', L('lt'), C([[lua vim.lsp.buf.type_definition()]]), 'Goto [T]ype definition')
map('n', L('lt'), C([[Pick lsp scope='type_definition']]), 'Goto [T]ype definition')
map('n', L('lr'), C([[Pick lsp scope='references']]), 'List all [R]eferences')
map('n', L('ls'), C([[Pick lsp scope='document_symbol']]), 'Symbols buffer')
map('n', L('lS'), C([[Pick lsp scope='workspace_symbol']]), 'Symbols workspace')
map('n', L('ln'), C([[lua vim.lsp.buf.rename()]]), 'Re[n]ame all references')
map('n', L('la'), C([[lua vim.lsp.buf.code_action()]]), 'Selects a code [a]ction available')

-- m key for image and map
map('n', L('mp'), C('PasteImage'), 'Paste image form clipboard')

-- q key for session and quit
map('n', L('qd'), C('lua require"custom.mini.sessions".delete()'), 'Delete session')
map('n', L('ql'), C('lua MiniSessions.select()'), 'Select session')
map('n', L('qs'), C('lua require"custom.mini.sessions".save()'), 'Save session')
map('n', L('qq'), C('qa!'), 'Quit all')

-- v is for 'visits'
map('n', L('vv'), C([[lua MiniVisits.add_label()]]), 'Add core label')
map('n', L('vV'), C([[lua MiniVisits.remove_label()]]), 'Remove core label')
map('n', L('vl'), C([[lua MiniVisits.add_label()]]), 'Add label')
map('n', L('vL'), C([[lua MiniVisits.remove_label()]]), 'Remove label')
map('n', L('vp'), C([[Pick visit_paths cwd=""]]), 'Find visited paths (all)')
map('n', L('vP'), C([[Pick visit_paths]]), 'Find visited paths (cwd)')

-- z for zk note
map('n', L('zb'), C('ZkBacklinks'), 'ZK Back links')
map('n', L('zd'), C('ZkCd'), 'Change directory')
map('n', L('zr'), C('ZkIndex'), 'ZK reindex')
map('n', L('zs'), C([[ZkNotes {sort = {'created'}}]]), 'ZK list notes')
map('n', L('zm'), C('ZkFullTextSearch'), 'ZK search notes (FT)')
map('n', L('zl'), C('ZkLinks'), 'ZK links')
map('n', L('zt'), C('ZkTags'), 'ZK tags')
-- map('n', L('zj'), C('ZkNew {dir = "journal"}'), 'New journal') FIXME: E488
-- map('n', L('zj'), C([[lua require'zk'.new(vim.tbl_extend('keep', {dir = 'journal'}, {}))]]), 'New journal')
map('n', L('zj'), C([[lua require'zk.commands'.get('ZkNew')({dir = 'journal'})]]), 'New journal')
-- map('n', L('zn'), C("ZkNew {title = vim.fn.input('Title: ')}"), 'New fast note')
-- FIXME: start E488 trailing characters
map('n', L('zn'), C([[lua require'zk.commands'.get('ZkNew')({title = vim.fn.input('Title: ')})]]), 'New fast note')
-- FIXME: end
map('n', L('zN'), C('ZkNewMeeting'), 'New meeting note')
map('n', L('zp'), C('ZkPriorMeetings'), 'Prior meetings')

-- ? for old files
map('n', L('?'), C([[Pick oldfiles]]), 'Find recent files')
map('n', L('/'), C([[Pick buf_lines scope='current']]), 'Lines (current)')
