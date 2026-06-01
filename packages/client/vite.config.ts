import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  resolve: {
    alias: {
      '@runebound/shared': path.resolve(__dirname, '../shared/src')
    }
  },
  server: {
    fs: {
      allow: ['..']
    }
  }
});
