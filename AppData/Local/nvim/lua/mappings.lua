-- =============================================================================
--                             NVCHAD BASE MAPPINGS
-- =============================================================================
require("nvchad.mappings")

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- =============================================================================
--                               GENERAL MAPPINGS
-- =============================================================================
map("i", "jk",         "<ESC>",                                  { desc = "Escape insert mode" })
map("i", ";w",         "<esc>:write<CR>",                        { desc = "Save in insert mode" })
map("i", ";x",         "<esc>:wq<CR>",                           { desc = "Save and quit in insert mode" })
map("n", "U",          "<C-r>",                                  { desc = "Redo" })
map("n", "<leader>w",  ":w<CR>",                                 opts)
map("n", "<leader>W",  ":wa<CR>",                                { desc = "Save all files" })
map("n", "<leader>sa", "ggVG",                                   { desc = "Select all" })
map("n", "<leader>ya", 'ggVG"+y',                                { desc = "Yank all to clipboard" })
map("n", "<leader>da", 'ggVG"_d',                                { desc = "Delete all to blackhole" })
map("n", "<leader>sf", ":source %<CR>",                         { desc = "Source current file" })
map("n", "<leader><Tab>", ":qa!<CR>",                             { desc = "Force quit Neovim" })

-- =============================================================================
--                            NAVIGATION & CENTERING
-- =============================================================================
map("n", "j",          "jzz",                                    opts)
map("n", "k",          "kzz",                                    opts)
map("n", "n",          "nzz",                                    opts)
map("n", "N",          "Nzz",                                    opts)
map("n", "gg",         "ggzz",                                   opts)
map("n", "G",          "Gzz",                                    opts)
map("n", "<C-d>",      "<C-d>zz",                                opts)
map("n", "<C-u>",      "<C-u>zz",                                opts)
map("n", "[{",         "{zz",                                    opts)
map("n", "]}",         "}zz",                                    opts)
map({ "i", "n" }, "<C-k>", "<Up>",                               { desc = "Move up" })
map({ "i", "n" }, "<C-j>", "<Down>",                             { desc = "Move down" })

-- =============================================================================
--                          WINDOW & BUFFER MANAGEMENT
-- =============================================================================
map("n", "<C-h>",      "<C-w>h",                                 { desc = "Focus left" })
map("n", "<C-j>",      "<C-w>j",                                 { desc = "Focus bottom" })
map("n", "<C-k>",      "<C-w>k",                                 { desc = "Focus top" })
map("n", "<C-l>",      "<C-w>l",                                 { desc = "Focus right" })
map("n", "<A-v>",      ":vsplit<CR>",                            { desc = "Vertical split" })
map("n", "<A-h>",      ":split<CR>",                             { desc = "Horizontal split" })
map("n", "<A-w>",      ":close<CR>",                             { desc = "Close split" })
map("n", "<C-w>",      ":tabclose<CR>",                          { desc = "Close current tab" })

-- =============================================================================
--                            TAB & BUFFERLINE (NVCHAD)
-- =============================================================================
map("n", "<S-k>",      function() require("nvchad.tabufline").prev() end,             opts)
map("n", "<S-j>",      function() require("nvchad.tabufline").next() end,             opts)
map("n", "<leader>q",  function() require("nvchad.tabufline").close_buffer() end,     opts)
map("n", "<leader>ct", function() require("nvchad.tabufline").closeAllBufs(false) end, opts)
map("n", "<leader>cr", function() require("nvchad.tabufline").closeBufs_at_direction("right") end, opts)
map("n", "<leader>cl", function() require("nvchad.tabufline").closeBufs_at_direction("left") end,  opts)
map("n", "<A-Left>",   function() require("nvchad.tabufline").move_buf(-1) end,        opts)
map("n", "<A-Right>",  function() require("nvchad.tabufline").move_buf(1) end,         opts)

