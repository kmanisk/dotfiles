return {
  -- Vim-Be-Good (lazy-loaded with command trigger)
  {
    "ThePrimeagen/vim-be-good",
    lazy = true, -- Lazy load the plugin
    cmd = "VimBeGood", -- Trigger with :VimBeGood command
  },

  -- Better Escape plugin (for jk mapping in insert mode)
  {
    "nvim-zh/better-escape.vim", -- Correct inclusion without `require`
    config = function()
      -- Configure the plugin using Vim global variables (vim.g)
      vim.g.better_escape_interval = 200 -- Set time interval to 200 ms
      vim.g.better_escape_shortcut = { "jk", "kj" } -- Support multiple shortcuts
    end,
  },
  
  {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end
    },


  -- Session management with nvim-possession and FZF-Lua dependency
  {
    "gennaro-tedesco/nvim-possession",
    dependencies = { "ibhagwan/fzf-lua" },
    config = function()
      require("nvim-possession").setup({
        -- Add any specific configurations for nvim-possession here
        autosave = true, -- Optional: enable autosave of sessions
        silent = false, -- Optional: suppress messages on session load/save
      })

      -- Key mappings for session management
      local possession = require("nvim-possession")
      vim.keymap.set("n", "<leader>gl", possession.list, { desc = "List Sessions" })
      vim.keymap.set("n", "<leader>gn", possession.new, { desc = "New Session" })
      vim.keymap.set("n", "<leader>gu", possession.update, { desc = "Update Session" })
      vim.keymap.set("n", "<leader>gd", possession.delete, { desc = "Delete Session" })
    end,
  },

  -- Comment.nvim for commenting code with custom keybindings
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        padding = true,
        sticky = true,
        ignore = nil,
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
        mappings = {
          basic = true,
          extra = true,
        },
      })
    end,
  },

  -- -- Code Runner plugin for running code
  -- {
    -- "CRAG666/code_runner.nvim",
    -- config = function()
      -- require("code_runner").setup({
        -- -- Add any specific configurations here, if needed
      -- })
    -- end,
  -- },

  
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon", -- Use 'moon' variant
      })
      vim.cmd("colorscheme rose-pine") -- Set the colorscheme to Rosé Pine
    end,
  },
  { "ThePrimeagen/harpoon" },
  { "nvim-lua/plenary.nvim" },
  ---@type LazySpec
  -- {
  --   "mikavilpas/yazi.nvim",
  --   event = "VeryLazy",
  --   keys = {
  --     -- 👇 in this section, choose your own keymappings!
  --     {
  --       "<leader>[",
  --       "<cmd>Yazi<cr>",
  --       desc = "Open yazi at the current file",
  --     },
  --     {
  --       -- Open in the current working directory
  --       "<leader>cw",
  --       "<cmd>Yazi cwd<cr>",
  --       desc = "Open the file manager in nvim's working directory",
  --     },
  --     {
  --       -- NOTE: this requires a version of yazi that includes
  --       -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
  --       "<c-up>",
  --       "<cmd>Yazi toggle<cr>",
  --       desc = "Resume the last yazi session",
  --     },
  --   },
  --   ---@type YaziConfig
  --   opts = {
  --     -- if you want to open yazi instead of netrw, see below for more info
  --     open_for_directories = false,
  --     keymaps = {
  --       show_help = "<f1>",
  --     },
  --   },
  -- },
  {
    "askfiy/visual_studio_code",
    priority = 100,
    config = function()
      vim.cmd([[colorscheme visual_studio_code]])
    end,
  },
   {
      'ggandor/leap.nvim',
      config = function()
        -- Add configuration for leap.nvim here
        require('leap').add_default_mappings()
        -- Customize the keybinding for leap.nvim
      end
    },
  {
        "vifm/vifm.vim",
        lazy = false, -- Load immediately
        config = function()
            -- Optional additional setup here
        end,
    },
	{
  "CRAG666/betterTerm.nvim",
  opts = {
    position = "bot",
    size = 15,
  },
},
   
  
  
require("lazy").setup({
  {
    'vidocqh/auto-indent.nvim',
    opts = {
      lightmode = true,          -- Keeps indent settings stable within the buffer's lifetime
      indentexpr = function(lnum)
        return require("nvim-treesitter.indent").get_indent(lnum)  -- Custom Treesitter-based indentation
      end,
      ignore_filetype = { 'javascript' },  -- Example of ignoring specific file types
    },
  },
}),


 {
      "CRAG666/code_runner.nvim",
      config = function()
         require("code_runner").setup({
            -- Configure options for code_runner here
            mode = "toggleterm", -- You can set it to "float", "tab", or "toggleterm"
            filetype = {
               python = "python3 -u",
               javascript = "node",
               lua = "lua",
               java = "java", -- You can adjust commands as needed for other languages
            },
            focus = true, -- Set to true to focus on the terminal window
            startinsert = true, -- Automatically enter insert mode
         })
      end,
   },
   
 
  





  
  
  
  
  

}
