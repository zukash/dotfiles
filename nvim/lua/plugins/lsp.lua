return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "<c-k>", false, mode = "i" },
        },
      },
    },
  },
}
