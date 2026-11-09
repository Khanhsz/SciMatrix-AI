@echo off
setlocal
cd /d "%~dp0"
title SciMatrix AI - Literature Review Studio

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Chua cai Node.js.
  echo Tai Node.js 22 LTS tai https://nodejs.org/
  pause
  exit /b 1
)

if not exist ".env.local" (
  copy ".env.example" ".env.local" >nul
  echo Da tao .env.local. Hay dien Supabase URL, Publishable Key va Gemini API Key.
  notepad ".env.local"
)

if not exist "node_modules" (
  echo Dang cai cac thu vien lan dau...
  call npm install
  if errorlevel 1 (
    echo [ERROR] npm install that bai. Kiem tra ket noi Internet va thu lai.
    pause
    exit /b 1
  )
)

echo.
echo SciMatrix AI se chay tai http://localhost:3000
echo Nhan Ctrl+C de dung.
echo.
call npm run dev
pause
