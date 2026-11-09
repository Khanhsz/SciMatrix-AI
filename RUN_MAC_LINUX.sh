#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

if ! command -v node >/dev/null 2>&1; then
  echo "Chua cai Node.js 22+. Tai tai https://nodejs.org/"
  exit 1
fi

if [ ! -f .env.local ]; then
  cp .env.example .env.local
  echo "Da tao .env.local. Hay dien Supabase URL, Publishable Key va Gemini API Key."
  ${EDITOR:-nano} .env.local
fi

if [ ! -d node_modules ]; then
  npm install
fi

echo "SciMatrix AI: http://localhost:3000"
npm run dev
