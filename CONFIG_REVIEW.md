# Przegląd configu - 2026-08-26

Stan wyjściowy: Neovim 0.11.0 z brew, wszystkie pluginy zaktualizowane do HEAD,
start kończył się błędem `Avante requires at least nvim-0.12`.

## Co zostało zrobione (zacommitowane)

1. **Krok 0** - niezacommitowana praca (migracja LSP na `vim.lsp.config`, csharp_ls,
   snacks image/layout, lazy-lock) wjechała jako checkpoint `dc70d1c`.
2. **Neovim 0.11.0 -> 0.12.5** (`brew upgrade neovim`), razem z `tree-sitter` 0.25.3 -> 0.26.13
   i nowym `tree-sitter-cli` 0.26.13 (brew wydzielił CLI z formuły `tree-sitter`).
   Config był najpierw przetestowany headless na tarballu 0.12.5, dopiero potem poszedł brew.
3. **nvim-treesitter `master` -> `main`.** `master` jest zamrożony i oficjalnie NIE wspiera 0.12,
   `main` wymaga 0.12. `main` to przepisany plugin: instaluje tylko parsery + queries, a
   highlight / foldy / indent włącza się per buffer (autocmd `FileType` w
   `lua/plugins/nvim-treesitter.lua`). Zachowane 1:1: lista parserów, `auto_install`
   (autocmd doinstalowuje brakujący parser), `html` bez treesitter-highlightu,
   regex `syntax` dodatkowo włączony (dawne `additional_vim_regex_highlighting = true`),
   incremental selection pod `<C-s>` / `<BS>` (teraz wbudowane `vim.treesitter.select`).
   Parsery leżą w `~/.local/share/nvim/site/parser` (29 sztuk zainstalowanych).
4. **Deprecated API**: `vim.diagnostic.goto_next/goto_prev` -> `vim.diagnostic.jump`
   (`]d [d ]D [D`), `nvim_win_set_option` -> `vim.wo[win]`, `foldexpr` ->
   `v:lua.vim.treesitter.foldexpr()`.
5. **Avante**: usunięta opcja `behaviour.enable_claude_text_editor_tool_mode` (nie istnieje
   już w configu avante), `input.provider` / `selector.provider = "snacks"`. Wyleciały zależności
   `dressing.nvim` (zarchiwizowany; nadpisywał `vim.ui.input`/`vim.ui.select` Snacksa - checkhealth
   to zgłaszał) i `mini.pick` (używany tylko jako file selector avante).
6. **csharp_ls** włączany tylko gdy `~/.dotnet/tools/csharp-ls` istnieje. Binarka NIE jest
   zainstalowana (`~/.dotnet/tools` nie ma), więc `DOTNET_PLUGINS.md` w sekcji "Działa" się myli.
   Instalacja: `dotnet tool install -g csharp-ls`.

Rollback configu: `git revert` odpowiednich commitów. Rollback Neovima: brew nie ma
`neovim@0.11`; najprościej pobrać tarball `v0.11.x` z GitHub releases (jak zrobiłem z 0.12.5
do testów) albo `brew extract`.

## Propozycje

**Status (runda 2, ten sam dzień): wdrożone sekcje A-G oraz I** - szczegóły na końcu pliku.
Niewdrożone zostały tylko punkty informacyjne (H) i `mmdc` (F).

### A. Martwy kod i konfiguracja (niskie ryzyko, szybkie)

- Specy wyłączonych pluginów: `fzf.lua`, `lspsaga.nvim.lua`, `nvim-cmp.lua`, `nvim-tree.lua`,
  `trouble-nvim.lua` (`enabled = false`). Do skasowania, chyba że trouble ma wrócić
  (DOTNET_PLUGINS.md go proponuje). W `lazy-lock.json` wiszą po nich wpisy
  (`fzf-lua`, `lspsaga.nvim`, `nvim-tree.lua`, `trouble.nvim`).
- `init.lua`: `vim.lsp.buf_request_sync_options` nie jest żadnym API Neovima - no-op.
- `nvim-lspconfig.lua`: `vim.lsp.config("omnisharp", { enabled = false })` - `enabled` nie jest
  polem `vim.lsp.Config`; omnisharp i tak nie jest w `vim.lsp.enable`, więc cały blok jest zbędny.
- `lua_ls.workspace.library` wskazuje `$HOME/nvim/lua` (taki katalog nie istnieje; config jest w
  `~/.config/nvim`). Lazydev i tak to obsługuje - można wyciąć cały `workspace.library`.
- `neoconf.nvim` + `neoconf.json`: `neoconf.json` konfiguruje `neodev`, który został zastąpiony
  przez lazydev. Prawdopodobnie cały neoconf do wyrzucenia (jedyne użycie to `setup({})` w lspconfig).
- `options.lua`: `cmdheight` ustawione 2x, `clipboard` 2x (`=` i `:append`), `encoding`,
  `backspace`, `hidden`, `modifiable`, `errorbells` to już domyślne wartości.
