return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {},
      ["*"] = {
        keys = {
          { "<c-k>", false, mode = "i" },
        },
      },
    },
  },
}
