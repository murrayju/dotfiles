-- Autocmds
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General Settings
local general = augroup("General", { clear = true })

-- Restore cursor position
autocmd("BufReadPost", {
  group = general,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto reload files
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = general,
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})


-- Custom file type detection
local custom_filetypes = augroup("CustomFileTypes", { clear = true })

-- JavaScript/TypeScript settings
autocmd("FileType", {
  group = custom_filetypes,
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Flow files
autocmd({ "BufNewFile", "BufRead" }, {
  group = custom_filetypes,
  pattern = "*.js.flow",
  callback = function()
    vim.bo.filetype = "javascript"
  end,
})

-- HTML files
autocmd({ "BufNewFile", "BufRead" }, {
  group = custom_filetypes,
  pattern = { "*.hta", "*.cshtml" },
  callback = function()
    vim.bo.filetype = "html"
  end,
})

-- Markdown files
autocmd({ "BufNewFile", "BufRead" }, {
  group = custom_filetypes,
  pattern = "*.md",
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})
