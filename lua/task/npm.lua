local M = {}

local function read_package_json()
  local file = io.open("package.json", "r")
  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()

  local package_json = vim.fn.json_decode(content)
  return package_json and package_json.scripts or {}
end

---@type get_commands
M.get_commands = function()
  local scripts = read_package_json()
  ---@type table<string, Command>
  local commands = {}

  for cmd, _ in pairs(scripts) do
    ---@type Command
    local task_cmd = { cmd = "npm run " .. cmd, name = "npm:" .. cmd }
    commands[task_cmd.name] = task_cmd
  end

  return commands
end

return M
