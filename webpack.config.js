const path = require("path");
const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const { env } = require("yargs");

let localCanisters, prodCanisters, canisters;

function initCanisterIds() {
    try {
        localCanisters = require(path.resolve(".dfx", "local", "canister_ids.json"));
    } catch (error) {
        console.log("No local canister_ids.json found. Continuing production");
    }
    try {
        prodCanisters = require(path.resolve("canister_ids.json"));
    } catch (error) {
        console.log("No production canister_ids.json found. Continuing with local");
    }

    const network =
        process.env.DFX_NETWORK ||
        (process.env.NODE_ENV === "production" ? "ic" : "local");
    console.log("Canster network: " + network);
    canisters = network === "local" ? localCanisters : prodCanisters;

    for (const canister in canisters) {
        process.env[canister.toUpperCase() + "_CANISTER_ID"] = canisters[canister][network];
    }
}
initCanisterIds();

const isDevelopment = process.env.NODE_ENV !== "production";
module.exports = (env) => {
    var part = env.part;
    console.log("building part: " + part);
    return {
        target: "web",
        mode: isDevelopment ? "development" : "production",
        entry: {
            "main": "./src/ui/" + part + "/index.js"
        },
        devtool: isDevelopment ? "source-map" : false,
        output: {
            filename: "index.js",
            path: path.join(__dirname, "dist", part)
        },
        plugins: [
            /////////////////////////////////////////////////////////////////////////////////
            new HtmlWebpackPlugin({
                filename: "index.html",
                template: 'src/ui/' + part + '/index.html',
                cache: false,
                chunks: ["main"],
            }),
            new CopyPlugin({
                patterns: [
                    {
                        from: path.join(__dirname, "src", "ui", "_assets_shared"),
                        to: "[path][name][ext]",
                    },
                ],
            }),
            /////////////////////////////////////////////////////////////////////////////////
            new webpack.EnvironmentPlugin({
                NODE_ENV: 'development',
                CORE_DATA_CANISTER_ID: canisters["core_data"],
                ADMIN_UI_CANISTER_ID: canisters["admin_ui"],
                CLIENT_UI_CANISTER_ID: canisters["client_ui"]
            }),
            new webpack.ProvidePlugin({
                Buffer: [require.resolve("buffer/"), "Buffer"],
                process: require.resolve("process/browser"),
            }),
        ],
        // proxy /api to port 8000 during development
        devServer: {
            host: '0.0.0.0',
            proxy: {
                "/api": {
                    target: "http://0.0.0.0:8000",
                    changeOrigin: true,
                    pathRewrite: {
                        "^/api": "/api",
                    },
                },
            },
            hot: true,
            contentBase: path.resolve(__dirname, "./src/ui/" + part),
            watchContentBase: true,
            watchOptions: {
            	ignored: [
            		"**/*.hx",
            		"**/*.xml"
            	]
            }
        },
    }
}

/*
module.exports = {
    target: "web",
    mode: isDevelopment ? "development" : "production",
    entry: {
        "main": "./src/ui/admin/index.js"
    },
    devtool: isDevelopment ? "source-map" : false,
    output: {
        filename: "index.js",
        path: path.join(__dirname, "dist", "admin")
    },
    plugins: [
        /////////////////////////////////////////////////////////////////////////////////
        new HtmlWebpackPlugin({
            filename: "index.html",
            template: 'src/ui/' + "admin" + '/index.html',
            cache: false,
            chunks: ["main"],
        }),
        new CopyPlugin({
            patterns: [
                {
                    from: path.join(__dirname, "src", "ui", "_assets_shared"),
                    to: "[path][name][ext]",
                },
            ],
        }),
        /////////////////////////////////////////////////////////////////////////////////
        new webpack.EnvironmentPlugin({
            NODE_ENV: 'development',
            CORE_DATA_CANISTER_ID: canisters["core_data"],
            ADMIN_UI_CANISTER_ID: canisters["admin_ui"],
            CLIENT_UI_CANISTER_ID: canisters["client_ui"]
        }),
        new webpack.ProvidePlugin({
            Buffer: [require.resolve("buffer/"), "Buffer"],
            process: require.resolve("process/browser"),
        }),
    ],
    // proxy /api to port 8000 during development
    devServer: {
        proxy: {
            "/api": {
                target: "http://localhost:8000",
                changeOrigin: true,
                pathRewrite: {
                    "^/api": "/api",
                },
            },
        },
        hot: true,
        contentBase: path.resolve(__dirname, "./src/ui/" + "admin"),
        watchContentBase: true
    },
}
*/
