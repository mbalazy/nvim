# Propozycje pluginów Neovim dla .NET

## Obecny stan

**Działa:**
- LSP: csharp-ls
- Completion: blink.cmp + friendly-snippets
- Nawigacja LSP: gd, gr, gI, gy (snacks.nvim)
- Formatery: EFM (brak C# formattera)
- Treesitter: c_sharp

**Brakuje:**
- Debugger (DAP)
- Test runner
- C# formatter (csharpier)

---

## 1. nvim-dap + nvim-dap-ui + nvim-dap-cs (NAJWAŻNIEJSZE)

Debugowanie z breakpointami.

**Use case:**
- Breakpoint na linii (F9)
- Start debugging (F5)
- Step over/into (F10/F11)
- Widok zmiennych, call stack, watch

**Instalacja:**

```lua
-- lua/plugins/dap.lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio", -- wymagane przez dap-ui
      "NicholasMata/nvim-dap-cs",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup dap-ui
      dapui.setup()

      -- Auto open/close dap-ui
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- Setup C# debugger (netcoredbg)
      require("dap-cs").setup()

      -- Keymaps
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
    end,
  },
}
```

**Wymaga zainstalowania netcoredbg:**
```bash
# Mason powinien zainstalować automatycznie, lub:
brew install netcoredbg
```

**Źródła:**
- https://github.com/mfussenegger/nvim-dap
- https://github.com/rcarriga/nvim-dap-ui
- https://github.com/NicholasMata/nvim-dap-cs

---

## 2. easy-dotnet.nvim (All-in-one .NET)

Test runner + utilities dla .NET.

**Use case:**
- `:Dotnet build` / `:Dotnet run` / `:Dotnet test`
- Test runner podobny do Rider
- User secrets management
- Może zastąpić csharp-ls (ma Roslyn LSP)

**Instalacja:**

```lua
-- lua/plugins/easy-dotnet.lua
return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim", -- lub można użyć snacks picker
  },
  ft = { "cs", "fsharp", "vb" },
  config = function()
    local dotnet = require("easy-dotnet")
    dotnet.setup({
      -- Nie używaj wbudowanego LSP - mamy csharp-ls
      -- roslyn = { enabled = false },
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>nr", function() dotnet.run_project() end, { desc = ".NET: Run" })
    vim.keymap.set("n", "<leader>nb", function() dotnet.build() end, { desc = ".NET: Build" })
    vim.keymap.set("n", "<leader>nt", function() dotnet.test() end, { desc = ".NET: Test" })
    vim.keymap.set("n", "<leader>nc", function() dotnet.clean() end, { desc = ".NET: Clean" })
  end,
}
```

**Źródło:** https://github.com/GustavEikaas/easy-dotnet.nvim

---

## 3. Włącz trouble.nvim (już masz!)

Zmień w `lua/plugins/trouble-nvim.lua`:

```lua
enabled = true,  -- było: enabled = false
```

**Keymaps (już skonfigurowane):**
- `<leader>xx` - toggle trouble
- `<leader>xw` - workspace diagnostics
- `<leader>xd` - document diagnostics

**Źródło:** https://github.com/folke/trouble.nvim

---

## 4. Dodaj csharpier do EFM

Formatter dla C#.

**Instalacja csharpier:**
```bash
dotnet tool install -g csharpier
```

**Dodaj do `lua/plugins/nvim-lspconfig.lua`:**

```lua
-- Po innych requires (linia ~126)
local csharpier = {
  formatCommand = "dotnet csharpier --write-stdout",
  formatStdin = true,
}

-- W settings.languages (linia ~152) dodaj:
cs = { csharpier },
```

**Dodaj "cs" do filetypes EFM (linia ~129):**
```lua
filetypes = {
  -- ... existing
  "cs",
},
```

---

## 5. which-key - dodaj grupy dla .NET i Debug

W `lua/plugins/which-key.lua` dodaj:

```lua
{ "<leader>n", group = ".NET" },
{ "<leader>d", group = "Debug/Diff" },  -- zmień istniejący "DiffView" na wspólny
```

---

## Kolejność implementacji

1. **nvim-dap** - najważniejsze, debugowanie
2. **trouble.nvim** - tylko zmień enabled na true
3. **csharpier** - prosty formatter
4. **easy-dotnet.nvim** - opcjonalnie, jeśli potrzebujesz test runner

---

## Przydatne komendy po instalacji

```vim
:Mason                    " sprawdź czy netcoredbg jest zainstalowany
:DapContinue              " start debugging (lub F5)
:DapToggleBreakpoint      " toggle breakpoint (lub <leader>db)
:Trouble                  " toggle trouble window
```
