# Pluginy i ich alternatywy - analiza na 2026-08-26

Stan: Neovim 0.12.5 (stable z 2026-08-23), config po przeglądzie z `CONFIG_REVIEW.md`.
Metoda: pięć niezależnych researchy webowych (infra, completion, AI, UI, edycja/git), każdy
plugin sprawdzony przez `gh api` (data ostatniego pusha, gwiazdki, otwarte issue) i README /
release notes; kluczowe twierdzenia zweryfikowane lokalnie (daty commitów w
`~/.local/share/nvim/lazy`, grep grup highlight, runtime 0.12.5). Kryteria z Twojego zlecenia:
tylko utrzymywane projekty, preferowane Lua, nie szukamy starych pluginów.

Skrót werdyktów: **KEEP** = zostaw, **SWITCH** = zamień, **DROP** = wywal, **CONSIDER** =
warto rozważyć, nie pilne, **WATCH** = działa, ale obserwuj.

---

## 0. TL;DR - co faktycznie zmienić

Posortowane wg (wartość / ryzyko). Wszystko poniżej to propozycje, nic nie wdrożone.

| # | Co | Werdykt | Dlaczego w jednym zdaniu |
|---|----|---------|--------------------------|
| 1 | `sindrets/diffview.nvim` -> `dlyongemallo/diffview-plus.nvim` | **SWITCH** | diffview: ostatni commit 2024-06-13 (ponad 2 lata, 131 issue); fork pushowany dziś, drop-in (te same komendy). |
| 2 | `tokyodark.nvim` -> `tokyonight.nvim` (albo catppuccin) | **SWITCH** | tokyodark ma **0** grup highlight dla Snacks, Blink, Noice, Bufferline - pickery i menu completion jeżdżą na fallbackach; tokyonight ma ich setki i ten sam autor co snacks/noice/which-key. |
| 3 | `bufferline.nvim` -> nic / `mini.tabline` / `barbar.nvim` | **DROP lub SWITCH** | 19 miesięcy bez commita, 25 wiszących PR; masz `Snacks.picker.buffers()` pod `<leader>,`. Tydzień bez bufferline, potem decyzja. |
| 4 | avante: provider ACP `claude-code` | **CONSIDER (tanie)** | avante ma wbudowany provider ACP jadący na Twoim `claude` (subskrypcja, nie tokeny API); wymaga `npm i -g @agentclientprotocol/claude-agent-acp`; **domyślnie `bypassPermissions`** - ustaw świadomie. |
| 5 | Kolizja `<C-s>` (blink snippets vs wbudowane signature help 0.12) | **FIX (1 linia)** | 0.12 mapuje `i_CTRL-S` globalnie na `vim.lsp.buf.signature_help()`; Twój blink nadpisuje to pokazywaniem snippetów. |
| 6 | efm + efmls-configs -> `conform.nvim` + `nvim-lint` | **CONSIDER** | efm jest utrzymywany, ale conform robi minimalne diffy (foldy/extmarki przeżywają format), range-format dla każdego narzędzia, fallbacki `prettierd -> prettier`; wszystkie Twoje 12 narzędzi pokryte. |
| 7 | noice -> wbudowane `ui2` (0.12) | **CONSIDER / WATCH** | noice: ostatni release 2025-02, commit 2025-11, otwarty bug z pollingiem 33 ms na idle; `ui2` jest eksperymentalne i trzyma cmdline na dole (Twoja wyśrodkowana paleta znika). Nie włączaj obu naraz (neovim#38916). |
| 8 | vtsls -> `tsc` (TypeScript 7 z natywnym `--lsp`) | **WATCH** | TS 7.0 (2026-07-08) ma standardowe LSP; `lsp/tsc.lua` w lspconfig ma 2 tygodnie; **oba Twoje repo są na TS 5.9**, więc dziś i tak niedostępne. vtsls od grudnia 2025 ma same bumpy dependabota. |
| 9 | Brak textobjectów: `mini.ai` (albo `nvim-treesitter-textobjects` main) | **CONSIDER (dodać)** | Największa realna luka funkcjonalna: brak `af`/`if`/`ac`/`ic`. |
| 10 | `nvim-treesitter-context`, `flash.nvim`, `grug-far.nvim` | **CONSIDER (dodać)** | Sticky nagłówek funkcji, skoki po labelach, search&replace po projekcie - wszystkie żywe. |

Darmowe drobiazgi z 0.12, bez pluginów: `vim.o.winborder = "rounded"` (masz `single`),
`completeopt:append("popup")`, `vim.ui.progress_status()` i `vim.diagnostic.status()` w
statusline, `:restart` / `ZR`, `SessionLoadPre` do własnego managera sesji.

Ryzyko przekrojowe: noice, snacks, which-key, lazy.nvim, lazydev (i tokyonight, jeśli
przejdziesz) to jeden autor (folke), którego aktywność w Neovimie w 2026 wyraźnie spadła
(flash.nvim i LazyVim nadal ruszane, reszta cicho). Dwa ekosystemy, które dziś niewątpliwie
kwitną: `nvim-mini/mini.nvim` (push codziennie, v0.18.0 06.2026, prawie zero otwartych issue)
i `fzf-lua`. Uwaga: mini.nvim przeniósł się do organizacji **`nvim-mini/`** (stare `echasnovski/`
przekierowuje).

---

## 1. Fundament: manager pluginów, Mason, lspconfig

### 1.1 lazy.nvim (masz) vs `vim.pack` (0.12) vs mini.deps

**lazy.nvim** - ostatni commit na main 2025-12-17 (rockspec + dependabot), ostatni
funkcjonalny 2025-11-06 = release v11.17.5. 53 otwarte PR (najstarszy z 2024-07). Nie ma
potwierdzonego bugu na 0.12 (issue "crash on 0.12.4" zamknięte jako błąd usera), ale dwa
otwarte dotyczą `runtimepath` przy bootstrapie (#2153, #2177) - istotne, bo masz treesitter.
**Werdykt: KEEP, WATCH.** Działa, ale to "coasting", nie rozwój.

**`vim.pack`** (wbudowany, `:h vim.pack`, w źródle literalnie "experimental, yet should be stable
enough for daily use"):
- ma: lockfile (`nvim/nvim-pack-lock.json`), `:packupdate` z buforem potwierdzenia,
  równoległy blobless clone, pinowanie wersją/tagiem/rangem, hooki `PackChangedPre`/`PackChanged`
  (build piszesz sam przez `vim.system`), `add({...}, {load=false})`.
- nie ma: **żadnego deklaratywnego lazy-loadingu** (`event=`, `ft=`, `cmd=`, `keys=`), grafu
  zależności, `opts`/`config`, `import` katalogu, profilera. Manifest `pkg.json` ze skryptami
  jest dopiero na masterze (0.13).
- lepsze: zero pluginu, core team, brak migracji v11 -> v12.
- gorsze: Twoje ~30 speców z `event`/`keys` musiałbyś przepisać na własne autocmd.
**Werdykt: nie teraz.** Trigger do migracji = realny break lazy.nvim na 0.13, nie sama cisza.

**mini.deps** (`nvim-mini/mini.nvim`) - jedyna żywa alternatywa o porównywalnej pracy:
dwustopniowy `now()`/`later()` (grubszy niż eventy lazy), snapshot jako lockfile.
`rocks.nvim` (żywy, luarocks-first) to zmiana paradygmatu; `paq-nvim` 17 miesięcy ciszy;
`packer` martwy.

### 1.2 mason.nvim + mason-lspconfig

- **mason.nvim** v2.3.1 (2026-06-11), realna praca w 2026 (firewall Socket.dev, pakiety
  "system"). **KEEP.**
- **mason-lspconfig** - push dziś, ale od 2026-06-28 wyłącznie `chore: update generated code`
  (regenerowana tabela mapowań serwer <-> pakiet). To jest dokładnie jego zadanie, więc liczy
  się jako utrzymywany. U Ciebie po `automatic_enable = false` używasz go **tylko** do
  `ensure_installed` z nazwami lspconfig (`lua_ls` zamiast `lua-language-server`). Cienki, ale
  auto-utrzymywana tabela nazw jest warta jednego pluginu. **KEEP.**
- Alternatywy: czysty lspconfig + serwery z brew/npm - przy 15 serwerach (vtsls, emmet, astro,
  tailwind, csharp_ls, clangd, efm...) to realna robota i gorsza reprodukowalność; **nie warto**.
  `mason-tool-installer` - push 2026-01, README dalej wskazuje `williamboman/*`, otwarte
  #79 z v2 od 15 miesięcy, i sam zależy od mason-lspconfig; **skip**.
- **nvim-lspconfig** - push 2026-08-24, 34 otwarte issue przy 13.9k gwiazdek; dziś to po prostu
  katalog `lsp/*.lua` konsumowany przez `vim.lsp.config`. **KEEP.**

### 1.3 lazydev.nvim (Lua)

Ostatni commit 2026-03-14, 7 otwartych issue. Zakres skończony, nie porzucony. Jedyne, co robi
wyjątkowo dobrze, to ładowanie bibliotek **na żądanie z Twoich `require()`** - alternatywa
`emmylua_ls` (`EmmyLuaLs/emmylua-analyzer-rust`, push dziś, release co miesiąc, 0.25.1 z
2026-08-14) tego nie ma i wymaga statycznej listy `workspace.library` (dokumentacja lspconfig
sama ostrzega "May be slower!"). **KEEP.** Spróbuj emmylua_ls tylko, jeśli lua_ls zacznie
przeszkadzać.

---

## 2. Serwery LSP dla Twoich języków

### 2.1 TypeScript: vtsls (masz od dziś) vs `tsc` (TS 7) vs ts_ls vs typescript-tools

Największa zmiana w całym ekosystemie i zaszła w ostatnie 7 tygodni:

- **TypeScript 7.0** (port na Go) wyszedł **2026-07-08**. Zamiast własnego protokołu tsserver
  ma standardowe LSP: `tsc --lsp --stdio`, w zwykłym pakiecie `typescript`. Raportowane
  przyspieszenia rzędu 10x.
- **nvim-lspconfig ma `lsp/tsc.lua` od 2026-08-12** (zweryfikowane lokalnie: sprawdza
  `--version`, wymaga major >= 7, szuka `node_modules/.bin/tsc`, `tsc`, `tsgo`; monorepo-aware;
  omija projekty Deno; inlay hints i CodeLens domyślnie włączone). `lsp/tsgo.lua` jest już
  **shimem deprecacji** wskazującym na `tsc` - pakiet `@typescript/native-preview` był kanałem
  beta i ten etap się skończył. **Nigdy nie wchodź w `tsgo`.**
- **vtsls** - `pushed_at` dziś, ale to wyłącznie dependabot/renovate; ostatni realny release
  `server-v0.3.0` 2025-12-24; otwarte #330 (2,8 GB RAM), #310 (nieświeże diagnostyki po edycji
  JSX). vtsls opakowuje rozszerzenie VS Code zbudowane na starym protokole tsserver, czyli
  strukturalnie warstwę, którą TS 7 zastępuje.
- **typescript-tools.nvim** - 2025-11-18, 84 issue; słusznie usunięty dziś.
- **ts_ls** - lspconfig w docblocku pisze, że "will likely eventually be replaced by tsc",
  zostaje głównie dla ES5.

**Ale:** `fable-app` ma TypeScript 5.9.2, `app.littleengine` 5.9.3. `tsc --lsp` wymaga TS 7 w
projekcie (albo globalnie). **Dziś vtsls jest właściwy.** Plan: gdy projekty wejdą na TS 7
(albo wrzucisz `typescript@7` globalnie), zamiana to jedna linia w liście `servers`
(`"vtsls"` -> `"tsc"`). Dwie rzeczy do sprawdzenia przed przełączeniem: `tsc.lua` nie ma
`vue` w filetypes (Vue nadal przez `vue_ls` + plugin, ścieżka niezweryfikowana), oraz to,
czy `lua/util/typescript.lua` (code actions `source.organizeImports` itd.) działa 1:1 na `tsc`
(powinno - to standardowe code actions, ale `typescript.findAllFileReferences` to komenda
vtsls/tsserver, może nie istnieć).

### 2.2 Python: pyright (masz) vs basedpyright vs pyrefly vs ty

| | Status |
|---|---|
| pyright | aktywny, domyślny; **KEEP** |
| basedpyright | fork pyright + funkcje Pylance (inlay hints, semantic tokens); Twoje settings działają bez zmian pod kluczem `basedpyright.analysis`; **darmowy upgrade do spróbowania** |
| pyrefly (Meta) | **stabilny od 1.0.0 (2026-05-12)**, 1.2.0 z 2026-08-01, konformancja ~92%; realna alternatywa, jeśli pyright będzie wolny |
| ty (astral) | **nadal beta, 0.0.74** (2026-08-22); najszybszy, najlepsza historia "gradual typing", ale nie do configu, na którym polegasz |

Wszystkie cztery mają `lsp/*.lua` w lspconfig.

### 2.3 C#

Poza zakresem researchu (agenci nie dostali .NET). Fakt lokalny: `csharp-ls` działa tylko w
0.16.0 na SDK .NET 8. Alternatywa do sprawdzenia osobno: `roslyn.nvim` (seblyng) z serwerem
Roslyn z Masona - standard w 2026 dla C#, ale nie zweryfikowany w tej analizie.

---

## 3. Formatowanie i lint: efm vs conform + nvim-lint vs none-ls

**Stan obecny nie gnije.** `efm-langserver` 0.0.57 (2026-07-08) z realnymi fixami (CRLF,
diagnostyki pod URI klienta); `efmls-configs-nvim` push 2026-08-11, 1 otwarte issue, w 2026
dodał oxlint/oxfmt, htmlhint, typos. Argument za zmianą jest o możliwościach, nie o porzuceniu.

**conform.nvim** (stevearc; push 2026-08-11, w jednym dniu 8 nowych formatterów) +
**nvim-lint** (mfussenegger; push 2026-08-25; kanoniczne repo jest na Codeberg, GitHub to
mirror). Pokrycie Twoich 12 narzędzi sprawdzone plik po pliku: biome, prettierd, stylua, black,
shfmt, fixjson, clang_format w conform; luacheck, flake8, shellcheck, hadolint, cpplint (i
biomejs) w nvim-lint. **Nic nie ginie.**

Lepsze niż efm:
- brak dodatkowego procesu LSP (efm to binarka Go widoczna w `:LspInfo`, konfigurowana w dwóch
  miejscach),
- **minimalne diffy**: conform aplikuje zmiany przez LSP text edits, więc foldy, extmarki i
  pozycja viewportu przeżywają format; efm podmienia bufor w całości,
- range formatting dla każdego formattera (nawet bez natywnego wsparcia),
- łańcuchy i fallbacki per filetype (`{ "prettierd", "prettier", stop_after_first = true }`,
  `lsp_format = "fallback"`) - efm nie umie "prettierd, a jak nie ma, to prettier",
- formatowanie bloków kodu w markdownie, `:ConformInfo` mówiący, który formatter zadziałał,
- nvim-lint: trigger per event (`BufWritePost`, `InsertLeave`, `TextChanged`).

Gorsze:
- dwa pluginy zamiast jednego serwera; formatowanie przestaje być capability LSP
  (`vim.lsp.buf.format()` nie obejmie CLI - `<leader>lf` kierujesz na `require("conform").format()`),
- konfig per projekt tylko przez pliki narzędzi (`biome.json`, `.prettierrc`, `.stylua.toml`) -
  dla Twojego zestawu to raczej plus,
- `mason-conform.nvim` jest zarchiwizowany; narzędzia dodajesz do `ensure_installed` Masona po
  nazwach Masona,
- migracja to realne popołudnie (12 narzędzi, 16 filetypes, format-on-save).

**none-ls.nvim** (dawny null-ls, "community caretaker fork"): ~6 sensownych commitów w 8
miesięcy, zero releasów, API celowo zamrożone, pełny in-process LSP. Nie rozwiązuje problemu
podmiany bufora. **Skip.**

Nowość warta wiedzy: narzędzia oxc mają własne serwery (`lsp/oxlint.lua`, `lsp/oxfmt.lua`),
biome też (`lsp/biome.lua`) - dla części narzędzi można pominąć wrapper i odpalić ich LSP.
Mieszanie biome-jako-LSP z eslint-jako-LSP na tych samych buforach wymaga uwagi.

**Werdykt: CONSIDER.** Jeśli przechodzić, to etapami: najpierw conform (tam jest zysk), efm
zostaje na lint przez tydzień, potem pięć linterów do nvim-lint i wywalenie efm + efmls-configs.

---

## 4. Completion, snippety, autopairs

### 4.1 blink.cmp (masz, `version = "1.*"`)

Dwa fakty, których README nie mówi wprost:
- **v1 jest zamrożone.** Branch `v1` = tag v1.10.2 (2026-04-04), zero commitów od ~5 miesięcy;
  cała praca idzie w v2 na `main` (wymaga 0.12, nowa zależność `saghen/blink.lib`, inny build,
  keymapy buffer-local, `prebuilt_binaries` zastąpione `download()`). Tracking issue v2 (#1059)
  otwarte od 2025-01 z większością punktów niezrobionych - **nie planuj pod v2**.
- **Twój `<C-s>` w blink zasłania globalne mapowanie 0.12**: `i_CTRL-S` ->
  `vim.lsp.buf.signature_help()` (zweryfikowane w `lsp.txt` lokalnie). Decyzja: przenieść
  trigger snippetów gdzie indziej i odzyskać signature help za darmo, albo włączyć
  `signature.enabled` w blink (eksperymentalne) i zostawić `<C-s>`.

Kompatybilność v1.10.2 z 0.12: OK (fix artefaktów redraw wszedł w v1.10.0; późniejszy problem
z `vim.Pos` dotyczył tylko v2). **Werdykt: KEEP na `1.*`.** Ekosystem: `blink.lib` (dawny
`blink.download`) żywy, `frizbee` żywy, **`blink.compat` 15 miesięcy nieruszany** - nie buduj na nim.

### 4.2 Alternatywy dla blink

**Wbudowane completion 0.12** - jedyna naprawdę ciekawa alternatywa. Ma: opcję
`'autocomplete'` (popup w trakcie pisania, z `autocompletedelay`/`timeout`), `'complete'` z
funkcjami i limitami per źródło (`.^5,w^5,b^5,u^5`), `'completeopt'` z `fuzzy`, `nearest`,
`preinsert`, `popup` (dokumentacja przez `completionItem/resolve`), `'pumborder'`,
`'pummaxwidth'`, `vim.lsp.completion.enable()`, `vim.lsp.inline_completion` (ghost text dla
providerów AI, `:h lsp-copilot`), autocompletion w cmdline.
Czego nie ma vs blink (każdy punkt sprawdzony z docs 0.12): fuzzy odporne na literówki
(Smith-Waterman), frecency + proximity dla wszystkich źródeł (`nearest` działa tylko dla
bieżącego bufora i wyłącza się przy `fuzzy`), jednej listy rankowanej globalnie (wbudowane
sortuje wg kolejności `'complete'`), prefetchu LSP, ghost text dla zwykłego completion,
automatycznego signature help, auto-nawiasów z semantic tokens, **loadera snippetów**
(`vim.snippet` to tylko expander). **Werdykt: CONSIDER później** - sensowny cel, gdyby
zamrożone v1 / łamiące v2 zaczęło boleć; dziś nie boli.

**nvim-cmp** - push 2026-07-09, ale 303 otwarte issue, README: "hobby project, don't expect a
fix"; 60 ms debounce vs 0,5-4 ms blink; potrzeba 5+ pluginów źródeł. **Nie.**
**mini.completion** - dwustopniowe (LSP, potem fallback), bez fuzzy, ghost text, path/buffer;
tylko przy przejściu całości na mini. **care.nvim** - 12 miesięcy martwe, "WIP". **Nie.**

### 4.3 Snippety

Twój układ (blink preset default + `vim.snippet` + friendly-snippets + `snippets/package.json`)
to kanoniczny setup blink w 2026, najmniej ruchomych części. `vim.snippet` w 0.12 = `expand`,
`jump`, `active`, `stop` + `hl-SnippetTabstopActive`; loader jest w blink. friendly-snippets:
ostatnia realna treść 2025-04, 74 issue - to statyczne dane, stagnacja kosztuje tylko brak
snippetów do nowych frameworków. LuaSnip (v2.5.0 04.2026) tylko, jeśli potrzebujesz snippetów
w Lua z warunkami; mini.snippets (może serwować snippety jako in-process LSP) - ciekawostka.
**KEEP.**

### 4.4 Autopairs i autotag

| Plugin | Push | Issues | TS-aware | Werdykt |
|---|---|---|---|---|
| nvim-autopairs (masz) | 2026-08-23 | 15 | tak (`check_ts`) | **KEEP** - najaktywniejszy, najczystszy tracker |
| blink.pairs | 2026-07-12 | 20 | własny parser Rust | 0.x, otwarte bugi psujące parowanie (C++ raw strings, nix, `Invalid 'col'`); **CONSIDER przy v1.0** - zastąpiłby też rainbow-delimiters (-1 plugin) |
| mini.pairs | 2026-07 | - | nie (wzorce sąsiadów) | downgrade |
| ultimate-autopair | 2026-03 (feat) | 22 | tak | README: "maintenance mode" |
| autoclose.nvim | 2026-03 (feat) | 13 | nie | downgrade |

Integracja z blink: nie ma czego integrować - nawiasy po accept robi blink
(`completion.accept.auto_brackets`), zwykłe pisanie robi autopairs; ścieżki się nie nakładają.

**nvim-ts-autotag** - push 2026-04-15 z commitem "handle nil parser for Neovim 0.12+", 6
issue (wszystkie z 2022-2024). Nie używa API nvim-treesitter (tylko `vim.treesitter`), więc
branch `main` mu obojętny. Uzupełnienie z 0.12: `vim.lsp.linked_editing_range.enable()` -
synchroniczne przemianowanie tagów przez LSP (tylko rename, nie close; zależy od serwera).
**KEEP.**

### 4.5 Signature help, inlay hints, ghost text

Wbudowane: signature help ręcznie pod `<C-s>` (patrz kolizja wyżej), inlay hints w pełni
(`vim.lsp.inlay_hint.enable()`, masz toggle `<leader>uh`), ghost text tylko dla
`inline_completion` (AI). `lsp_signature.nvim` - 88 issue, zbędny po 0.11. **Nic nie dodawać.**

---

## 5. AI

### 5.1 avante.nvim (masz)

- 18,1k gwiazdek, push dziś, 100+ commitów w 90 dni. **Ale autorstwo się zmieniło**: yetone
  ostatni commit 2026-03-06, `teto` zrobił 90 ze 100 ostatnich. Żywe, bus factor = 1 i to nie
  osoba z nazwy repo.
- Wymóg 0.12 twardy (`plugin/avante.lua:1`), README wciąż w jednym miejscu twierdzi "0.11+" -
  stąd wrażenie niespójnej dokumentacji. Tagi pluginu: v0.1.2 (2026-06-03); "latest release"
  na GitHubie to binarki `avante-libs`. Twoje `version = false` jest poprawne.
- **ACP jest wbudowane** (`lua/avante/config.lua`, `acp_providers`): `gemini-cli`,
  **`claude-code`**, `goose`, `codex`, `opencode`, `kimi-cli`. Provider `claude-code` odpala
  `claude-agent-acp` z `ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = exepath("claude")`, czyli jedzie
  na Twojej subskrypcji, nie na `ANTHROPIC_API_KEY`. Domyślnie
  **`ACP_PERMISSION_MODE = "bypassPermissions"`**. Pakiet: `@agentclientprotocol/claude-agent-acp`
  v0.70.0 (2026-08-18) - stary `@zed-industries/claude-code-acp` stoi od 03.2026.
- "Avante Zen Mode": shim `./contrib/avante` na PATH, CLI w stylu Claude Code z Neovimem pod spodem.
- Otwarte bolączki: #3202 build `make` przekracza timeout lazy (masz `build = "make"`;
  `build.sh` pobiera prebuilty), **#3076 dostęp do plików poza cwd** (od 2026-05-17),
  #3185 `avante.md`/symlinki czytają poza workspace i wysyłają do providera, #3038 breaking
  changes na main, #3207 zużycie tokenów, #3155/#3156 auth i rate limity Claude.
  Przy pracy w repo klientów te dwa "filesystem" issue ważą więcej niż zwykle.

**Werdykt: KEEP** + trzy tanie zmiany: (1) włączyć provider ACP `claude-code`, (2) świadomie
ustawić `ACP_PERMISSION_MODE`, (3) przejść na `build.sh`, jeśli #3202 ugryzie.

### 5.2 Alternatywy

| Plugin | Push | Gwiazdki | Werdykt | Lepsze / gorsze vs avante |
|---|---|---|---|---|
| **codecompanion.nvim** (olimorris) | 2026-08-26, v19.23.0 z 2026-08-24, 11 issue | 6,8k | **ADD (hedge)** | + release co tydzień, czysty tracker, bez builda Rust, 16 adapterów ACP (w tym `claude_code` przez `CLAUDE_CODE_OAUTH_TOKEN`, permissions opt-in przez wariant `yolo`), **czyta `CLAUDE.md` i `.cursor/rules` natywnie**, MCP, integracja z herdr; - brak apply-diff w sidebarze w stylu Cursora, mniejsza społeczność, brak Zen Mode i RAG |
| sidekick.nvim (folke) | 2026-04-22, **0 commitów w 90 dni**, 49 otwartych PR (najstarszy 2025-11) | 2,7k | **NIE** | zamarł; NES z Copilota działa, ale integracja agentów bez opieki |
| claudecode.nvim (coder) | 2026-08-11, 0 commitów w 30 dni, 91 issue, release v0.3.0 09.2025 | 3,0k | **NIE** | najwierniejszy protokołowo (reverse-engineering rozszerzenia VS Code po WebSocket/MCP: `ClaudeCodeSend`, `ClaudeCodeAdd`, diff accept/deny), ale to protokół niepublikowany, a ACP go wyprzedził |
| claude-code.nvim (greggh) | 2026-02-04, 0 w 90 dni, 74 issue | 2,1k | **NIE** | wrapper terminala, uśpiony |
| opencode.nvim (NickvanDyke) | 2026-08-21, **v1.0.0 z 2026-08-20**, 6 issue | 3,8k | tylko przy zmianie agenta | świetnie prowadzony, ale integruje opencode; avante/CodeCompanion i tak umieją opencode po ACP |
| copilot.lua | 2026-08-25 | 4,1k | zdrowy | referencyjny klient Copilota |
| CopilotChat.nvim | 2026-08-03 | 3,7k | zbędny obok CodeCompanion | |
| copilot-lsp (NES) | 2026-03-15 | 454 | zimny | silnik NES sidekicka, oba końce stoją |
| minuet-ai.nvim | 2026-08-14, 13 issue | 1,4k | **CONSIDER** | completion LLM przez blink na Twoim kluczu OpenAI |
| neocodeium | 2026-06-22 | 506 | żywy, wolny | darmowe Codeium |
| parrot.nvim | 2026-08-24, 7 issue | 791 | żywy | lekki czat bez agenta i builda |
| llm.nvim (Kurama622) | 2026-06-20, 0 issue | 479 | żywy, niszowy | |
| gp.nvim, gen.nvim | 2025-08 / 2025-05 | | **martwe** | |
| mcphub.nvim | 2026-01-18, 0 w 90 dni | 1,8k | **NIE** | 7 miesięcy ciszy; CodeCompanion ma własne MCP |

Nowi gracze "ACP-native" (emeth, ghost, acpear) to zabawki po 0-2 gwiazdki - duże pluginy
wchłonęły ACP zanim dedykowany zdążył się przyjąć.

### 5.3 Dwa modele integracji (i trzeci, który wygrał)

(a) czat w edytorze na kluczach API (natywne providery avante, nie-ACP adaptery CodeCompanion):
sidebar, `@file`, selekcja, inline edits, apply-diff, obrazki; płacisz tokenami; pętla agenta
tylko tak dobra jak implementacja pluginu.
(b) sterowanie CLI Claude Code: (b1) reverse-engineered WebSocket/MCP (claudecode.nvim) -
prawdziwy agent, subskrypcja, CLAUDE.md, skille, MCP, ale rozmowa w terminalu i protokół
niepublikowany; (b2) **ACP** (avante, CodeCompanion) - to samo, standard z SDK, rozmowa w
buforze Neovima, własny diff review pluginu. (b2) jest ściśle lepszą wersją (b1).

Co realnie zyskujesz jako ktoś, kto już żyje w Claude Code CLI: mniej, niż sugeruje
marketing - diff review motions Vima zamiast scrollowania pane'a, wysyłanie selekcji/`@file`
bez wpisywania ścieżek, rozmowa w prawdziwym buforze (search/yank/fold), diagnostyki LSP jako
kontekst. Nie zyskujesz lepszego modelu ani narzędzi.

Poza pluginami: **herdr** (`herdrdev/herdr`, 32,5k gwiazdek od marca 2026, Rust, v0.8.2, 235
issue) - trwały runtime terminali dla agentów (przeżywa zamknięcie klapy, sieć, reboot; pane
oznaczony working/blocked/idle; API po sockecie). Zastępuje tmux, nie avante; CodeCompanion
ma integrację (PR #3321, 2026-08-23). Przy Twoich odpalanych w tle batchach executora warte
osobnego spojrzenia. Nie odpalane w tej analizie.

### 5.4 img-clip i render-markdown

- **img-clip.nvim** - push 2025-12-19, 0 commitów w 90 dni, v0.6.0 z 2025-02; #129 (ścieżki ze
  spacjami przy drag&drop) otwarte od 06.2025. Zależność avante jest miękka
  (`Utils.has("img-clip.nvim")`), avante ma własny moduł schowka. Brak lepiej utrzymywanego
  odpowiednika. **KEEP** (kosztuje nic).
- **render-markdown.nvim** (push 2026-08-11, v8.13.0, 12 issue) vs **markview.nvim** (push
  2026-08-14, v28.3.0, 4 issue, 3x więcej commitów, renderuje też Typst/LaTeX/HTML/AsciiDoc).
  **KEEP render-markdown**: avante jest pod niego dokumentowany i strojony (był konkretny
  crash-fix w claudecode.nvim #224 właśnie na styku z render-markdown), a zysk w buforze
  czatu niewidoczny. markview tylko, jeśli zaczniesz pisać Typst/LaTeX.

---

## 6. UI

### 6.1 noice.nvim (masz) vs `ui2` (0.12) vs fidget vs mini.notify

**noice**: ostatni commit 2025-11-03, ostatni release v4.10.0 **2025-02-06**, 27 otwartych PR,
w 2026 folke skomentował 1 issue, resztę zamyka bot "not planned". Otwarte: **#1201** (nie
chowa cmdline przy `cmdheight=0` z ui2; po stronie core **neovim#38916** - włączenie ui2 przy
podpiętym zewnętrznym `ext_cmdline` daje dwa cmdline naraz, reprodukowane na `--clean`),
**#1225** (router wiadomości polluje co 33 ms nawet na idle), #1226 (`confirm()` w złym popupie).
Na 0.12.5 noice działa, dopóki nie włączysz ui2 (ui2 jest opt-in).

**`ui2`**: moduł to `vim._core.ui2` (zweryfikowane lokalnie; w źródle "WARNING: This is an
experimental feature"). Włączenie:

```lua
require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = "cmd", -- albo "msg", albo mapa kind -> target
    cmd = { height = 0.5 },
    dialog = { height = 0.5 },
    msg = { height = 0.5, timeout = 4000 },
    pager = { height = 1 },
  },
})
```

Cztery okna (`cmd`, `msg`, `pager`, `dialog`) z `filetype` = id, więc stylujesz przez
`FileType`. Daje: kolorowany cmdline w trakcie pisania (treesitter vim), **brak hit-enter**
(nadmiar zwijany do `[+x]`, rozwijasz `g<`/Enter), pager jako prawdziwy bufor. Zastąpiło ~3000
linii C. Obok: `vim.o.winborder = "rounded"` (ramki floatów, które dawał noice),
`vim.ui.progress_status()` (postęp LSP do statusline), `completeopt+=popup`.
Czego nie reprodukuje: **wyśrodkowanej palety komend** - ui2 z założenia trzyma cmdline na dole.

**fidget.nvim** - v2.0.0 z 2026-06-21 (reflow, health checks), zakres: postęp LSP +
notyfikacje, nie tyka cmdline. **mini.notify** - `vim.notify` + postęp LSP, zero issue.

**Werdykt: CONSIDER, etapami.** (1) darmowe rzeczy już teraz (`winborder`, `completeopt`),
(2) tydzień na `ui2` z wyłączonym noice, (3) notyfikacje zostają na snacks.notifier (ui2 nie
zastępuje `vim.notify`), (4) **nigdy noice + ui2 razem**. Jeśli wyśrodkowana paleta jest
nienegocjowalna - zostanie na noice jest do obrony, ze świadomością pollingu 33 ms i braku
opieki.

### 6.2 snacks.nvim (masz, 8 modułów w jednym)

Całość: 8,0k gwiazdek, ostatni commit 2026-05-25, ostatni release v2.31.0 2026-03-20, **111
otwartych PR**, 136 issue, tylko 5 commitów od 2026-05-01. Kadencja padła (v2.26-v2.30 w dwa
tygodnie 10-11.2025, potem jeden release w marcu, potem cisza). Issue wciąż wpadają codziennie.
**KEEP, WATCH** - najlepszy stosunek wartości do liczby pluginów w configu.

| Moduł | Werdykt | Alternatywa i dlaczego |
|---|---|---|
| picker | KEEP | **fzf-lua** (push 2026-08-13, **10 issue przy 4,4k gwiazdek**, fixy tego samego dnia z testem regresji, najszybszy na dużych repo) - ewakuacja, jeśli snacks pomilczy kolejne pół roku albo grep zacznie mulić (#950). telescope: commituje, ale 462 issue / 84 PR - nie kierunek. mini.pick: najbezpieczniejszy, celowo minimalny. |
| explorer | KEEP | to "picker przebrany za drzewo"; **neo-tree** (push dziś, 3.41.0) jest silniejszy w rzeczach drzewiastych (git na głębokość, watchery, dnd); **oil.nvim** to inny model (system plików jako bufor); **mini.files** - kolumnowy środek. Zmieniać tylko przy konkretnym limicie. |
| dashboard | KEEP | alpha-nvim i dashboard-nvim żywe, ale gorzej zaprojektowane |
| notifier | KEEP | mini.notify / fidget lepiej utrzymywane, równie dobre; nvim-notify rok ciszy, 80 issue - nie |
| terminal | KEEP | toggleterm 17 miesięcy ciszy, 92 issue - gorzej niż snacks |
| image | KEEP | tylko protokół kitty (ghostty OK); `3rd/image.nvim` (push 2026-08-19) ma też ueberzugpp i sixel |
| bigfile, quickfile, scope, statuscolumn, toggle, bufdelete, rename, input, lazygit | KEEP | małe, stabilne, bez konkurencji |

### 6.3 lualine (masz) vs heirline vs mini.statusline vs domyślna statusline 0.12

- lualine: push 2026-05-31, **271 issue**, bez tagów; community-fixy, "utrzymywany, nie
  rozwijany". **KEEP.**
- heirline: 2025-05-23, 15 miesięcy; biblioteka, gnije wolno, ale nie cel migracji.
- mini.statusline: zero issue, minimalny; następca lualine, gdyby ten umarł - nie heirline.
- Domyślna statusline 0.12 to teraz wyrażenie (nie C): nazwa pliku + flagi, exit code
  terminala, **postęp LSP** (`vim.ui.progress_status()`), showcmd, `busy` (`◐`),
  **diagnostyki** `E:2 W:3` (`vim.diagnostic.status()`), ruler; grupy highlight się
  "stackują". Brak: branch/diff git, kolorów per tryb, ikon, Twojego przezroczystego motywu.
  Tanie: zamień ewentualne komponenty progress/diagnostics na te wbudowane funkcje.

### 6.4 bufferline (masz)

**Najwyraźniej porzucony plugin w configu**: ostatni commit **2025-01-14** (zweryfikowane
lokalnie), 25 wiszących PR, 103 issue, bez forka. Działa (tabline to stabilne API), nic nie
będzie naprawione.

| Alternatywa | Push | Uwagi |
|---|---|---|
| **nic** (picker `<leader>,` + `Snacks.bufdelete`) | - | mocny argument: bufferline pokazuje 8-10 buforów zanim utnie, kosztuje linię na stałe; fuzzy picker jest O(1) |
| mini.tabline | 2026-07 | minimalny, bez przycisków zamykania i diagnostyk; najbliższy Twojemu "pokaż bufory, przezroczyście" |
| barbar.nvim | 2026-06-10, 35 issue | najbliższa parytetu funkcji (reorder, pin, diagnostyki) |
| nvim-cokeline | 2026-06-19 | w pełni programowalny, mała społeczność |
| tabby.nvim | 2026-01 | tab-oriented, skip |

**Werdykt: tydzień bez bufferline, potem mini.tabline (minimalizm) albo barbar (parytet).
Nie zostawać długo na bufferline.** Uwaga na keymapy: `<S-h>/<S-l>`, `<A-h>/<A-l>`, `≤/≥`,
`<leader>bh/bl`, `<leader>q` w `keymaps.lua`/`which-key.lua` i `offsets` w specu.

### 6.5 which-key, ikony, zależności

- **which-key** v3: ostatni commit 2025-10-28, release v3.17.0 2025-02; ale feature-complete,
  preset `modern` stabilny, bez poważnych bugów. **KEEP**; następca na czarną godzinę:
  **mini.clue** (v0.18.0 wyrównał `modes`), inna filozofia (deklarujesz prefiksy jawnie).
- **nvim-web-devicons** push 2026-07-23, 18 issue - nie jest porzucony. **mini.icons** zero
  issue, szybszy, więcej kategorii (LSP kinds, katalogi), ma shim `mock_nvim_web_devicons()`;
  which-key i snacks wspierają oba (snacks README wskazuje już `nvim-mini/mini.icons`). **KEEP
  devicons**, zmieniać tylko przy szerszym wejściu w mini.
- **nui.nvim** (push 2026-08-21) - wymagany przez avante (twardo) i noice. **plenary** (push
  2026-04-10, 158 issue) - wymagany przez avante; biblioteka bez churnu API. **Oba zostają.**

### 6.6 Colorscheme: tokyodark (masz)

Ostatni commit 2025-11-13 = "feat: add license"; ostatnia praca nad highlightami 2024-06.
Zliczenie grup w źródle (zweryfikowane lokalnie `rg`): **Snacks 0, Blink 0, Noice 0,
Bufferline 0, Lualine 0**, `@lsp` 14, WhichKey 4, GitSigns 9. Czyli każdy picker, explorer,
dashboard i menu completion rysuje się na generycznych fallbackach - prawdopodobnie widzisz
częściowo nieotematowane UI, nie przypisując tego colorscheme.

| Scheme | Push | Snacks | Blink | `@lsp` | Noice | WhichKey | Transparentność |
|---|---|---|---|---|---|---|---|
| **tokyonight** | 2026-03-24 | 35 | 272 | 249 | 30 | 34 | `transparent`, `styles.sidebars/floats = "transparent"` |
| catppuccin | 2026-08-09 | 11 | 44 | 5 | 5 | 6 | `transparent_background` + mapa integracji |
| cyberdream | 2026-08-19 | 14 | 38 | 0 | 0 | 18 | `transparent` |
| rose-pine | 2026-05-15 | 1 | 37 | 18 | 0 | 21 | `styles.transparency` |
| kanagawa | 2026-05-10 | 0 | 43 | 40 | 0 | 0 | `transparent` |
| nightfox | 2026-07-04 | 0 | 28 | 30 | 0 | 8 | `options.transparent` |
| oxocarbon | 2026-08-09 | 0 | 0 | 104 | 0 | 0 | - |

**Werdykt: SWITCH -> tokyonight** (`night`/`storm` najbliżej nastroju tokyodark, `moon`
ciemniejszy); ten sam autor co snacks/noice/which-key, więc integracje idą razem. Zastrzeżenie:
tokyonight też ma 5 miesięcy ciszy, ale colorscheme z generatorem i dojrzałym zestawem
integracji starzeje się tanio. Bez folke: **catppuccin** (bardzo aktywny, 11 issue) albo
**cyberdream** (wysoki kontrast, bez semantic tokens).

---

## 7. Edycja, treesitter, git, sesje

### 7.1 nvim-surround (masz) vs mini.surround

Oba równie utrzymywane (nvim-surround v4.0.5 2026-05-02, mini.surround w monorepo codziennie).
Obalony mit z blogów: nvim-surround **ma** dot-repeat. Różnice: nvim-surround = klawisze
vim-surround (`ys`/`cs`/`ds`), opcjonalna integracja z textobjects TS; mini.surround =
`gsa`/`gsd`/`gsr` + `gsf`/`gsF` find, `gsh` highlight, `[count]`, warianty `next`/`last`
(`gsan`, `gsal`), spec z par capture TS. **KEEP** - przesiadka tylko przy wejściu w mini.

### 7.2 rainbow-delimiters (masz)

Push 2026-07-29, v0.12.0 (2026-04-06) z jawnymi fixami pod Neovim 0.12; nie używa systemu
modułów nvim-treesitter (własne queries, `vim.treesitter` bezpośrednio), więc branch `main` mu
obojętny. Otwarte: wolne otwieranie dużych plików C++, highlight pojawia się dopiero po innym
parsie. Alternatyw utrzymywanych brak (monopol). **KEEP** (chyba że kiedyś blink.pairs v1.0).

### 7.3 Ekosystem nvim-treesitter `main`

- `main` jest już domyślnym branchem (push 2026-08-23); `master` docs-only od 2026-03.
- **nvim-treesitter-textobjects** - `master` zamrożony (commit "docs: master is frozen"),
  `main` żywy (2026-07-19). To inny plugin: bez bloku `configs`, każdy keymap ręcznie
  (`select.select_textobject("@function.outer", "textobjects")`, `move.goto_next_start`,
  `swap.swap_next("@parameter.inner")`, `repeatable_move` dla `;`/`,`). Koszt ~30-50 linii.
- **nvim-treesitter-context** (push 2026-08-02, 31 issue) - najlepiej prowadzony z trójki;
  ostatni commit używa nowej opcji 0.12 `winpinned`. `vim.treesitter` bezpośrednio, bez tarć z main.
- **mini.ai** - `gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" })` daje
  `af`/`if`/`ac`/`ic` bez boilerplate'u, plus `a`/`i` dla nawiasów/cudzysłowów/argumentów,
  `[count]`, `n`/`l` (next/last).
- Wbudowane 0.12 (`news.txt`): `an`/`in`/`]n`/`[n`/`]N`/`[N`, `vim.treesitter.select()`,
  LSP `selectionRange` jako drugie źródło - **incremental selection masz rozwiązane**
  (`<C-s>`/`<BS>`). Nie zastępuje: nazwanych textobjectów, ruchów `]m`/`[m`, swapów, sticky context.

### 7.4 gitsigns (masz) vs mini.diff

gitsigns v2.1.0 (2026-03-26), push 2026-08-11, nudne fixy jakich chcesz. mini.diff: źródło
referencji konfigurowalne (nie tylko git), overlay z pełnym diffem inline (lepszy review niż
`preview_hunk`), ale **brak blame** (osobny `mini.git`) i brak rozróżnienia staged/unstaged -
dwa moduły, żeby dostać mniej. **KEEP.** (vim-fugitive żywy, ale vimscript - poza kryteriami.)

### 7.5 diffview (masz) -> diffview-plus

```
sindrets/diffview.nvim      ostatni commit 2024-06-13, 131 issue, nie zarchiwizowany
dlyongemallo/diffview-plus  fork od 2024-12-28, push 2026-08-26 (dziś), 305 gwiazdek, 7 issue
```

Fork: nightly CI na Neovimie, w sierpniu 2026: tryb ukrywania przejrzanych plików, multi-file
merge, konflikty w stylu jj, `--rename-threshold`, fix foldów; plus wybór wielu plików w
panelu do batch stage/unstage, unified inline diff z highlightem treesitter po obu stronach,
wsparcie jujutsu. **Te same komendy** (`:DiffviewOpen`, `:DiffviewFileHistory`), ten sam kształt
configu - zmiana jednej linii w specu i w `util/compare_with_branch.lua` nic nie trzeba ruszać.

Dlaczego nie inne: `git-conflict.nvim` martwy (2024-12); `mini.git` to wrapper `:Git` bez UI
konfliktów; **neogit** żywy (push 2026-08-22), ale sam listuje diffview jako zależność do
diffów (kółko); `unified.nvim` mały, bez historii plików; `gitgraph.nvim` 14 miesięcy ciszy;
lazygit w floacie nie da Ci motions/LSP/treesittera w diffie ani 3-way bufora. **SWITCH** -
najcenniejsza pojedyncza zmiana w tym dokumencie.

### 7.6 Sesje: własny `sessions.lua` (masz) vs pluginy

| Plugin | Push | Issue | Uwagi |
|---|---|---|---|
| persisted.nvim (olimorris) | 2026-08-25, **v3.1.0 wczoraj** | 0 | `use_git_branch`, nazwane sesje, czyszczenie sierot, `before_save`; **picker tylko Telescope** (u Ciebie `vim.ui.select`) |
| auto-session | 2026-08-15 | 16 | **natywny picker Snacks**, `git_use_branch_name`, **`git_auto_restore_on_branch_change`** (nikt inny tego nie ma), `bypass_save_filetypes` pod dashboard |
| persistence.nvim (folke) | 2025-10-28 | 9 | ~150 linii per cwd, skończony nie porzucony, bez git-branch |
| resession, mini.sessions, neovim-session-manager, possession | 2025-11..2026-08 | | wolniejsze / minimalne |

0.12: `:restart` / `ZR` odtwarza sesję w miejscu (nie cold-start per cwd), nowy autocmd
**`SessionLoadPre`** - użyteczny w Twoim managerze. **KEEP własny** (100 linii pod kontrolą,
dziś naprawiony), z `SessionLoadPre`; jeśli chcesz to wyrzucić - **auto-session** pasuje do
Twojego stosu najlepiej.

---

## 8. Czego brakuje (żywe, standardowe w 2026)

1. **mini.ai** - textobjecty; największa luka, najlepszy stosunek wartości do linii.
2. **nvim-treesitter-context** - sticky nagłówek; prawie zero configu.
3. **flash.nvim** (push 2026-08-22; folke tu wciąż aktywny) - skoki po labelach zamiast
   `f`/`t`/`/`, tryb selekcji TS. Alternatywnie **leap.nvim** (2026-08-16).
4. **grug-far.nvim** (push 2026-08-13, **0 issue przy 2k gwiazdek**) - search & replace po
   projekcie w buforze, ripgrep/ast-grep; nic w configu tego nie robi.
5. **nvim-treesitter-textobjects** `main` - zamiast mini.ai, jeśli chcesz ruchy `]m`/`[m`,
   swap parametrów i powtarzalne `;`/`,`.

Rezerwa: quicker.nvim (edytowalny quickfix), nvim-various-textobjs, mini.move,
todo-comments (cichy od 2025-11, kompletny), trouble v3 (cichy ~10 miesięcy; dużo z tego
dają pickery snacks).

---

## 9. Tabela zbiorcza (data ostatniego commita = lokalne `git log` w `~/.local/share/nvim/lazy`)

| Plugin | Ostatni commit | Werdykt |
|---|---|---|
| lazy.nvim | 2025-12-17 (funkcjonalny 2025-11-06) | KEEP, WATCH |
| mason.nvim | 2026-06-11 | KEEP |
| mason-lspconfig.nvim | 2026-08-26 (generated) | KEEP |
| nvim-lspconfig | 2026-08-24 | KEEP |
| lazydev.nvim | 2026-03-14 | KEEP |
| efmls-configs-nvim (+efm 0.0.57) | 2026-08-11 | KEEP / CONSIDER conform+nvim-lint |
| blink.cmp | 2026-04-04 (v1 zamrożone) | KEEP `1.*`, fix `<C-s>` |
| friendly-snippets | 2026-01-23 | KEEP |
| nvim-autopairs | 2026-08-23 | KEEP |
| nvim-ts-autotag | 2026-04-15 | KEEP |
| nvim-treesitter (main) | 2026-08-23 | KEEP |
| rainbow-delimiters.nvim | 2026-07-29 | KEEP |
| nvim-surround | 2026-05-02 | KEEP |
| gitsigns.nvim | 2026-08-11 | KEEP |
| **diffview.nvim** | **2024-06-13** | **SWITCH -> diffview-plus** |
| avante.nvim | 2026-08-26 | KEEP + ACP claude-code; ADD codecompanion (hedge) |
| img-clip.nvim | 2025-12-19 | KEEP |
| render-markdown.nvim | 2026-08-11 | KEEP |
| snacks.nvim | 2026-05-25 | KEEP, WATCH (fzf-lua w odwodzie) |
| noice.nvim | 2025-11-03 | CONSIDER ui2 / WATCH |
| lualine.nvim | 2026-05-31 | KEEP |
| **bufferline.nvim** | **2025-01-14** | **DROP / SWITCH** |
| which-key.nvim | 2025-10-28 | KEEP |
| nvim-web-devicons | 2026-07-23 | KEEP |
| **tokyodark.nvim** | **2025-11-13** (highlighty 2024-06) | **SWITCH -> tokyonight** |
| nui.nvim | 2026-08-21 | KEEP (dep) |
| plenary.nvim | 2026-04-10 | KEEP (dep) |

## 10. Zastrzeżenia

- Liczby (gwiazdki, issue, `pushed_at`) to zdjęcie z 2026-08-26.
- Niezweryfikowane: czy `lsp/tsc.lua` pokryje Vue tak jak vtsls + `@vue/typescript-plugin`;
  konformancja `ty` (źródła podają od 15% do 67%); czy avante w sesji ACP faktycznie wychodzi
  poza cwd (ocena z #3076/#3185 i domyślnego `bypassPermissions`, nie z testu); herdr nie był
  odpalany.
- C# (roslyn.nvim) nie był objęty researchem.
- Sekcja 0 to moja synteza pięciu raportów; tam, gdzie raporty się różniły w ocenie (np. snacks
  "coasting" vs "keep"), wybrałem ostrożniejszą wersję i dałem WATCH.