- `util/clear_bufferline.lua`: pierwszy autocmd szuka bufora "bufferline" - taki nie istnieje
  (bufferline rysuje `tabline`, nie ma bufora), więc ta pętla nigdy nic nie robi. Działa tylko
  drugi autocmd (TabLine* na `guibg=NONE`). Można zostawić sam drugi.
- `mason-lspconfig`: `automatic_installation` nie istnieje w v2 (ignorowane). Repo przeniosło się
  na `mason-org/mason.nvim` i `mason-org/mason-lspconfig.nvim` - GitHub redirect działa, ale warto
  podmienić nazwy zanim przestanie.

### B. Pluginy do zastąpienia wbudowanymi funkcjami Neovima

- `Comment.nvim` (ostatni commit 06.2024) -> wbudowane `gc`/`gcc` (od 0.10). Jedyna Twoja
  customizacja to `<leader>/` jako toggle linii: `vim.keymap.set("n", "<leader>/", "gcc", { remap = true })`
  i `vim.keymap.set("x", "<leader>/", "gc", { remap = true })`.
- `vim-highlightedyank` -> `vim.hl.on_yank({ timeout = 150 })` w autocmd `TextYankPost`.
- Snacks `undo` picker vs wbudowane `:Undotree` (0.12) - do porównania, nic pilnego.

### C. Konflikty keymapów (do wyboru, które mają wygrać)

- `<leader>/`: Comment.nvim (toggle komentarza) **wygrywa** z `Snacks.picker.grep()`
  ze `snacks.lua`. Grep i tak jest pod `<leader>sf`. Wpis w snacks jest martwy.
- `<leader>sb`: zmapowane 2x w `snacks.lua` (`grep_buffers` i `lines`); wygrywa `lines`.
- `<leader>lf`: w `keymaps.lua` (LspAttach) i w `which-key.lua` - to samo działanie, tylko
  dublowanie.
- `<leader>st`: desc "Grep for packages" (copy-paste z `<leader>sp`).
- `<leader>d` to grupa "DiffView"; plan DAP z `DOTNET_PLUGINS.md` chce `<leader>d*` na debug -
  do rozstrzygnięcia przed wdrożeniem DAP.

### D. LSP / narzędzia zewnętrzne

- **efm** odwołuje się do narzędzi, których nie ma ani w PATH, ani w Masonie: `fixjson`, `shfmt`,
  `hadolint`, `cpplint`, `clang-format`. Efekt: formatowanie json/sh/dockerfile/c/cpp po cichu
  nie działa. Albo `:MasonInstall shfmt hadolint fixjson cpplint clang-format`, albo wyciąć te
  języki z efm. (`luacheck`, `stylua`, `black`, `flake8`, `prettierd`, `biome`, `shellcheck` są.)
- Mason ma zainstalowane **oba** `emmet-ls` i `emmet-language-server`; config używa `emmet_ls`.
  Drugi do odinstalowania (albo przejść na `emmet_language_server`, który jest aktywniej rozwijany).
- `ensure_installed` instaluje `tailwindcss`, `solidity_ls` i (ręcznie) `vue-language-server`,
  ale żaden nie ma `vim.lsp.config` ani nie jest w `vim.lsp.enable` - martwe instalacje.
  Tailwind: `vim.lsp.enable("tailwindcss")` to jedna linia, jeśli go używasz.
- **typescript-tools.nvim**: ostatnia aktywność 11.2025. `tsserver_plugins` wymaga globalnie
  `@styled/typescript-styled-plugin` i `@vue/typescript-plugin` - w `npm ls -g` ich nie ma, więc
  te pluginy i tak nie działają. Alternatywa: `vtsls` przez lspconfig (`:MasonInstall vtsls`,
  `vim.lsp.enable("vtsls")`), aktywnie utrzymywany, te same komendy (organize imports itd.
  przez code actions).
- `eslint`: `settings.experimental.useFlatConfig` - nowy lspconfig sam wykrywa flat config;
  do sprawdzenia, czy ta opcja jest jeszcze potrzebna (jest nieszkodliwa).
- `bashls.filetypes` zawiera `aliasrc` - filetype, którego nic nie ustawia.

### E. Treesitter - dalsze kroki po migracji

- `vim.bo.syntax = "ON"` na wierzchu treesittera (odziedziczone z
  `additional_vim_regex_highlighting = true`) - podwójny highlight kosztuje na dużych plikach i
  potrafi psuć kolory. Sugeruję wyłączyć i sprawdzić, czy czegoś brakuje (typowy powód włączania
  to markdown, a 0.12 ma tam własny highlight TS).
- `html` bez highlightu TS - prawdopodobnie relikt starego buga. Warto włączyć i zobaczyć.
- `nvim-ts-autotag` już się nie konfiguruje przez treesitter; ma własny spec z `opts`.

### F. Lazy / drobne

- `checkhealth lazy` narzeka na brak Lua 5.1 (luarocks). Żaden plugin tego nie potrzebuje:
  `rocks = { enabled = false }` w `lua/config/lazy.lua`.
