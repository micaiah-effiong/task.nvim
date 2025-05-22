---@alias Callback fun(selection: string)

local M = {}

---@param opt string[]
---@param cb Callback
M.open_menu = function(opt, cb)
  local opts = opt

  if vim.fn.len(opt) == 0 then
    print "No tasks found"
    return
  end

  vim.ui.select(opts, {}, function(selection, number)
    cb(selection)
  end)
end

return M
