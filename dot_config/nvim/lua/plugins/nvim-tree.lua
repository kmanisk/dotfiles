-- lua/plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Disable netrw at start
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- Setup nvim-tree
require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = true,
  open_on_tab = false,        -- don’t open automatically on tab
  hijack_cursor = true,       -- keep cursor on file when opening
  update_cwd = true,          -- sync nvim cwd with tree
  diagnostics = {             -- show LSP diagnostics in tree
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  update_focused_file = {     -- auto-focus tree on current file
    enable = true,
    update_cwd = true,
    ignore_list = {},
  },
  system_open = {             -- open files with system default app
    cmd = nil,
    args = {},
  },
  view = {
    width = 35,
    side = "left",
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
  renderer = {
    highlight_git = true,
    highlight_opened_files = "all",
    root_folder_modifier = ":t",
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        default = "",
        symlink = "",
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
        folder = {
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
        },
      },
    },
  },
  filters = {
    dotfiles = false,
    custom = { ".git", "node_modules", ".cache" },
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
      window_picker = {
        enable = true,
      },
    },
  },
})
    -- Keymap: toggle file tree
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
  end
}
