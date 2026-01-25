# Check if .makeconfig exists, if not provide helpful error
ifeq (,$(wildcard .makeconfig))
  ifeq (,$(filter config,$(MAKECMDGOALS)))
    $(error .makeconfig not found. Run 'make config' to create it)
  endif
endif

# Include config if it exists
-include .makeconfig

# Default values (used by config target)
DEFAULT_OPENSCAD = "/Applications/OpenSCAD 2.app/Contents/MacOS/OpenSCAD"
DEFAULT_TARGET_SCAD = "model.scad"
DEFAULT_RENDER_FN = 144

# Use configured values or defaults
OPENSCAD ?= $(DEFAULT_OPENSCAD)
TARGET_SCAD ?= $(DEFAULT_TARGET_SCAD)
RENDER_FN ?= $(DEFAULT_RENDER_FN)

TARGETS=$(shell sed '/^\*\/\* make '\''[a-zA-Z0-9_-]*'\'' \*\//!d;s/\*\/\* make '\''//;s/'\''.*/.stl/' $(TARGET_SCAD))

# Strip .scad to get just basenames
BASENAMES = $(basename $(TARGETS))

# Extensions to clean
CLEAN_EXTS = .scad

# Files to remove
CLEANFILES = \
  $(foreach ext,$(CLEAN_EXTS),$(addsuffix $(ext),$(BASENAMES)))

.PHONY: clean list config

all: ${TARGETS}

list:
    @echo "Targets: ${TARGETS}"

clean:
    @echo "Targets for cleaning: ${CLEANFILES}"
    rm -f ${CLEANFILES}

config:
    @echo "Creating .makeconfig for this project..."
    @echo ""
    @echo "Checking for OpenSCAD installations..."
    @echo ""
    @paths=( \
        "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" \
        "/Applications/OpenSCAD 2.app/Contents/MacOS/OpenSCAD" \
        "/usr/bin/openscad" \
        "/usr/local/bin/openscad" \
        "C:/Program Files/OpenSCAD/openscad.exe" \
        "C:/Program Files (x86)/OpenSCAD/openscad.exe" \
    ); \
    found=(); \
    for p in "${paths[@]}"; do \
        if [ -f "$p" ] || [ -f "$(echo $p | sed 's/C:/\/mnt\/c/')" ]; then \
            found+=("$p"); \
        fi; \
    done; \
    echo "Found installations:"; \
    if [ ${#found[@]} -eq 0 ]; then \
        echo "  (none found)"; \
    else \
        for i in "${!found[@]}"; do \
            echo "  $((i+1)). ${found[$i]}"; \
        done; \
    fi; \
    echo "  $((${#found[@]}+1)). Enter path manually"; \
    echo ""; \
    read -p "Select option [1]: " choice; \
    choice=${choice:-1}; \
    if [ "$choice" -le "${#found[@]}" ] && [ "$choice" -ge 1 ] 2>/dev/null; then \
        scad_path="${found[$((choice-1))]}"; \
    else \
        read -p "Enter OpenSCAD executable path: " scad_path; \
    fi; \
    echo ""; \
    read -p "Target .scad filename [$(DEFAULT_TARGET_SCAD)]: " scad_file; \
    scad_file=${scad_file:-$(DEFAULT_TARGET_SCAD)}; \
    echo "OPENSCAD = $scad_path" > .makeconfig; \
    echo "TARGET_SCAD = $scad_file" >> .makeconfig; \
    echo ""; \
    echo ".makeconfig created with:"; \
    cat .makeconfig; \
    echo ""; \
    echo "Add .makeconfig to your .gitignore to keep project-specific settings local"

# Keep auto-generated .scad files to avoid constant rebuilds
.SECONDARY: $(shell echo "${TARGETS}" | sed 's/\.stl/.scad/g')

# Explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

%.scad:
    sed 's/^\*\/\* make '\''$*'\'' \*\/\ /\!/;s/^$fn \= [0-9]*\;/$fn = $(RENDER_FN)\;/' $(TARGET_SCAD) > $@

%.stl: %.scad
    $(OPENSCAD) --enable fast-csg-safer --enable manifold -o $@ $
