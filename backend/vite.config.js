import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';
import { fileURLToPath, URL } from 'node:url';

export default defineConfig({
    build: {
        chunkSizeWarningLimit: 4000,
        emptyOutDir: false,
        rollupOptions: {
            output: {
                manualChunks: {
                    'vendor-charts': ['apexcharts', 'vue3-apexcharts', 'echarts', 'vue3-echarts'],
                    'vendor-ui': ['bootstrap', 'bootstrap-vue-next', '@vueform/slider', '@vueform/multiselect', 'sweetalert2'],
                    'vendor-maps': ['leaflet', '@vue-leaflet/vue-leaflet'],
                    'vendor-core': ['vue', 'vuex', 'vue-i18n', '@inertiajs/vue3', 'axios', 'moment', 'ziggy-js'],
                }
            }
        }
    },
    server: {
        host: '0.0.0.0',
        port: 5173,
        hmr: {
            host: 'parkirgo.localhost',
        },
    },
    plugins: [
        laravel({
            input: 'resources/js/app.js',
            refresh: true,
        }),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
    ],
    resolve: {
        alias: {
            '@assets': '/resources/', // Update this with the correct path to your images
            '@favicon': '/resources/images/', // Update this with the correct path to your images
            'bootstrap': fileURLToPath(new URL('./node_modules/bootstrap', import.meta.url)),
        },
    },
    css: {
        preprocessorOptions: {
            scss: {
                loadPaths: ['node_modules'],
            },
        },
    },
});
