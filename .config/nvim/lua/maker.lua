local Maker = {
  __compile_command = "make",
  __run_command = "./main"
}

function Maker.__execute_in_terminal(cmd)
  if cmd == "" then return end
  vim.cmd("botright split | terminal " .. cmd)
  vim.cmd("startinsert")
end

function Maker.setup(opts)
  opts = opts or {}
  if opts.compile_command then
    Maker.__compile_command = opts.compile_command
  end
  if opts.run_command then
    Maker.__run_command = opts.run_command
  end
end

function Maker.compile()
  vim.cmd("write")

  vim.ui.input({
    prompt = "Build command: ",
    default = Maker.__compile_command,
  }, function(input)
    if input == nil then return end 
    
    Maker.__compile_command = input
    Maker.__execute_in_terminal(input)
  end)
end

function Maker.run()
  vim.ui.input({
    prompt = "Run command: ",
    default = Maker.__run_command,
  }, function(input)
    if input == nil then return end
    
    Maker.__run_command = input
    Maker.__execute_in_terminal(input)
  end)
end

return Maker
