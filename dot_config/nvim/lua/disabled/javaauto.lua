

return {
  {
    "artur-shaik/jc.nvim",
    dependencies = {
      "puremourning/vimspector",
      "mfussenegger/nvim-jdtls",
      "williamboman/mason.nvim",
    },
    ft = { "java" },
    opts = {
      java_exec = "C:\\Program Files\\OpenJDK\\jdk-22.0.2\\bin\\java.exe",  -- Update this to your Java path
      keys_prefix = "'j",
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-11",  -- You may want to change this version to match your setup
                path = "C:\\Program Files\\OpenJDK\\jdk-22.0.2\\",  -- Update the runtime path to JDK 22
                default = true,
              },
            },
          },
        },
      },
    },
    config = function()
      -- Additional configuration if needed
    end,
  },
}
