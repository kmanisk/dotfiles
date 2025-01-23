require("nvim-tree").setup({
    -- General settings
    filters = { dotfiles = false },
    disable_netrw = true,
    hijack_cursor = true,
    sync_root_with_cwd = true,
    update_focused_file = {
        enable = true,
        update_root = false,
    },
    git = {
        enable = true,
        ignore = false,
        timeout = 500,
    },
    -- View settings
    view = {
        width = 30,
        -- adaptive_size = true,
        preserve_window_proportions = true,
        side = "right", -- Make sure to add this if you want to position the tree on the right
    },

    -- Renderer settings
    renderer = {
        root_folder_label = true, -- Hide root folder label
        highlight_git = true,
        indent_markers = { enable = true },
        icons = {
            glyphs = {
                default = "󰈚",
                folder = {
                    default = "",
                    empty = "",
                    empty_open = "",
                    open = "",
                    symlink = "",
                },
                git = { unmerged = "" },
            },
        },
    },

    -- on_attach function for keymaps
    on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Load default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- vim.keymap.set("n", "h", function()
        -- 	local node = api.tree.get_node_under_cursor()
        -- 	if node.parent then
        -- 		-- Only change root if we're not already at the root level
        -- 		if node.parent.parent then
        -- 			api.tree.change_root(node.parent.absolute_path)
        -- 		else
        -- 			-- Navigate up without changing root
        -- 			api.tree.change_root_to_parent()
        -- 		end
        -- 	end
        -- end, opts("Go Up to Parent Directory of Current File"))
        -- Custom mappings
        vim.keymap.set("n", "l", api.node.open.edit, opts("Open File/Folder"))
        -- vim.keymap.set('n', 'h', api.tree.change_root_to_parent, opts('Go Up'))
        vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
        vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
    end,
})
