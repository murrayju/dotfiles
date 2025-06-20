-- Keymaps
local keymap = vim.keymap

-- Better escape
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Clear search highlighting
keymap.set("n", "\\\\", ":noh<CR><ESC>", { desc = "Clear search highlights" })

-- Better navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move text up and down
keymap.set("v", "<A-j>", ":m .+1<CR>==", { desc = "Move text down" })
keymap.set("v", "<A-k>", ":m .-2<CR>==", { desc = "Move text up" })
keymap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move text down" })
keymap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move text up" })
keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move text down" })
keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move text up" })

-- Better indenting
keymap.set("v", "<", "<gv", { desc = "Indent right" })
keymap.set("v", ">", ">gv", { desc = "Indent left" })

-- Y behaves like C and D
keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Paste over selection without yanking
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Delete without yanking
keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Save file
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })

-- Save file as root
keymap.set("n", "<leader>W", ":w !sudo tee % > /dev/null<CR>", { desc = "Save file as root" })

-- Buffer navigation
keymap.set("n", "<F5>", ":ls<CR>:b<Space>", { desc = "List and select buffer" })
keymap.set("n", "<leader>b", ":buffers<CR>:buffer<Space>", { desc = "List and select buffer" })
keymap.set("n", "<leader>q", ":bdelete<CR>", { desc = "Delete current buffer" })

-- Toggle line wrap
keymap.set("n", "<C-E><C-W>", ":set wrap!<CR>", { desc = "Toggle line wrap" })

-- Strip trailing whitespace
keymap.set("n", "<leader>ss", function()
  local save_cursor = vim.fn.getpos(".")
  local old_query = vim.fn.getreg("/")
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos(".", save_cursor)
  vim.fn.setreg("/", old_query)
end, { desc = "Strip trailing whitespace" })

-- Toggle list characters
keymap.set("n", "<leader>l", ":set list!<CR>", { desc = "Toggle list characters" })