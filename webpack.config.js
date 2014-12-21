module.exports = {
    entry: "./entry.js",
    output: {
        path: __dirname,
        filename: "bundle.js"
    },
    externals: {
        // require("jquery") is external and available on the global var jQuery
        "jquery": "jQuery",
        //"coffee-script": "CoffeeScript"
    },
    module: {
        loaders: [
            { test: /\.css$/, loader: "style!css" },
            { test: /\.coffee$/, loader: "coffee-loader" },
        ]
    },
    resolve: {
        alias: {
            //"fs": "tmp",
            //"file": "tmp",
            //"repl": "tmp",
            //"child_process": "tmp",
        },
        modulesDirectories: [
            "lib/js",
            "lib/css",
            "node_modules",
        ]
    },
};
