const pkg = require('./package.json');
const webpack = require('webpack')

module.exports = {
    /*
     ** Headers of the page
     */
    head: {
        title: 'mg-small-cell',
        meta: [
            { charset: 'utf-8' },
            {
                name: 'viewport',
                content: 'width=device-width, initial-scale=1'
            },
            {
                hid: 'description',
                name: 'description',
                content: 'Map of Small Cell applications in Montgomery County'
            }
        ],
        link: [
            {
                rel: 'icon',
                type: 'image/x-icon',
                href: `/${pkg.name}/favicon.ico`
            }
        ]
    },
    modules: [
        '@nuxtjs/axios',
        [
            '@nuxtjs/google-analytics',
            {
                id: 'UA-3383794-4'
            }
        ]
    ],
    plugins: [
        { src: '~/plugins/pym.js', ssr: false },
        { src: '~/plugins/typekit.js', ssr: false },
        { src: '~plugins/chartbeat.js', ssr: false }
    ],
    axios: {
        baseURL: process.server
            ? `http://${process.env.HOST || 'localhost'}:${process.env.PORT ||
                  3000}/${pkg.name}/`
            : `/${pkg.name}/`
    },
    generate: {
        minify: {
            collapseWhitespace: false,
            removeEmptyAttributes: false,
            minifyJS: false
        }
    },
    /*
     ** Global CSS
     */
    router: {
        base: `/${pkg.name}/`
    },
    css: ['~/assets/css/site.css', '~/assets/css/main.css', '~/assets/css/mapbox-gl.css'],
    /*
     ** Add axios globally
     */
    build: {
        vendor: ['axios'],
        plugins: [new webpack.ProvidePlugin({
            'mapboxgl': 'mapbox-gl'
        })],
        /*
         ** Run ESLINT on save
         */
        extend(config, ctx) {
            if (ctx.isClient) {
                config.devtool = 'eval';
                
                config.module.rules.push({
                    enforce: 'pre',
                    test: /\.(js|vue)$/,
                    loader: 'eslint-loader',
                    exclude: /(node_modules)/
                });
            }
        }
    }
};
