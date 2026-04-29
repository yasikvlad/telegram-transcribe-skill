#!/bin/bash
# Telegram Transcribe Skill — installer for Claude Code
# https://github.com/yasikvlad/telegram-transcribe-skill

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

REPO_RAW="https://raw.githubusercontent.com/yasikvlad/telegram-transcribe-skill/main"
SKILL_DIR="$HOME/.claude/skills/telegram-transcribe"
MODEL_DIR="$HOME/.whisper-models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
BIN_DIR="$HOME/bin"

ok()    { echo -e "${GREEN}✓${RESET} $1"; }
info()  { echo -e "${BLUE}→${RESET} $1"; }
warn()  { echo -e "${YELLOW}⚠${RESET} $1"; }
err()   { echo -e "${RED}✗${RESET} $1" >&2; }
title() { echo -e "\n${BOLD}$1${RESET}"; }

echo ""
echo -e "${BOLD}🎙️  Telegram Transcribe Skill — установка${RESET}"
echo -e "Локальная транскрибация голосовых из Telegram через whisper.cpp"
echo ""

# --- Step 1: macOS check ---
title "1. Проверка системы"
if [ "$(uname -s)" != "Darwin" ]; then
  err "Этот скилл работает только на macOS. Извини."
  exit 1
fi
ok "macOS обнаружен"

ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  ok "Apple Silicon (M1/M2/M3/M4/M5) — Metal-ускорение доступно"
else
  warn "Intel Mac — будет работать, но медленнее. На M-чипе раз в 5–10 быстрее."
fi

# --- Step 2: Homebrew ---
title "2. Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew не установлен. Ставлю..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for current session
  if [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -d "/usr/local/bin" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  ok "Homebrew установлен"
else
  ok "Homebrew уже стоит"
fi

# --- Step 3: whisper-cpp + ffmpeg ---
title "3. Зависимости (whisper-cpp, ffmpeg)"
if ! command -v whisper-cli >/dev/null 2>&1; then
  info "Ставлю whisper-cpp..."
  brew install whisper-cpp
  ok "whisper-cpp установлен"
else
  ok "whisper-cpp уже стоит"
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  info "Ставлю ffmpeg..."
  brew install ffmpeg
  ok "ffmpeg установлен"
else
  ok "ffmpeg уже стоит"
fi

# --- Step 4: Whisper model ---
title "4. Модель Whisper large-v3-turbo (1.5 ГБ)"
mkdir -p "$MODEL_DIR"
if [ -f "$MODEL_FILE" ] && [ "$(stat -f%z "$MODEL_FILE" 2>/dev/null || echo 0)" -gt 1000000000 ]; then
  ok "Модель уже скачана: $MODEL_FILE"
else
  info "Скачиваю модель (~1.5 ГБ, может занять 3–5 минут)..."
  curl -L --progress-bar -o "$MODEL_FILE" "$MODEL_URL"
  ok "Модель скачана"
fi

# --- Step 5: Install skill ---
title "5. Скилл telegram-transcribe в Claude Code"
mkdir -p "$SKILL_DIR/scripts"
info "Скачиваю SKILL.md..."
curl -fsSL -o "$SKILL_DIR/SKILL.md" "$REPO_RAW/skill/SKILL.md"
info "Скачиваю transcribe.sh..."
curl -fsSL -o "$SKILL_DIR/scripts/transcribe.sh" "$REPO_RAW/skill/scripts/transcribe.sh"
chmod +x "$SKILL_DIR/scripts/transcribe.sh"
ok "Скилл установлен в $SKILL_DIR"

# --- Step 6: Optional terminal entrypoint ---
title "6. Терминальная команда (опционально)"
mkdir -p "$BIN_DIR"
cp "$SKILL_DIR/scripts/transcribe.sh" "$BIN_DIR/transcribe-tg.sh"
chmod +x "$BIN_DIR/transcribe-tg.sh"
ok "Команда $BIN_DIR/transcribe-tg.sh — можно запускать из терминала напрямую"

# --- Final check ---
title "🔍 Финальная проверка"
if command -v whisper-cli >/dev/null && command -v ffmpeg >/dev/null && [ -f "$MODEL_FILE" ] && [ -f "$SKILL_DIR/SKILL.md" ]; then
  ok "Всё на месте"
else
  err "Что-то пошло не так. Напиши Владу с этим логом."
  exit 1
fi

echo ""
echo -e "${BOLD}${GREEN}🎉 Готово!${RESET}"
echo ""
echo -e "${BOLD}Как пользоваться:${RESET}"
echo ""
echo -e "  ${BLUE}1.${RESET} Экспортируй чат из Telegram Desktop:"
echo -e "     меню чата → Export chat history → формат HTML, поставь галочку Voice messages"
echo ""
echo -e "  ${BLUE}2.${RESET} Открой Claude Code в терминале и напиши:"
echo -e "     ${BOLD}«расшифруй голосовые из ~/Downloads/Telegram Desktop/ChatExport_...»${RESET}"
echo ""
echo -e "  ${BLUE}3.${RESET} Получи ${BOLD}transcripts/_ALL.md${RESET} рядом с экспортом — все голосовые в тексте"
echo ""
echo -e "Подробная инструкция: ${BLUE}https://yasikvlad.github.io/telegram-transcribe-skill/${RESET}"
echo ""
