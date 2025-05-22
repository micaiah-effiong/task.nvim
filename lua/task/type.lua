---@alias field "shell"

---@class TaskItem
---@field label string
---@field type field
---@field command string
---@field args? string[]

---@class TaskJSON
---@field version string
---@field tasks TaskItem[]|TaskItem

---@class Command
---@field name string
---@field cmd string
---@field args? string[]


---@alias get_commands fun(): table<string, Command>
