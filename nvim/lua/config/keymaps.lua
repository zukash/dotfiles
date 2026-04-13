-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ========================================
-- Emacs-like editing (movement + kill)
-- ========================================
vim.keymap.set("i", "<C-p>", "<Up>") -- previous line
vim.keymap.set("i", "<C-n>", "<Down>") -- next line
vim.keymap.set("i", "<C-f>", "<Right>") -- forward char
vim.keymap.set("i", "<C-b>", "<Left>") -- backward char

vim.keymap.set({ "i", "n", "v" }, "<C-a>", "<Home>") -- beginning of line
vim.keymap.set({ "i", "n", "v" }, "<C-e>", "<End>") -- end of line

vim.keymap.set("i", "<C-d>", "<Del>") -- delete forward char
vim.keymap.set("i", "<C-h>", "<BS>") -- delete backward char
vim.keymap.set("i", "<C-k>", "<C-o>d$") -- kill to end of line

-- ========================================
-- Jump
-- ========================================
vim.keymap.set("i", "<C-j>", "<C-o>s", { remap = true })
vim.keymap.set({ "n", "v" }, "<C-j>", "s", { remap = true })

-- ========================================
-- Scrolling
-- ========================================
vim.keymap.set({ "n", "v" }, "<PageUp>", "<C-u>")
vim.keymap.set({ "n", "v" }, "<PageDown>", "<C-d>")
vim.keymap.set("i", "<PageUp>", "<C-o><C-u>")
vim.keymap.set("i", "<PageDown>", "<C-o><C-d>")

-- ========================================
-- Search (word under cursor)
-- ========================================
vim.keymap.set("i", "<C-g>", "<ESC>*N")
vim.keymap.set("n", "<C-g>", "*N")
vim.keymap.set("v", "<C-g>", "*N", { remap = true })

-- ========================================
-- Insert-mode helpers (temporary normal-mode actions)
-- ========================================
vim.keymap.set("i", "<C-v>", "<C-o>v", { remap = true }) -- enter visual
vim.keymap.set("i", "<C-u>", "<C-o>u") -- undo
vim.keymap.set("i", "<C-r>", "<C-o><C-r>") -- redo / register
