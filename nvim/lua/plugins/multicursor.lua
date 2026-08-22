return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- Turn each selected line into a cursor.
    set("x", "m", mc.visualToCursors, { desc = "Create cursors from selection" })

    -- These mappings are active only while multiple cursors exist.
    mc.addKeymapLayer(function(layer_set)
      layer_set({ "n", "x" }, "n", mc.nextCursor, { desc = "Next cursor" })
      layer_set({ "n", "x" }, "N", mc.prevCursor, { desc = "Previous cursor" })
      layer_set({ "n", "x" }, "s", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip next matching cursor" })
      layer_set({ "n", "x" }, "S", function()
        mc.matchSkipCursor(-1)
      end, { desc = "Skip previous matching cursor" })
      layer_set("n", "<esc>", mc.clearCursors, { desc = "Clear multicursors" })
    end)
  end,
}
