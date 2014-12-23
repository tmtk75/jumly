var path = require("path");

module.exports = {
    entry: {
      jumly: "./lib/entry.js",
      spec:  "./spec/entry.js",
    },
    output: {
        path: path.join(__dirname, './dist'),
        path: "./dist",
        publicPath: '.',
        filename: 'bundle.[name].js',
        //chunkFilename: '[chunkhash].js'
    },
    externals: {
        // require("jquery") & require("coffee-script") are external and available on the global
        "jquery": "jQuery",
        "coffee-script": "CoffeeScript"
    },
    module: {
        loaders: [
            { test: /\.css$/, loader: "style!css" },
            { test: /\.styl$/, loader: "style-loader!css-loader!stylus-loader" },
            { test: /\.coffee$/, loader: "coffee-loader" },
        ]
    },
    resolve: {
        modulesDirectories: [
            "lib/js",
            "lib/css",
            "node_modules",
            "spec",
        ]
    },
};
