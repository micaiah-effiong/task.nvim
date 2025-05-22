# task.nvim

Task is a Neovim plugin to easily run any script defined in your file.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'micah-effiong/task.nvim'
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

```jsonc
// ./tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "echo",
      "type": "shell",
      "command": "echo '[[ECHOING]]'"
    },
    {
      "label": "GLog",
      "type": "shell",
      "command": "git log",
      "args": [
        "--oneline",
        "--graph"
      ]
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

Running `:Task` will pop up and display all available tasks


### Troubleshoot
If you are having trouble getting it to run, try this
```diff
{
  'micah-effiong/task.nvim',
+  config = function()
+    require('task')
+  end
}
```
