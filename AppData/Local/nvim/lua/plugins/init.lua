return {
	{
		"NvChad/nvterm",
		enabled = false,
	},
	{
		"lewis6991/gitsigns.nvim",
		enabled = false,
	},
        {
		"stevearc/conform.nvim",
        enabled = false,
		event = "BufWritePre", -- uncomment for format on save
		opts = require("configs.conform"),
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},
{
  "smoka7/hop.nvim",
  version = "*",
  opts = {
    keys = "etovxqpdygfblzhckisuran", -- Define the keys for hop
    -- Initialize the hop module and directions
  cond = function()
    return not vim.g.vscode -- Exclude this plugin in VSCode
  end,
}
},

	{
		"CRAG666/code_runner.nvim",
		config = true,
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},

	{
		"Mofiqul/vscode.nvim",
		cond = function()
			return not vim.g.vscode -- Exclude this plugin in VSCode
		end,
	},

	-- These are some examples, uncomment them if you want to see them work!
 {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = { "pyright" }, -- Install Pyright automatically
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = function(_, bufnr)
              local bufopts = { noremap = true, silent = true, buffer = bufnr }
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
              vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
              vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
              vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
              vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
              vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
              vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
            end,
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          })
        end,
      })
    end,
  },

  -- mason-lspconfig Configuration
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" },
      })
    end,
  },

  -- Treesitter Configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "python", "lua", "html", "css", "json" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Mason Configuration
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright", -- LSP for Python
        "flake8", -- Linter for Python
        "black", -- Formatter for Python
      },
    },
    config = function()
      require("mason").setup()
    end,
  },

  -- Autocompletion Configuration
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP completion source
      "hrsh7th/cmp-buffer", -- Buffer completion source
      "hrsh7th/cmp-path", -- Path completion source
      "L3MON4D3/LuaSnip", -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- Linting and Formatting Configuration
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.black, -- Formatter
          null_ls.builtins.diagnostics.flake8, -- Linter
        },
        on_attach = function(client, bufnr)
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
            vim.keymap.set("n", "<Leader>f", function()
              vim.lsp.buf.format({ async = true })
            end, { buffer = bufnr })
          end
        end,
      })
    end,
  },

}
