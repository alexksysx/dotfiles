local TaskTracker = {
  __database_dir = "tasks"
}

function TaskTracker.setup(opts)
  local cfg_dbdir = opts["directory"]
  if cfg_dbdir and cfg_dbdir ~= "" then
    TaskTracker.__database_dir = cfg_dbdir
  end
end

function TaskTracker.__findDatabaseDir()
  local current_dir = vim.loop.cwd()
  if not current_dir then
    vim.notify("Could not determine current working directory.", vim.log.leves.WARN)
    return nil
  end
  local target_name = TaskTracker.__database_dir

  while true do
    local potential_db_path = vim.fs.joinpath(current_dir, target_name)
    local stat = vim.uv.fs_stat(potential_db_path)
    if stat and stat.type == "directory" then
      -- print("Found '" .. target_name .. "' directory at: " .. potential_db_path)
      return potential_db_path
    end
    local parent_dir = vim.fs.dirname(current_dir)
    if parent_dir == current_dir then
      vim.notify("Could not find '" .. target_name .. "' directory in any parent directory.", vim.log.levels.WARN)
      return nil
    end
    current_dir = parent_dir
  end
end

function TaskTracker.__createFilesForTask(directory, huid, text)
  local task_dir = vim.fs.joinpath(directory, huid)
  local stat = vim.uv.fs_stat(task_dir)
  local task_md_file = vim.fs.joinpath(task_dir, "TASK.md")
  local text_trimmed = text:match('^%s*(.-)%s*$') or ''
  if stat then
    vim.notify("Directory with task " .. huid .. "already exists", vim.log.levels.ERROR)
    return nil
  end
  if vim.fn.mkdir(task_dir) ~= 1 then
    vim.notify("Failed to create dir " .. task_dir, vim.log.levels.ERROR)
    return nil
  end

  local file = io.open(task_md_file, "w")
  if file then
    file:write("# ")
    file:write(text_trimmed)
    file:write("\n\n")
    file:write("- STATUS: OPEN\n")
    file:write("- PRIORITY: 50\n")
    file:close()
    return task_md_file
  else
    vim.notify("Failed to create file " .. task_md_file, vim.log.levels.ERROR)
    return nil
  end
  -- TODO create file with task and data
  -- https://www.youtube.com/watch?v=QH6KOEVnSZA 1:43:09
end

function TaskTracker.__initDatabase()
  local current_dir = vim.loop.cwd()
  if not current_dir then
    vim.notify("Could not determine current working directory.", vim.log.leves.WARN)
    return nil
  end

  vim.ui.input({ prompt = "Specify path for task tracker database: ", default = current_dir, completion = "dir" },
    function(input)
      if (input == nil or input == "") then
        print("Must specify path to db")
        return
      end
      local stat = vim.uv.fs_stat(input)
      if not stat then
        vim.notify("Dir do not exist " .. input, vim.log.levels.ERROR)
        return nil
      end
      local tasks_dir = vim.fs.joinpath(input, TaskTracker.__database_dir)
      if vim.fn.mkdir(tasks_dir) ~= 1 then
        vim.notify("Failed to create dir " .. tasks_dir, vim.log.levels.ERROR)
        return nil
      end
    end
  )
end

function TaskTracker.createTaskFromTodo()
  local dbpath = TaskTracker.__findDatabaseDir()
  if not dbpath then
    local choice = vim.fn.confirm("Do you want to init tasks database?\n", "&Yes\n&No", 1)
    if choice == 1 then
      TaskTracker.__initDatabase()
    else
      return
    end
  end
  local row = vim.fn.line(".") - 1
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)
  if #lines == 0 then return end
  local current_line = lines[1]
  -- (%s*TODO[^%s]*%s*) : Capture the "TODO" part (and surrounding whitespace)
  -- (.*)               : Capture the *rest* of the line after the TODO part
  local prefix, todo_match, todo_text = current_line:match("(.*)(%s*TODO[^%s]*%s*)(.*)")

  if todo_match then
    -- vim.notify("Text after TODO found: " .. text_after, vim.log.levels.INFO)
    local huid = os.date("!%Y%m%d-%H%M%S")
    local new_line = prefix .. "TASK(" .. huid .. "): " .. todo_text
    vim.api.nvim_buf_set_text(buf, row, 0, row, #current_line, { new_line })
    local taskfile = TaskTracker.__createFilesForTask(dbpath, huid, todo_text)
    if taskfile then
      local choice = vim.fn.confirm("Do you want to open task?\n", "&Yes\n&No", 2)
      if choice == 1 then
        vim.cmd.edit(vim.fn.expand(taskfile))
      end
    end
  end
end

function TaskTracker.openTaskFromLine()
  local dbpath = TaskTracker.__findDatabaseDir()
  if not dbpath then
    return
  end
  local row = vim.fn.line(".") - 1
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)
  if #lines == 0 then return end
  local current_line = lines[1]

  local task_match = current_line:match(".*TASK%((.*)%).*")
  if (task_match) then
    local taskfile = vim.fs.joinpath(dbpath, task_match, "TASK.md")
    vim.cmd.edit(vim.fn.expand(taskfile))
  end
end

function TaskTracker.list()
  local dbpath = TaskTracker.__findDatabaseDir()
  if not dbpath then
    return
  end

  if Snacks then
    Snacks.picker.grep({
      cwd = dbpath,
      search = "# ",
      ft = { "markdown" },
      need_search = false,
      hidden = true,
      ignored = true
    })
  end

  vim.notify("TT list implementation without Snacks is not ready yet")
end

return TaskTracker
