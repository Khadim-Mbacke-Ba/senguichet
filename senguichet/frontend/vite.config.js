import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Configuration de Vite
// Le serveur de dev tourne sur le port 3000.
// Les appels vers /api sont rediriges vers le backend (port 8080),
// ce qui evite les problemes de CORS en developpement.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
})
