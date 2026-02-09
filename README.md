# OpenSCAD Helper Library

This is a library of modules, functions and variables for OpenSCAD that I use in almost all my projects

## Installation

### Download and include (easy)
The simplest way to use this library is to just download it from github by clicking `Code > Download ZIP` or here [https://github.com/tsnoad/OpenSCAD-Helper-Library/archive/refs/heads/master.zip](https://github.com/tsnoad/OpenSCAD-Helper-Library/archive/refs/heads/master.zip)


Alternately you can run this terminal command to download the libary

```bash
curl -sSL https://github.com/tsnoad/OpenSCAD-Helper-Library/raw/refs/heads/master/common_params_and_modules.scad
```

### Add to your git repo as a submodule (recommended)

If your OpenSCAD project is a git repository, you can add this library as a git submodule.

```bash
git submodule add https://github.com/tsnoad/OpenSCAD-Helper-Library.git # Add this library as a submodule
git commit -m 'added helper library submodule' # save the change to your repo
```

Then, to get any updates you can run:
```bash
git submodule update --remote
```

#### Setting up a git repository

If you don't have a git repository yet you can run these commands to set one up

```bash
git init # Create the repository
echo '.DS_Store' >> .gitignore # If you're on a Mac, do this to ignore the hidden files Mac OS creates
git add .gitignore
git commit -m 'add gitignore file'

echo 'include <OpenSCAD-Helper-Library/common_params_and_modules.scad>;' >> some_openscad_file.scad # Create an openscad file and include this library
git add some_openscad_file.scad # Add the openscad file to the repo
git commit -m 'added openscad file' # Save changes to repo

git submodule add https://github.com/tsnoad/OpenSCAD-Helper-Library.git # Add this library as a submodule

# Binary (like images and STLs) files _should not_ be added to git repositories as they massively inflate the repository size
# Instead we can use LFS to store them in the repo without these issues
git lfs install # Install LFS (this should only need to be done once)
git lfs track "*.stl" # Tell LFS that it can track STL files. Note that this doesn't add files to the repo
git lfs track "*.png"
git add .gitattributes
git commit -m 'set up LFS'

git add some_rendered_file.stl # Add an STL file to the repo
git commit -m 'added an stl file to repo'
```

## Example Usage

Once installed, you can use this libray in an OpenSCAD file by adding this to the top of your scad file:

```openscad
include <OpenSCAD-Helper-Library/common_params_and_modules.scad>;
```

### Example: [Cylinders](https://github.com/tsnoad/OpenSCAD-Helper-Library/blob/master/examples/cylinders.scad)
![Example of cylinders](https://github.com/tsnoad/OpenSCAD-Helper-Library/raw/refs/heads/master/examples/example_cylinders.png)

### Example: [Cylinders with flat tops (for 3d printing)](https://github.com/tsnoad/OpenSCAD-Helper-Library/blob/master/examples/cylinders_for_overhangs.scad)
![Example of cylinders with overhangs](https://github.com/tsnoad/OpenSCAD-Helper-Library/raw/refs/heads/master/examples/example_cylinders_for_overhangs.png)

## Rendering with Make

This library also includes a makefile that can be used to render STLs from the command line.

Assuming you have installed the library as a git submodule, you then need to set it up as follows:

```bash
ln -s OpenSCAD-Helper-Library/makefile makefile # Create symlink to the makefile
git add makefile # Add the symlinked makefile to your repo
```

Next, run `make config` which will tell make where OpenSCAD is installed on your computer, and what target scad file it should try to render. These are stored in a file called `.makeconfig`

```bash
make config
echo '.makeconfig' >> .gitignore # Tell git to ignore the config file
git commit -m 'set up make file and config' # Save the changes to your repo
```

Make will look for a special string in the target scad file, and will render an STL based on this

```scad
*/* make 'some_output_file_name' */ some_module();
*/* make 'a_rendered_cube' */ cube([10,10,10]);
```

This will render a file named `some_output_file_name.stl` and a file named `a_rendered_cube.stl`

Make can also be used to render PNG images like this:
```scad
*/* make image 'some_output_image_name' */ some_module();
```

## Licence

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)





