import react from '@vitejs/plugin-react';
import path from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    },
  },
  plugins: [
    react()
  ],
  build: {
    outDir: path.resolve(__dirname, '../_oficial_cc_mdt/web/build'),
    emptyOutDir: true,
    assetsInlineLimit: 0,
  }
});
