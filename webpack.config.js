module.exports = {
    entry: "./entry.js",
    output: {
        path: __dirname,
        filename: "bundle.js"
    },
    externals: {
        // require("jquery") & require("coffee-script") are external and available on the global
        "jquery": "jQuery",
        "coffee-script": "CoffeeScript"
    },
    module: {
        loaders: [
            { test: /\.css$/, loader: "style!css" },
            { test: /\.coffee$/, loader: "coffee-loader" },
        ]
    },
    resolve: {
        modulesDirectories: [
            "lib/js",
            "lib/css",
            "node_modules",
        ]
    },
};
