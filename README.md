# task.nvim

Task is a Neovim plugin to easily run any script defined in your file.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'micah-effiong/task.nvim',
  config = function()
    require('task')
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'maxolasersquad/task.nvim',
  cond = function()
    return vim.fn.filereadable(vim.fn.getcwd() .. '/tasks.json') == 1
  end,
  config = function()
    require('task')
    -- Optional: Add your key mapping here
    vim.api.nvim_set_keymap('n',
      '<leader>tk',
      ':Task<CR>',
      { noremap = true, silent = false }
    )
  end
}
```

## Usage

```json
// ./tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run tests",
      "type": "shell",
      "command": "npm run test"
    },
    {
      "label": "Tsc watch",
      "type": "shell",
      "command": "npx tsc",
      "args": ["--watch"]
    }
  ]
}
```

It also supports npm projects that use `package.json`

If we assume your `package.json` contains the following `scripts` object:

```json
  "scripts": {
    "dev": "DEBUG=app:* tsx watch src/index.ts",
    "start": "node dist/index.js"
  }
```

You can run the `start` script by typing `:Task start`. You can also type
`:Task <Tab>` to auto-complete all available scripts.

Running `:Task` will popup all available tasks
