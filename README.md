# NaN-GDK Base Project

All the main code is in the `main.lua` file located in the `source` directory.

## How to build

1. Clone the repository.
2. Open the `build_project.py` file in a text editor.
3. Update the `github_base_url` variable to the correct branch, repository, and path.
4. Run the `build_project.py` file.
5. The `build.lua` file will be generated in the `build` directory.
6. Copy the `build.lua` file to Blip's world code.

## How to run

1. Open Blip's world code.
2. Paste the `build.lua` file into the world code.
3. Press the play button.
4. Make sure there's no errors in logs, you can copy logs with `debug.getLogs()` command.