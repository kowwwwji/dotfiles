return {
  "rcarriga/nvim-notify",
  keys = {
    {
      "<leader>sna",
      function()
        require("telescope").extensions.notify.notify()
      end,
    },
  },
}
