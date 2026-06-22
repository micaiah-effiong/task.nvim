local default_task = {
  version = "0.0.1",
  tasks = {}
}

local M = {}

M.git_root = function()
  local file = vim.api.nvim_buf_get_name(0)
  local dir
  local cwd = vim.fn.getcwd()

  if file == '' then
    dir = cwd
  else
    dir = vim.fs.dirname(file)
  end

  --- @type string
  local groot = vim.fn.systemlist('git -C ' ..
    vim.fn.escape(dir, ' ') ..
    ' rev-parse --show-toplevel')[1]

  if vim.v.shell_error ~= 0 then
    return nil
  else
    return groot
  end
end

local function task_datadir()
  return vim.fn.stdpath('data') .. '/task'
end

---It takes your cwd and hashes it into a filename
---@param key string
---@return string
M.task_datafile = function(key)
  local dir = vim.fn.stdpath('data') .. '/task'
  local filename = vim.fn.sha256(key)
  local data_file = dir .. '/' .. filename .. '.task'
  return data_file
end

M.task_create_data = function(path)
  local data = vim.json.encode(default_task)
  if data == nil then
    return
  end

  vim.fn.mkdir(task_datadir(), 'p')
  local file = io.open(M.task_datafile(path), 'w')

  file:write(data)
  file:close()
end

---@param key string
---@param obj TaskJSON
M.task_write_data = function(key, obj)
  local data = vim.json.encode(obj)
  if data == nil then
    return
  end

  local file = io.open(M.task_datafile(key), 'w')

  file:write(data)
  file:close()
end


---@return TaskJSON | nil
M.task_read_data = function(key)
  local file = io.open(M.task_datafile(key), 'r')
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  local tasks_json = vim.fn.json_decode(content)

  if not tasks_json.tasks and not tasks_json.version then
    return nil
  end

  return tasks_json
end

return M
