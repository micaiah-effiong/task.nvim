local npm   = require "task.npm"
local popup = require "task.popup"
local tfs   = require "task.fs"

local M     = {}

---Commands table
---@type table<string, Command>
local C     = {}

-- local json_content = [[{
--   "version": "2.0.0",
--   "tasks": [
--     {
--       "label": "Run tests",
--       "type": "shell",
--       "command": "node",
--       "args": ["-v"],
--       "windows": {
--         "command": ".\\scripts\\test.cmd"
--       },
--       "group": "test",
--       "presentation": {
--         "reveal": "always",
--         "panel": "new"
--       }
--     }
--   ]
-- }]]

---@type get_commands
local function get_commands()
  local key = tfs.git_root()
  if key == nil then
    return {}
  end

  local content_json = tfs.task_read_data(key);

  if not content_json then
    return {}
  end

  local _tasks = content_json.tasks ---@type TaskItem[]|TaskItem
  local commands = {} ---@type table<string, Command>

  ---@type TaskItem[]
  local tasks = vim.isarray(_tasks) and _tasks or { _tasks }

  if vim.islist(tasks) then
    for _, task in pairs(tasks) do
      if task.type ~= "shell" then
        --
      else
        -- table.insert(commands, { name = task.label, cmd = task.command })
        local item = { name = task.label, cmd = task.command, args = task.args }
        commands[task.label] = item
      end
    end
  end

  commands = vim.tbl_deep_extend('error', commands, npm.get_commands())

  return commands
end

local function load_commands()
  C = {}
  C = vim.tbl_deep_extend('error', C, get_commands())
end

local function complete_command(lead, _, _)
  load_commands() --- update command table
  local commands = C
  local matches = {} ---@type string[]

  for _, cmd in pairs(commands) do
    if cmd.name:find(lead, 1, true) == 1 then
      table.insert(matches, cmd.name)
    end
  end

  return matches
end

---@param command_name string
local function run_task_command(command_name)
  local task_cmd = C[command_name]

  if task_cmd == nil then
    print "No command found"
    return
  end

  local args = task_cmd.args ~= nil and table.concat(task_cmd.args, " ") or ""
  local command = task_cmd.cmd .. " " .. args

  -- vim.cmd.wincmd("J")
  -- vim.api.nvim_win_set_height(0, 5)
  -- local job_id = vim.bo.channel

  vim.cmd("bel terminal " .. command)
end

vim.api.nvim_create_user_command("Task", function(opts)
  if vim.fn.len(opts.args) == 0 then
    local keys = {}
    load_commands() --- update command table

    for key, _ in pairs(C) do
      table.insert(keys, key)
    end

    popup.open_menu(keys, function(selection)
      run_task_command(selection)
    end)
    return
  else
    run_task_command(opts.args)
  end
end, { nargs = "*", complete = complete_command })

vim.api.nvim_create_user_command("TaskCreate", function(_)
  local dir = tfs.git_root()

  if dir == nil then
    print('Not a git repository')
    return
  end

  local filepath = tfs.task_datafile(dir)
  if vim.uv.fs_stat(filepath) == nil then
    tfs.task_create_data(dir)
  end

  -- edit file
  vim.cmd.edit(filepath)
end, {})

vim.api.nvim_create_user_command("TaskEdit", function(_)
  local dir = tfs.git_root()

  if dir == nil then
    print('Not a git repository')
    return
  end

  local filepath = tfs.task_datafile(dir)
  if vim.uv.fs_stat(filepath) ~= nil then
    vim.cmd.edit(filepath)
  else
    print('No existing task file.')
  end
end, {})

M.setup = function()
end

return M
