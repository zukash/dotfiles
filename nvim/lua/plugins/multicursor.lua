return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- Create cursors for each selected line.
    set("x", "m", mc.visualToCursors, { desc = "Create cursors from selection" })

    set("n", "m", function()
      if vim.v.hlsearch == 1 then
        mc.searchAddCursor(1)
      end
    end, { desc = "Add next search match cursor" })

    -- These mappings are active only while multiple cursors exist.
    mc.addKeymapLayer(function(layer_set)
      layer_set({ "n", "x" }, "n", function()
        mc.searchAddCursor(1)
      end, { desc = "Add next search match cursor" })
      layer_set({ "n", "x" }, "N", function()
        mc.searchAddCursor(-1)
      end, { desc = "Add previous search match cursor" })
      layer_set({ "n", "x" }, "A", mc.searchAllAddCursors, { desc = "Add cursors to all search matches" })
      layer_set({ "n", "x" }, "s", function()
        mc.searchSkipCursor(1)
      end, { desc = "Skip next search match" })
      layer_set({ "n", "x" }, "S", function()
        mc.searchSkipCursor(-1)
      end, { desc = "Skip previous search match" })
      layer_set("n", "<esc>", mc.clearCursors, { desc = "Clear multicursors" })
    end)
  end,
}
