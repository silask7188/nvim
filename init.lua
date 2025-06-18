

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha"
    },
  },

  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", tag = "0.1.5" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  { "HiPhish/nvim-ts-rainbow2"},

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  { "akinsho/toggleterm.nvim", version = "*" },

  { "lewis6991/gitsigns.nvim" },

  -- { "zbirenbaum/copilot.lua", cmd = "Copilot" },
  -- { "zbirenbaum/copilot-cmp" },

  { "numToStr/Comment.nvim" },

  { "ray-x/go.nvim" },
  { "ray-x/guihua.lua" },

  { "windwp/nvim-autopairs" },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl" },
})

local o = vim.opt
o.number         = true
o.relativenumber = true
o.tabstop        = 4
o.shiftwidth     = 4
o.expandtab      = true
o.smartindent    = true
o.cursorline     = true
o.wrap           = true
o.scrolloff      = 4
o.termguicolors  = true
o.clipboard      = "unnamedplus"
o.ignorecase     = true
o.smartcase      = true
o.signcolumn     = "yes"
o.updatetime     = 300
o.timeoutlen     = 500
o.completeopt    = "menu,menuone,noselect"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd.colorscheme("catppuccin")

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "gopls",
    "pyright",
    "clangd",
    "html",
    "cssls",
    "jsonls",
  },
  automatic_installation = true,
})

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
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
    -- { name = "copilot" },
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  })
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" }
  }, {
    { name = "cmdline" }
  })
})

local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local capabilities = cmp_nvim_lsp.default_capabilities()

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- Configure language servers
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },
  pyright = {},
  clangd = {},
  html = {},
  cssls = {},
  jsonls = {},
  ts_ls = {},
}

for server, config in pairs(servers) do
  config.capabilities = capabilities
  config.on_attach = on_attach
  lspconfig[server].setup(config)
end

require("telescope").setup()
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep,  { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })

require("nvim-treesitter.configs").setup({
  ensure_installed = {"go", "lua", "python", "cpp", "json", "html", "css", "javascript", "typescript" },
  highlight = { enable = true },
  indent    = { enable = true },
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  view = { 
    width = 35, 
    side = "left",
  },
  renderer = { 
    add_trailing = false, 
    highlight_git = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      require("nvim-tree.api").tree.open()
    end
  end
})

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<cr>", { desc = "Focus file explorer" })

require("toggleterm").setup({
  open_mapping = [[<c-\>]],
  direction    = "horizontal",
  size         = 15,
  shade_terminals = true,
})
vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=60<cr>", { desc = "Vertical terminal" })
vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Horizontal terminal" })

require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
})

-- require("copilot").setup({
  -- suggestion = { enabled = false },
  -- panel = { enabled = true },
-- })

-- require("copilot_cmp").setup()

require("Comment").setup({
  toggler = {
    line = '<C-_>',
    block = '<C-S-_>',
  },
  opleader = {
    line = '<C-_>',
    block = '<C-S-_>',
  },
})

require("go").setup({
  goimport = "gopls",
  gofmt = "gofumpt",
  tag_transform = false,
  test_dir = "",
  comment_placeholder = "   ",
  lsp_cfg = true,
  lsp_gofumpt = true,
  lsp_on_attach = on_attach,
  dap_debug = true,
})

-- Go-specific keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set("n", "<leader>gr", "<cmd>!go run %<cr>", opts)
    vim.keymap.set("n", "<leader>ga", "vip:!formattag -C<CR>", { desc = "Align Go tags" })
    vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", opts)
    vim.keymap.set("n", "<leader>gf", "<cmd>GoFmt<cr>", opts)
    vim.keymap.set("n", "<leader>gi", "<cmd>GoImport<cr>", opts)
    vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<cr>", opts)
  end,
})

require("nvim-autopairs").setup({
  check_ts = true,
  ts_config = {
    lua = { "string", "source" },
    javascript = { "string", "template_string" },
    java = false,
  },
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

require("ibl").setup({
  indent = {
    char = "│",
    tab_char = "│",
  },
  scope = { enabled = false },
  exclude = {
    filetypes = {
      "help",
      "alpha",
      "dashboard",
      "neo-tree",
      "Trouble",
      "lazy",
      "mason",
      "notify",
      "toggleterm",
      "lazyterm",
    },
  },
})

vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { silent = true })
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { silent = true })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move text down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move text up" })

vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { desc = "Copy to system clipboard" })

vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste from system clipboard" })

vim.keymap.set("i", "<C-v>", '<C-r>+', { desc = "Paste from system clipboard" })


vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.go",
  callback = function()
    vim.cmd("%!formattag")
  end,
})

