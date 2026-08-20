return {
  "folke/snacks.nvim",
  opts = {
    -- 起動時に左側へ表示されるファイルツリーを無効にする
    explorer = {
      enabled = false,
    },
    picker = {
      sources = {
        -- 隠しファイルと Gitignore 対象を検索結果に含める
        explorer = {
          hidden = true,
          ignored = true,
        },
        files = {
          hidden = true,
          ignored = true,
        },
        grep = {
          hidden = true,
          ignored = true,
        },
      },
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "i", "n" } },
          },
        },
      },
    },
  },
}
