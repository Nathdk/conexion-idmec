@echo off
start "1 - Backend" cmd /k "cd /d D:\conexion-idmec\backend && npm run dev"
start "2 - ngrok backend" cmd /k "ngrok http --url=https://upstart-goal-recycler.ngrok-free.dev 3000"
start "3 - Panel Laravel" cmd /k "cd /d D:\conexion-idmec\panel-web && php artisan config:clear && php artisan serve"
start "4 - Tunel panel" cmd /k "cloudflared tunnel --url http://localhost:8000"
