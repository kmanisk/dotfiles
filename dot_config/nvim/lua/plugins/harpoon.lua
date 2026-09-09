return {
  "ThePrimeagen/harpoon",
  cond = function()
    return not vim.g.vscode -- Exclude this plugin in VSCode
  end,
  config = function()
    -- Setup Harpoon with default settings
    require("harpoon").setup({
      global_settings = {
        save_on_toggle = true,  -- Automatically save when toggling the menu
        save_on_change = true,  -- Automatically save changes to the Harpoon list
        enter_on_sendcmd = false, -- Do not move to terminal when sending command
        excluded_filetypes = { "harpoon" }, -- Exclude Harpoon buffer itself
        mark_branch = false, -- Do not use branch-based marks
      },
    })

    -- Mappings for Harpoon
    local map = vim.keymap.set
    local harpoon_ui = require("harpoon.ui")
    local harpoon_mark = require("harpoon.mark")

    -- Add file to Harpoon
    map("n", "<leader>ha", harpoon_mark.add_file, { desc = "Add file to Harpoon" })

    -- Toggle the Harpoon menu
    map("n", "<leader>hh", harpoon_ui.toggle_quick_menu, { desc = "Toggle Harpoon menu" })

map("n", "<leader>a", harpoon_ui.toggle_quick_menu, { desc = "Toggle Harpoon menu" })

-- Remove file from Harpoon
map("n", "<leader>hr", function()
  harpoon_mark.remove_file()
end, { desc = "Remove file from Harpoon" })


-- Navigate to the next file in Harpoon
map("n", "<leader>hn", function()
  harpoon_ui.nav_next()
end, { desc = "Navigate to next Harpoon file" })

-- Close the Harpoon menu when pressing 'q'
-- map("n", "Q", harpoon_ui.toggle_quick_menu, { desc = "Close Harpoon menu" })
-- Navigate to the previous file in Harpoon
map("n", "<leader>hp", function()
  harpoon_ui.nav_prev()
end, { desc = "Navigate to previous Harpoon file" })
    -- -- Navigate to specific Harpoon files (1-9)
    for i = 1, 9 do
      map("n", "<leader>" .. i, function()
        harpoon_ui.nav_file(i)
      end, { desc = "Navigate to Harpoon file " .. i })
    end

-- Create mappings for navigating to Harpoon files using QWERTY keys
  end,
}
