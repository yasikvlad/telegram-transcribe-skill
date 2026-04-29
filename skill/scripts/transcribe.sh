#!/bin/bash
# Transcribe all voice messages in a Telegram export folder.
# Usage: transcribe-tg.sh <ChatExport_folder>

set -e

EXPORT_DIR="${1:-}"
if [ -z "$EXPORT_DIR" ] || [ ! -d "$EXPORT_DIR" ]; then
  echo "Usage: $0 <path/to/ChatExport_YYYY-MM-DD>"
  exit 1
fi

VOICE_DIR="$EXPORT_DIR/voice_messages"
ROUND_DIR="$EXPORT_DIR/round_video_messages"
MODEL="$HOME/.whisper-models/ggml-large-v3-turbo.bin"
OUT_DIR="$EXPORT_DIR/transcripts"
COMBINED="$EXPORT_DIR/transcripts/_ALL.md"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$OUT_DIR"

# Collect all audio files (voice + circle videos)
FILES=()
[ -d "$VOICE_DIR" ] && while IFS= read -r f; do FILES+=("$f"); done < <(find "$VOICE_DIR" -type f \( -iname "*.ogg" -o -iname "*.opus" -o -iname "*.mp3" -o -iname "*.m4a" \) | sort)
[ -d "$ROUND_DIR" ] && while IFS= read -r f; do FILES+=("$f"); done < <(find "$ROUND_DIR" -type f -iname "*.mp4" | sort)

TOTAL=${#FILES[@]}
if [ "$TOTAL" -eq 0 ]; then
  echo "No audio files found in $EXPORT_DIR"
  exit 0
fi

echo "Found $TOTAL audio files. Transcribing with large-v3-turbo (Metal)..."
echo "# Telegram Voice Transcripts" > "$COMBINED"
echo "_Source: $EXPORT_DIR_" >> "$COMBINED"
echo "" >> "$COMBINED"

i=0
for SRC in "${FILES[@]}"; do
  i=$((i+1))
  BASENAME=$(basename "$SRC")
  STEM="${BASENAME%.*}"
  TXT_OUT="$OUT_DIR/$STEM.txt"

  if [ -f "$TXT_OUT" ]; then
    echo "[$i/$TOTAL] SKIP (already done): $BASENAME"
  else
    echo "[$i/$TOTAL] $BASENAME"
    WAV="$TMP_DIR/$STEM.wav"
    ffmpeg -y -loglevel error -i "$SRC" -ar 16000 -ac 1 -c:a pcm_s16le "$WAV"
    whisper-cli -m "$MODEL" -l ru -nt -otxt -of "$OUT_DIR/$STEM" -f "$WAV" 2>/dev/null
    rm -f "$WAV"
  fi

  # Append to combined transcript
  {
    echo "## $BASENAME"
    echo ""
    cat "$TXT_OUT" 2>/dev/null || echo "_(empty)_"
    echo ""
    echo "---"
    echo ""
  } >> "$COMBINED"
done

echo ""
echo "Done. Results:"
echo "  - Individual: $OUT_DIR/*.txt"
echo "  - Combined:   $COMBINED"
