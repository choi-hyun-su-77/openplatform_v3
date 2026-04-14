import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { fileURLToPath, URL } from 'node:url';

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 25174,
    strictPort: true,
    host: '0.0.0.0',
    proxy: {
      '/api/bff': {
        target: 'http://localhost:19091',
        changeOrigin: true
      },
      '/api': {
        target: 'http://localhost:19090',
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true
  }
});
