module.exports = {
    entry: "./entry.js",
    output: {
        path: __dirname,
        filename: "bundle.js"
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
