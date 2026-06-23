local npm    = require "task.npm"
local popup  = require "task.popup"
local tfs    = require "task.fs"

local M      = {}

---@type Config
local config = {
  position = 'belowright'
}

---@type integer|nil
local edit_buffer;

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

  return vim.tbl_deep_extend('error', commands, npm.get_commands())
end

local function complete_command(lead, _, _)
  local matches = {} ---@type string[]

  for _, cmd in pairs(get_commands()) do
    if cmd.name:find(lead, 1, true) == 1 then
      table.insert(matches, cmd.name)
    end
  end

  return matches
end

---@param command_name string
---@param commands Command
local function run_task_command(command_name, commands)
  local task_cmd = commands[command_name]

  if task_cmd == nil then
    print "No command found"
    return
  end

  local args = task_cmd.args ~= nil and table.concat(task_cmd.args, " ") or ""
  local command = task_cmd.cmd .. " " .. args

  -- vim.api.nvim_win_set_height(0, 5)
  vim.cmd(config.position .. " terminal " .. command)
end

---@param filename string
local function edit_task_file(filename)
  if edit_buffer ~= nil then
    local win = vim.fn.bufwinid(edit_buffer)

    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
    else
      vim.cmd.buffer(edit_buffer)
    end

    return
  end

  vim.cmd.vsplit(filename)
  vim.bo.filetype = 'json'
  edit_buffer = vim.api.nvim_get_current_buf()

  vim.api.nvim_create_autocmd('WinClosed', {
    buffer = edit_buffer,
    once = true,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(edit_buffer) then
          vim.api.nvim_buf_delete(edit_buffer, { force = false })
          edit_buffer = nil
        end
      end)
    end
  })
end

---@param opt Config
M.setup = function(opt)
  opt = opt or {}
  config = vim.tbl_deep_extend('force', config, opt)

  vim.api.nvim_create_user_command("Task", function(opts)
    local commands = get_commands()
    if vim.fn.len(opts.args) == 0 then
      local keys = {}

      for key, _ in pairs(commands) do
        table.insert(keys, key)
      end

      popup.open_menu(keys, function(selection)
        run_task_command(selection, commands)
      end)
      return
    else
      run_task_command(opts.args, commands)
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

    edit_task_file(filepath)
  end, {})

  vim.api.nvim_create_user_command("TaskEdit", function(_)
    local dir = tfs.git_root()

    if dir == nil then
      print('Not a git repository')
      return
    end

    local filepath = tfs.task_datafile(dir)
    if vim.uv.fs_stat(filepath) ~= nil then
      edit_task_file(filepath)
    else
      print('No existing task file.')
    end
  end, {})
end

return M
