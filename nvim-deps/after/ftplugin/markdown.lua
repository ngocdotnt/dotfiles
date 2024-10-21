-- options
local ol = vim.opt_local
ol.textwidth = 80
ol.wrap = true
ol.spell = true

-- Helper function
local map = function(mode, lhs, rhs, desc, opts)
  opts = opts or { noremap = true, silent = false }
  opts.desc = desc
  -- vim.keymap.set(mode, lhs, rhs, opts)
  vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
end

local L = function(key) return '<leader>' .. key end
local C = function(cmd) return '<Cmd>' .. cmd .. '<CR>' end

-- mkdnflow mappings
map('n', '+', C('MkdnIncreaseHeading'), 'Increase heading')
map('n', '-', C('MkdnDecreaseHeading'), 'Decrease heading')
map('n', '<F2>', C('MkdnMoveSource'), 'Rename source')
map('n', '<CR>', C('MkdnEnter'), 'Enter')
map('v', '<CR>', C('MkdnEnter'), 'Enter')
map('n', '<BS>', C('MkdnGoBack'), 'Go back')
map('n', 'o', C('MkdnNewListItemBelowInsert'), 'New list item below insert')
map('n', 'O', C('MkdnNewListItemAboveInsert'), 'New list item above insert')
map('i', '<S-Tab>', C('MkdnTablePrevCell'), 'Prev table cell')
map('i', '<Tab>', C('MkdnTableNextCell'), 'Next table cell')
map('n', '<M-e>', C('MkdnToggleToDo'), 'Toggle todo')
map('n', '<M-/>', C('MkdnToggleToDo'), 'Toggle todo')

map('n', L('nf'), C('MkdnFoldSection'), 'Fold section')
map('n', L('nF'), C('MkdnUnfoldSection'), 'Unfold section')
map('n', L('nn'), C('MkdnUpdateNumbering'), 'Update numbering')
map('n', L('nd'), C('MkdnToggleToDo'), 'Toggle todo')
map('n', L('nj'), C('MkdnTableNewRowBelow'), 'Table new row below')
map('n', L('nk'), C('MkdnTableNewRowAbove'), 'Table new row above')
map('n', L('nh'), C('MkdnTableNewColBefore'), 'Table new col before')
map('n', L('nl'), C('MkdnTableNewColAfter'), 'Table new col ater')

-- Using `vim.cmd` instead of `vim.wo` because it is yet more reliable
-- vim.cmd('setlocal spell')
-- vim.cmd('setlocal wrap')

-- Customize 'mini.nvim'
local has_mini_ai, mini_ai = pcall(require, 'mini.ai')
if has_mini_ai then
  vim.b.miniai_config = {
    custom_textobjects = {
      ['*'] = mini_ai.gen_spec.pair('*', '*', { type = 'greedy' }),
      ['_'] = mini_ai.gen_spec.pair('_', '_', { type = 'greedy' }),
    },
  }
end

local has_mini_surround, mini_surround = pcall(require, 'mini.surround')
if has_mini_surround then
  vim.b.minisurround_config = {
    custom_surroundings = {
      -- Bold
      B = { input = { '%*%*().-()%*%*' }, output = { left = '**', right = '**' } },

      -- Link
      L = {
        input = { '%[().-()%]%(.-%)' },
        output = function()
          local link = mini_surround.user_input('Link: ')
          return { left = '[', right = '](' .. link .. ')' }
        end,
      },
    },
  }
end
