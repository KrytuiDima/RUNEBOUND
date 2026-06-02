import { defineConfig } from 'vite';
import path from 'path';
export default defineConfig({
    resolve: {
        alias: {
            '@runebound/shared': path.resolve(__dirname, '../shared/src'),
            'three': path.resolve(__dirname, '../../node_modules/three')
        }
    },
    server: {
        fs: {
            allow: ['../..']
        },
        hmr: {
            overlay: false
        }
    },
    optimizeDeps: {
        include: ['three']
    }
});
//# sourceMappingURL=vite.config.js.map