-- =============================================================================
--                             CLIPBOARD OPERATIONS
-- =============================================================================
map({ "n", "v" }, "y", '"+y',                                    opts)
map("n", "yy",         '"+yy',                                   opts)
map({ "n", "v" }, "p", '"+p',                                    opts)
map("n", "gp",         'o<Esc>"+p',                              opts)
map("n", "gP",         'O<Esc>"+P',                              opts)
map({ "n", "v" }, "d", '"_d',                                    opts)
map("n", "dd",         '"_dd',                                   opts)
map("v", "p",          '"_dP',                                   { desc = "Paste over selection" })
map({ "n", "v" }, "c", '"_c',                                    opts)
map({ "n", "v" }, "C", '"_C',                                    opts)
map("n", "x",          '"_x',                                    opts)

-- =============================================================================
--                                   TERMINAL
-- =============================================================================
map({ "n", "t" }, "<A-i>", "<cmd>ToggleTerm direction=float<cr>",      { desc = "Toggle float terminal" })
map({ "n", "t" }, "<A-;>", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Toggle horizontal terminal" })
map("t", "jk",         [[<C-\><C-n>]],                                 opts)

-- Terminal Navigation
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use termopen
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

-- =============================================================================
--                                    PLUGINS
-- =============================================================================
map("n", "<leader>e",  ":NvimTreeToggle<CR>",                    opts)
map("n", "<A-d>",      ":NvimTreeClose<CR>",                     opts)
map("n", "<leader>fm", ":Vifm<CR>",                              opts)
map("n", "<leader>ts", ":Telescope colorscheme<CR>",             opts)
map("n", "<leader>ff", ":Telescope find_files<CR>",              opts)
map("n", "<leader>fh", ":Telescope oldfiles<CR>",                opts)
map("n", "<leader>fr", ":Telescope resume<CR>",                 opts)
map("n", "<leader>sk", function() require("telescope.builtin").keymaps() end, opts)
map("n", "<leader>oc", function() require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Open Config" })
map("n", "<leader>og", function() require("telescope.builtin").live_grep({ cwd = vim.fn.stdpath("config") }) end,  { desc = "Config Grep" })
map("n", "<leader><leader>", function() require("telescope").extensions.live_grep_args.live_grep_args() end,       opts)

-- =============================================================================
--                                  CODE RUNNER
-- =============================================================================
map("n", "<leader>rr", ":RunCode<CR>",                           opts)
map("n", "<leader>rf", ":RunFile<CR>",                           opts)
map("n", "<A-q>",      ":RunFile<CR>",                           opts)
map("n", "<leader>rc", ":RunClose<CR>",                          opts)

-- =============================================================================
--                                      LSP
-- =============================================================================
map("n", "cr",         function() require("nvchad.lsp.renamer")() end, opts)
map("n", "<leader>ih", "<cmd>ToggleInlayHints<CR>",              { desc = "Toggle inlay hints" })

-- =============================================================================
--                                     MISC
-- =============================================================================
map("n", "<leader>;",  "mzA;<Esc>`z",                            { desc = "Append semicolon" })
map("n", "<leader>,",  "mzA,<Esc>`z",                            { desc = "Append comma" })
map("n", "+",          "<C-a>",                                  opts)
map("n", "-",          "<C-x>",                                  opts)
map("n", "<leader>Ls", ":Lazy sync<CR>",                         { desc = "Sync lazy plugins" })
map("n", "<leader>oe", function()
    local dir = vim.fn.expand("%:p:h")
    vim.cmd("silent !start explorer " .. dir)
end, { desc = "Open Explorer" })

-- =============================================================================
--                          REMOVE CONFLICTING DEFAULTS
-- =============================================================================
local function safe_del(mode, key)
    if vim.fn.maparg(key, mode) ~= "" then
        pcall(vim.keymap.del, mode, key)
    end
end

local to_remove = {
    { "n", "<leader>h" }, { "n", "<leader>v" }, { "n", "<leader>b" },
    { "n", "<leader>x" }, { "n", "<C-n>" },     { "n", "<Tab>" }, 
    { "n", "<S-Tab>" }
}
for _, m in ipairs(to_remove) do safe_del(m[1], m[2]) end
