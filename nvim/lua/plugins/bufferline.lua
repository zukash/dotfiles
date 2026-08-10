return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      -- 現在開いているバッファだけをタブバーに表示する
      custom_filter = function(bufnr)
        return bufnr == vim.api.nvim_get_current_buf()
      end,
    },
  },
}
