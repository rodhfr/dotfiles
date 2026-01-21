vim.filetype.add({
  pattern = {
    [".*/sway/config$"] = "swayconfig", -- main sway config
    [".*/sway/config.d/.*"] = "swayconfig", -- all files in config.d/
  },
})
