# Telegram Transcribe Skill

Скилл для **Claude Code**, который расшифровывает все голосовые из экспорта Telegram локально на Mac. Без облака, без подписок.

📖 **Полная инструкция (для учеников):** https://yasikvlad.github.io/telegram-transcribe-skill/

## Установка через Claude Code

Для учеников курса — открой Claude Code и вставь это сообщение Клоду:

```
Поставь мне скилл telegram-transcribe-skill.
Запусти этот установщик и подожди пока всё доделается:

curl -fsSL https://raw.githubusercontent.com/yasikvlad/telegram-transcribe-skill/main/install.sh | bash
```

Клод спросит разрешение запустить команду — жми **Yes**. Дальше он сам поставит всё за 3-5 минут.

## Установка через Терминал (для тех кто умеет)

```bash
curl -fsSL https://raw.githubusercontent.com/yasikvlad/telegram-transcribe-skill/main/install.sh | bash
```

Что делает установщик (в обоих случаях):
- Ставит Homebrew (если нет)
- Ставит `whisper-cpp` и `ffmpeg`
- Скачивает модель `large-v3-turbo` (1.5 ГБ)
- Кладёт скилл в `~/.claude/skills/telegram-transcribe/`
- Кладёт `transcribe-tg.sh` в `~/bin/` для опционального запуска из терминала

## Как пользоваться

1. Экспорт чата из Telegram Desktop (с галочкой Voice messages)
2. В Claude Code: «расшифруй голосовые из ~/Downloads/Telegram Desktop/ChatExport_…»
3. Готово — `transcripts/_ALL.md` рядом с экспортом

## Системные требования

- macOS (Apple Silicon летает, на Intel работает медленнее)
- ~2 ГБ свободного места
- Установленный Claude Code

## Что внутри

```
telegram-transcribe-skill/
├── install.sh              # one-line installer
├── skill/
│   ├── SKILL.md            # сам скилл для Claude Code
│   └── scripts/
│       └── transcribe.sh   # bash-скрипт транскрибации
├── docs/
│   └── index.html          # инструкция (GitHub Pages)
└── README.md
```

## Под капотом

- **whisper.cpp** — нативная сборка Whisper на C++ с Metal-ускорением
- **large-v3-turbo** — последняя версия модели Whisper, 8× быстрее large-v3 при том же качестве
- **ffmpeg** — конвертация .ogg/.opus/.mp4 в 16 kHz WAV для модели

## Удаление

```bash
brew uninstall whisper-cpp ffmpeg
rm -rf ~/.whisper-models ~/.claude/skills/telegram-transcribe ~/bin/transcribe-tg.sh
```

---

Сделано для курса **AI-Маркетолог · 2 поток** ([@yasikvlad](https://github.com/yasikvlad))
