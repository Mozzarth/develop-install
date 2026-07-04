-- Opciones generales
vim.opt.number = true
vim.opt.tabstop = 2

-- =============================================================================
-- lazy.nvim — plugin manager
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Plugins
-- =============================================================================
require("lazy").setup({

    -- oil.nvim — explorador de archivos como buffer editable
    {
        "stevearc/oil.nvim",
        opts = {
            default_file_explorer = true,  -- reemplaza netrw
            view_options = {
                show_hidden = true,        -- mostrar archivos ocultos (.env, .git, etc)
            },
        },
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Abrir directorio actual" },
        },
    },

})
