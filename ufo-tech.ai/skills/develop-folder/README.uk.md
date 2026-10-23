# develop-folder — скіл для Claude Code і Codex

Створює та веде робочу папку `.develop/` у корені проєкту:

```
.develop/
├── README.md                     # коротка шпаргалка з правилами
├── glossary.md                   # терміни й абревіатури, згруповані за темами
├── investigations/<тема>.md      # дослідження, по файлу на тему чи контекст запиту
├── questions/
│   ├── open/<тема>.md            # ⚠️ нові, ⏸️ відкладені
│   ├── accepted/<тема>.md        # ✅ прийняті
│   └── rejected/<тема>.md        # 🛑 відхилені
├── issues/
│   ├── features/<іконка>-NNN-<назва>.md
│   └── bugfix/<іконка>-NNN-<назва>.md
└── docs/                         # як працює функціональність зараз
```

- **Статуси:** ⚠️ нове / чекає рішення · ⏸️ відкладено · ✅ прийнято · 🛑 відхилено · 🏁 реалізовано (тільки задачі). Статус питання змінює лише рішення людини.
- **Питання:** нумерація наскрізна для всієї папки `questions/`. Після рішення питання переїжджає з `open/<тема>.md` в `accepted/<тема>.md` чи `rejected/<тема>.md` разом із датою й формулюванням рішення.
- **Задачі** (`issues/`) з'являються, коли в обговоренні дійшли до запланованої роботи. Шаблони: `templates/feature.md` і `templates/bug.md`. Заголовок H1 — це Jira Summary, а все до розділу «Локальні посилання» — Description, яке можна вставити в Jira без правок.
- **docs/** описує поточний стан системи, не плани. Розділи оновлюються, коли задача стає 🏁.
- **Git:** папка не потрапляє в git, бо скрипт додає `/.develop/` у `.git/info/exclude`. Це локальний файл, тож спільний `../../../.gitignore` не змінюється. CLAUDE.md лишається окремо.

## Коли створюється

- Під час `/init`: агент підхоплює скіл і запускає `ensure-develop` одразу після `CLAUDE.md` (Claude Code) чи `AGENTS.md` (Codex).
- Якщо `/init` був раніше, ніж з'явився скіл:
  - **Claude Code** — SessionStart hook на старті сесії бачить CLAUDE.md, створює або доповнює `.develop/` і повідомляє про це Claude;
  - **Codex** — hook-а немає: агент сам запускає `ensure-develop`, коли бачить `AGENTS.md` без повної `.develop/`.

  Якщо знайдеться старий формат (`.develop/investigate.md`, `.develop/qa.md`, `.features/`), агент запропонує перенести.

## Платформи

Кожен скрипт має дві однакові за поведінкою версії:

| Система | Версія скриптів | Що потрібно |
|---|---|---|
| macOS, Linux, WSL | `.sh` | `bash` (підходить і 3.2, як на macOS), `git` |
| Windows з Git for Windows (Git Bash) | `.sh` | Git for Windows |
| Windows без Git Bash | `.ps1` | вбудований Windows PowerShell 5.1 або PowerShell 7; `git` — якщо проєкти в git |

Claude Code на Windows без Git for Windows запускає і команди, і hooks через PowerShell. Тому для такої машини потрібні `.ps1`-версії скриптів і окремий варіант hook.

## Встановлення

1. Встановити скіл **глобально** — шляхи в SKILL.md (і hook для Claude Code) розраховані саме на це місце: `~/.claude/skills/develop-folder/` для Claude Code, `~/.agents/skills/develop-folder/` для Codex. Найпростіше — попросити агента: «встанови скіл develop-folder з каталогу UFO Tech глобально»; команди для ручного встановлення є вище на цій сторінці.

   Файл `.gitattributes` у папці скіла тримає `.sh`-скрипти з LF-закінченнями рядків, якщо скіл зберігається в git. Інакше на Windows із `core.autocrlf=true` bash на них падає.
2. **Лише для Claude Code:** додати hook у `~/.claude/settings.json` (на Windows це `%USERPROFILE%\.claude\settings.json`). Якщо там уже є `hooks.SessionStart`, допишіть елемент у наявний масив, а не замінюйте його.

   macOS, Linux, WSL, Windows з Git Bash:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash \"$HOME/.claude/skills/develop-folder/scripts/session-check.sh\"",
               "timeout": 10
             }
           ]
         }
       ]
     }
   }
   ```

   Windows без Git Bash:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "shell": "powershell",
               "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"$HOME\\.claude\\skills\\develop-folder\\scripts\\session-check.ps1\"",
               "timeout": 15
             }
           ]
         }
       ]
     }
   }
   ```
   `-ExecutionPolicy Bypass` діє лише на цей запуск, системну політику він не змінює.

Codex цей крок не потрібен. Без кроку 2 скіл теж працює, але папку буде створено лише під час `/init` або коли Claude сам помітить CLAUDE.md без `.develop/`.

## Склад

Встановлений скіл:

```
develop-folder/
├── SKILL.md                        # правила для агента (свої для Claude Code і для Codex)
├── .gitattributes                  # LF для .sh, щоб bash не падав на Windows
├── scripts/ensure-develop.sh|.ps1  # створює або доповнює .develop; наявні файли не перезаписує
├── scripts/next-number.sh|.ps1     # наступний вільний номер: questions | features | bugfix
├── scripts/session-check.sh|.ps1   # SessionStart hook (лише Claude Code)
└── templates/                      # README, glossary, investigation, questions, feature, bug
```

У каталозі скрипти й шаблони лежать один раз у `shared/`, а в `claude/` і `codex/` — лише те, що відрізняється.
