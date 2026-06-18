# task.nvim

Task is a Neovim plugin to easily run any script defined in your file.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'micah-effiong/task.nvim'
}
```

### Using Vim pack

```lua
vim.pack.add('https://github.com/micah-effiong/task.nvim')
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'micah-effiong/task.nvim',
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

Here is an example of the task data

```jsonc
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "echo",
      "type": "shell",
      "command": "echo '[[ECHOING]]'",
    },
    {
      "label": "GLog",
      "type": "shell",
      "command": "git log",
      "args": ["--oneline", "--graph"],
    },
  ],
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
Other commands include

- TaskCreate: This create a task file for your project. Expect you to be in a
  git repository
- TaskEdit: This opens the task file for editing

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
