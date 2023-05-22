# Skyrim SKSE plugin example

This has been adapted from [this example](https://github.com/xanderdunn/skaar/releases/tag/plugin3). It has a simple build script to simplify the build process. It's also been tidied up a bit, and updated to use Visual Studio 2017.


## Requirements

- Skyrim
    - The Creation Kit
- [Python 3.6](https://www.python.org/downloads/) for the build script
- [Visual Studio 2017](https://visualstudio.microsoft.com/vs/express/)
    - "VC++ 2017 version 15.8 v14.15 latest v141 tools"
    - "Windows Universal CRT SDK"


## Getting Started

Ignore the `common` and `skse` directories, they are included from SKSE and are required for the plugin to compile. The directory of interest for your plugin is `plugin`.

Paths relevant to the build script are stored in `build.ini`, you may need to edit these, particularly if you're not installing with Steam on a 64-bit machine.

To compile, run:

```
python build.py
```

This will compile the plugin and any Papyrus scripts in the `plugin\scripts` directory to the `Debug` directory. When you have finished developing and are ready to compile a release version, run the following:

```
python build.py --release
```

This will compile to the `Release` directory. You can then use the following to install the compiled plugin and scripts to your Skyrim installation's directory:

```
python build.py install
```

Or:

```
python build.py install --release
```

From here follow [this guide](https://github.com/xanderdunn/skaar/wiki/SKSE%3A-Getting-Started).
