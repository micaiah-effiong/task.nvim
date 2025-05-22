local npm = require "task.npm"
local popup = require "task.popup"
require "table.clear"

---Commands table
---@type table<string, Command>
local C = {}

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

-- ---@return TaskJSON
-- local function read_task_json()
--   return vim.fn.json_decode(json_content)
-- end


---@return TaskJSON | nil
local function read_task_json()
  local file = io.open("tasks.json", "r")
  if not file then
    return {}
    -- allow for check in another folder
    -- TODO: should use find to look for tasks.json file
  end


  local content = file:read("*a")
  file:close()

  local tasks_json = vim.fn.json_decode(content)

  if not tasks_json.tasks and not tasks_json.version then
    return nil
  end

  return tasks_json
end

---@type get_commands
local function get_commands()
  local content_json = read_task_json();

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
  table.clear(C)
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

load_commands()
