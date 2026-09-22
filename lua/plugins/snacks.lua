local session = require("config.sessions")

local win_width = 0.90
local win_height = 0.88

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    -- DEBUG: wyłączone tymczasowo
    debug = { enabled = false },
		dashboard = {
			enabled = true,
			preset = {
				keys = {
          { icon = " ", key = "s", desc = "Restore Session", action = session.load_session },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
    explorer = { enabled = true },
    image = {
      enabled = true,
      doc = {
        inline = false,
        float = false,
        max_width = 80,
        max_height = 40,
      },
      convert = {
        notify = true,
        mermaid = function()
          local theme = vim.o.background == "light" and "neutral" or "dark"
          return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}" }
        end,
      },
    },
    indent = { enabled = false },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 2000,
    },
    picker = {
      enabled = true,
      layout = {
        layout = {
          width = win_width,
          height = win_height,
        },
      },
      sources = {
        explorer = { hidden = true, ignored = true },
      },
      -- config = function(opts)
      --   -- In a monorepo, snacks might not detect the project root correctly.
      --   -- This logic ensures that we always use the git root as the cwd for the picker.
      --   local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      --   if vim.v.shell_error == 0 and root and root ~= "" then
      --     opts.cwd = root
      --   end
      --   return opts
      -- end,
      win = {
        input = {
          keys = {
            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
            ["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
          },
        },
        -- Same swap for the list window - the explorer keeps focus there
        -- (tree in normal mode), so the input-window keys never apply.
        list = {
          keys = {
            ["<c-u>"] = "preview_scroll_up",
            ["<c-d>"] = "preview_scroll_down",
            ["<c-f>"] = "list_scroll_down",
            ["<c-b>"] = "list_scroll_up",
          },
        },
      },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = false },
    scratch = { enabled = false },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      }
    },
    lazygit = {
      -- configure = true, -- automatically configure LazyGit
      config = {
        os = {
          editPreset = "nvim-remote",
          -- editInTerminal = true,
          open = 'nvim --server ' .. vim.v.servername .. ' --remote-tab {{filename}}',
          openLink = 'open {{link}}',
        },
        keybinding = {
          files = {
            openFile = 'o',
          },
        },
      },
      win = {
        width = win_width,
        height = win_height,
      },
    },
  },
  keys = {
    -- Image
    { "<leader>i", function() Snacks.image.hover() end, desc = "Preview Image/Diagram" },
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>N", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>E", function() Snacks.picker.explorer({ layout = { preset = "sidebar", preview = false, layout = { width = 40, min_width = 40, height = 0 } } }) end, desc = "File Explorer" },
		{
			"<leader>e",
			function()
				Snacks.picker.explorer({
					layout = {
						preset = "default",
						preview = true,
					},
					auto_close = true,
					jump = { close = true },
				})
			end,
			desc = "File Explorer",
		},
    -- find
    { "<leader>f", function() Snacks.picker.git_files() end, desc = "Git Files" },
    -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    -- { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    -- { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    -- git
    -- { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gC", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
    { "<leader>gd", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>go", function() Snacks.picker.git_stash() end, desc = "Show Stash" },
    { "<leader>gD", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
    -- { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
    -- Grep
    -- { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sf", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sF", function() Snacks.picker.files() end, desc = "Files" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    { "<leader>sp", function() Snacks.picker.files({ search = "package.json" }) end, desc = "Grep for packages" },
    { "<leader>st", function() Snacks.picker.files({ search = "todo" }) end, desc = "Find todo files" },
    { "<leader>sr", function() Snacks.picker.recent() end, desc = "Recent" },
    { "<leader>sP", function() Snacks.picker.projects() end, desc = "Projects" },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    -- { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    -- { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    -- { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    -- { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    -- LSP
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>lR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    -- Other
    -- { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    -- { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    -- { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    -- { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    -- { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    -- { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
    -- { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    -- { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
