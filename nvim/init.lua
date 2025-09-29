-- init.lua

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- UI & Themes
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          mason = true,
        }
      })
      vim.cmd.colorscheme("catppuccin")
    end
  },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "catppuccin" },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        }
      })
    end
  },
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })
    end
  },
  { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          themable = true,
          diagnostics = "nvim_lsp",
        }
      })
    end
  },

  -- Telescope & Navigation
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" }
        }
      })
    end
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Treesitter & Syntax
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "typescript", "html", "css", "json", "yaml", "bash" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
  { "nvim-treesitter/nvim-treesitter-context" },

  -- Git Integration
  { "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = '│' },
          change = { text = '│' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
      })
    end
  },
  { "tpope/vim-fugitive" },

  -- LSP & Completion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", build = ":MasonUpdate",
    config = function() require("mason").setup() end },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },

  -- Formatting & Linting
  { "jose-elias-alvarez/null-ls.nvim" },
  { "jay-babu/mason-null-ls.nvim" },

  -- Editor Enhancements
  { "windwp/nvim-autopairs", config = true },
  { "numToStr/Comment.nvim", config = true },
  { "kylechui/nvim-surround", config = true },
  { "folke/which-key.nvim", config = true },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = true },

  -- Development Tools
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap"} },
  { "theHamsta/nvim-dap-virtual-text", dependencies = {"mfussenegger/nvim-dap"} },

  -- Language Specific
  { "simrat39/rust-tools.nvim" },
  { "fatih/vim-go", ft = "go" },
  { "elixir-editors/vim-elixir", ft = "elixir" },
})

-- Keymaps
local map = vim.keymap.set

-- File Explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Explorer" })
map("n", "<leader>E", ":NvimTreeFocus<CR>", { desc = "Focus Explorer" })

-- Telescope
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live Grep" })
map("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help Tags" })
map("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "Recent Files" })
map("n", "<leader>fc", ":Telescope colorscheme<CR>", { desc = "Colorschemes" })

-- Buffer management
map("n", "<Tab>", ":BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete Buffer" })
map("n", "<leader>ba", ":BufferLineCloseOthers<CR>", { desc = "Close Other Buffers" })

-- File operations
map("n", "<C-s>", ":w<CR>", { desc = "Save" })
map("n", "<leader>w", ":w<CR>", { desc = "Save" })
map("n", "<leader>wa", ":wa<CR>", { desc = "Save All" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>qa", ":qa<CR>", { desc = "Quit All" })

-- Window management
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>sh", ":split<CR>", { desc = "Horizontal Split" })
map("n", "<leader>se", "<C-w>=", { desc = "Equal Splits" })
map("n", "<leader>sx", ":close<CR>", { desc = "Close Split" })

-- Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Git
map("n", "<leader>gs", ":Git<CR>", { desc = "Git Status" })
map("n", "<leader>gc", ":Git commit<CR>", { desc = "Git Commit" })
map("n", "<leader>gp", ":Git push<CR>", { desc = "Git Push" })
map("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Git Log" })

-- Diagnostics
map("n", "<leader>xx", ":Trouble<CR>", { desc = "Trouble" })
map("n", "<leader>xd", ":Trouble document_diagnostics<CR>", { desc = "Document Diagnostics" })
map("n", "<leader>xw", ":Trouble workspace_diagnostics<CR>", { desc = "Workspace Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format" })

-- Debugging
map("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
map("n", "<leader>dc", ":DapContinue<CR>", { desc = "Continue" })
map("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step Into" })
map("n", "<leader>do", ":DapStepOver<CR>", { desc = "Step Over" })
map("n", "<leader>du", ":DapUiToggle<CR>", { desc = "Toggle DAP UI" })

-- LSP Setup
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Mason LSP setup
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "ts_ls", "html", "cssls", "jsonls", "bashls" }
})

-- Configure LSP servers
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = {"vim"} },
        workspace = { 
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false
        },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {},
  ts_ls = {},
  html = {},
  cssls = {},
  jsonls = {},
  bashls = {},
}

for server, config in pairs(servers) do
  config.capabilities = capabilities
  lspconfig[server].setup(config)
end

-- Null-ls setup
local null_ls = require("null-ls")
require("mason-null-ls").setup({
  ensure_installed = { "prettier", "stylua", "black", "isort", "flake8" }
})

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.diagnostics.flake8,
  },
})

-- Completion setup
local cmp = require("cmp")
local luasnip = require("luasnip")

-- Load friendly snippets
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
  }, {
    { name = "buffer" },
  }),
})

-- DAP Configuration
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()
require("nvim-dap-virtual-text").setup()

-- Auto open/close DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Trouble configuration
require("trouble").setup()

-- Auto commands
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

