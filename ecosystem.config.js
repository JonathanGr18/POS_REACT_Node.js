/**
 * Configuración PM2 para el POS PapeAmistad
 *
 * Comandos básicos:
 *   pm2 start ecosystem.config.js      → arranca backend + frontend (dev)
 *   pm2 start ecosystem.config.js --only pos-backend   → solo backend
 *   pm2 status                          → ver estado
 *   pm2 logs                            → ver logs
 *   pm2 restart all                     → reiniciar todo
 *   pm2 stop all                        → parar
 *   pm2 delete all                      → quitar de pm2
 *   pm2 save                            → guardar lista actual
 *   pm2 startup                         → auto-arranque en boot (Win: pm2-startup)
 */
module.exports = {
  apps: [
    {
      name: 'pos-backend',
      cwd: './backend',
      script: 'server.js',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      env: {
        NODE_ENV: 'production',
      },
      env_development: {
        NODE_ENV: 'development',
      },
      error_file: './backend/logs/err.log',
      out_file: './backend/logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      time: true,
    },
    // Frontend en producción: servir el build con "serve" (no npm start)
    // Para desarrollo con hot reload, corre `npm start` manualmente
    {
      name: 'pos-frontend',
      cwd: './front-pos',
      script: 'npx',
      args: 'serve -s build -l 3000',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '300M',
      // Solo inicia si existe la carpeta build (generada con `npm run build`)
      error_file: './front-pos/logs/err.log',
      out_file: './front-pos/logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      time: true,
    },
  ],
};