- `Snacks.image`: brak `mmdc` (mermaid) - `npm i -g @mermaid-js/mermaid-cli`, jeśli chcesz
  renderować diagramy. Ghostty obsługuje kitty graphics, więc obrazki działają.

### G. Bugi w `lua/util`

- `diff_upload.lua:79`: `buf_temp` jest `local` wewnątrz gałęzi `else`, a używany poza nią ->
  w ścieżce "nie w repo git" `os.remove(nil)` rzuci błąd.
- `create_stash.lua`: nazwa stasha wstawiana w `'%s'` bez escapowania - apostrof w nazwie
  rozwali komendę. Lepiej `vim.fn.system({ "git", "stash", "push", "-u", "-m", name })`.
- `file_from_commit.lua:132`: nieużywany argument (luacheck), kosmetyka.

### H. Nowości 0.12, które mogą Cię zainteresować

- `:restart` / `ZR` - restart Neovima z odtworzeniem sesji (przydatne po zmianach configu).
- `vim.pack` - wbudowany menedżer pluginów; nie ma powodu porzucać lazy, ale istnieje.
- `'pumborder'`, `'diffopt'` z `inline:char` domyślnie, `:lsp` do zarządzania klientami,
  `:checkhealth vim.lsp`.
- Wbudowana incremental selection: `an` / `in` / `]n` / `[n` w visual (masz też `<C-s>`/`<BS>`).

### I. .NET (`DOTNET_PLUGINS.md`)

Plan jest OK, ale krok zero to instalacja `csharp-ls` (dziś nie istnieje). `netcoredbg` i
`csharpier` też nie są zainstalowane. Bez tego cała sekcja "Działa" w dokumencie jest na wyrost.

## Runda 2 - co zostało wdrożone

- **Sesje** (`lua/config/sessions.lua`): root repo liczony przez `vim.system({"git", ...})`
  bez shella - hook zsh-a dopisywał "Using Node v22.12.0" do nazwy pliku sesji.
  `sessionoptions` bez `folds` (mksession zapisywał `normal! zo`, które przy treesitterowych
  foldach kończyło się `E490` i przerywało ładowanie). Ładowanie przez `silent! source`, więc
  stare pliki sesji z foldami też wchodzą. Sześć plików `git_Using Node v*_...vim` w
  `~/.local/share/nvim/sessions` przemianowane na właściwe nazwy; starszy plik fable-app
  został jako `*.pre-2026-08-26.bak`.
- **A. Porządki**: skasowane specy `fzf`, `lspsaga`, `nvim-cmp`, `nvim-tree`, `trouble`
  (+ `util/keymapper.lua`, używany tylko przez trouble), `neoconf` + `neoconf.json`,
  `vim.lsp.buf_request_sync_options`, blok `omnisharp`, `lua_ls.workspace.library`,
  `bashls` z `aliasrc`; `options.lua` bez duplikatów; `clear_bufferline.lua` to już tylko
  autocmd na highlighty; `automatic_installation` usunięte; repo Masona -> `mason-org/*`.
  `lazy-lock.json` bez martwych wpisów.
- **B. Wbudowane zamiast pluginów**: `Comment.nvim` -> `gc`/`gcc` z `<leader>/` (normal i
  visual, `lua/config/keymaps.lua`); `vim-highlightedyank` -> `vim.hl.on_yank` (150 ms,
  `init.lua`).
- **C. Keymapy**: z `snacks.lua` wyleciał martwy `<leader>/` (grep) i zdublowany `<leader>sb`
  (zostaje `lines`), `<leader>st` ma poprawny opis, `<leader>lf` tylko w `LspAttach`.
- **D. LSP**: `typescript-tools.nvim` -> **vtsls** (Mason). Komendy `<leader>lo/ls/li/lF/lu/ll`
  są w `lua/util/typescript.lua` jako code actions / komendy vtsls (organize, sort, add
  missing imports, fix all, remove unused, file references -> quickfix). Inlay hints
  przeniesione 1:1. Plugin `@vue/typescript-plugin` bierze się z Masonowego
  `vue-language-server`, `vue_ls` włączony. Włączone `tailwindcss` i `solidity_ls`
  (attachują się tylko przy własnych root markerach). Mason doinstalował `shfmt`, `hadolint`,
  `fixjson`, `cpplint`, `clang-format`, `vtsls`; `emmet-language-server` odinstalowany.
- **E. Treesitter**: bez `syntax=ON` na wierzchu i bez wyjątku dla `html` - czysty treesitter.
  To jedyna zmiana czysto wizualna, obejrzyj kolory w TS/TSX/HTML.
- **F.** `rocks.enabled = false` w lazy.
- **G. util**: `diff_upload.lua` (`buf_temp` poza gałęzią), `create_stash.lua` (nazwa stasha
  jako argument listy, bez cytowania shella), `file_from_commit.lua` (nieużywany argument).
- **I. .NET**: `csharp-ls` zainstalowany jako `dotnet tool` w wersji **0.16.0** - nowsze
  wersje nie instalują się na SDK .NET 8 ("DotnetToolSettings.xml was not found").
  `netcoredbg` i `csharpier` nadal nie ma.
