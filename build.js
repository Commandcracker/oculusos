const luamin = require("luamin");
const luaparse = require("luaparse");
const fs = require("fs");
const path = require("path");

const license_map = {
    // lib
    //"lib/aes.lua": "aeslua.txt",
    "lib/bigfont.lua": "bigfont.txt",
    "lib/cprint.lua": "cprint.txt",
    "lib/cryptoNet.lua": "cryptonet.txt",
    "lib/framebuffer.lua": "framebuffer.txt",
    // bin
    //"lib/readline.lua": "metis.txt",
    //"lib/stack_trace.lua": "metis.txt",
    //"lib/scroll_window.lua": "metis.txt",
    //"lib/argparse.lua": "metis.txt",
    //"bin/shell.lua": "mbs.txt",
    "bin/matrix.lua": "matrix.txt"
}

function minify(input_file, output_file, options) {
    fs.readFile(input_file, "utf8", (err, data) => {
        if (err) throw err;

        const parsed_data = luaparse.parse(data, options);
        var minifyed_data = luamin.minify(parsed_data);
        
        if (license_map[input_file.slice(4)] != null) {
            data = fs.readFileSync(path.join("Licenses", license_map[input_file.slice(4)]), "utf8")
            minifyed_data = "--[[\n" + data + "\n]]\n" + minifyed_data;
        }

        fs.writeFileSync(output_file, minifyed_data);

        const oldSize = fs.statSync(input_file).size;
        const newSize = fs.statSync(output_file).size;
        const percentDecreased = Math.floor(((oldSize - newSize) / oldSize) * 100);

        console.log(input_file + " -> " + output_file + " " + percentDecreased + "% decrease in file size");
    });
}

function minify_folder(input_folder, output_folder, options) {
    fs.readdir(input_folder, (err, files) => {
        if (err) throw err;
        for (const file of files) {
            if (file != "index" && !fs.statSync(path.join(input_folder, file)).isDirectory()) {
                minify(path.join(input_folder, file), path.join(output_folder, file), options);
            }
        }
    });
}

function minify_folders(input_folder, output_folder, options) {
    fs.readdir(input_folder, (err, files) => {
        if (err) throw err;
        for (const file of files) {
            if (file != "index") {
                if (fs.statSync(path.join(input_folder, file)).isDirectory()) {
                    if (!fs.existsSync(path.join(output_folder, file))) {
                        fs.mkdirSync(path.join(output_folder, file));
                    }
                    minify_folders(path.join(input_folder, file), path.join(output_folder, file), options);
                } else {
                    minify(path.join(input_folder, file), path.join(output_folder, file), options);
                }
            }
        }
    });
}

if (!fs.existsSync("build")) {
    fs.mkdirSync("build");
}

minify_folders("src", "build");
