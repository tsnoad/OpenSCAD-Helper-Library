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
DEFAULT_RENDER_FN = 108

# Use configured values or defaults
OPENSCAD ?= $(DEFAULT_OPENSCAD)
TARGET_SCAD ?= $(DEFAULT_TARGET_SCAD)
RENDER_FN ?= $(DEFAULT_RENDER_FN)

# Try to find targets if the target file exists
ifneq (,$(wildcard $(TARGET_SCAD)))
  STL_TARGETS=$(shell sed '/^\*\/\* make '\''[a-zA-Z0-9_-]*'\'' \*\//!d;s/\*\/\* make '\''//;s/'\''.*/.stl/' $(TARGET_SCAD))
  PNG_TARGETS=$(shell sed '/^\*\/\* make image '\''[a-zA-Z0-9_-]*'\'' \*\//!d;s/\*\/\* make image '\''//;s/'\''.*/.png/' $(TARGET_SCAD))
  TARGETS=$(STL_TARGETS) $(PNG_TARGETS)
  
  # Check if any targets were found (but only error for build commands)
  ifeq ($(strip $(TARGETS)),)
    ifneq (,$(filter all,$(MAKECMDGOALS)))
      $(error No render targets found in $(TARGET_SCAD). Add target markers like: /* make 'part_name' */ for STL or /* make image 'image_name' */ for PNG)
    endif
    ifeq ($(MAKECMDGOALS),)
      $(error No render targets found in $(TARGET_SCAD). Add target markers like: /* make 'part_name' */ for STL or /* make image 'image_name' */ for PNG)
    endif
  endif
endif

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
	@echo "TARGET_SCAD: $(TARGET_SCAD)"
	@echo "STL_TARGETS: $(STL_TARGETS)"
	@echo "PNG_TARGETS: $(PNG_TARGETS)"
	@echo "Targets: ${TARGETS}"

clean:
	@echo "Targets for cleaning: ${CLEANFILES}"
	rm -f ${CLEANFILES}

config:
	@echo "Creating .makeconfig for this project..."
	@echo ""
	@echo "Checking for OpenSCAD installations..."
	@echo ""
	@found=""; \
	count=0; \
	for p in \
		"/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" \
		"/Applications/OpenSCAD 2.app/Contents/MacOS/OpenSCAD" \
		"/usr/bin/openscad" \
		"/usr/local/bin/openscad" \
		"C:/Program Files/OpenSCAD/openscad.exe" \
		"C:/Program Files (x86)/OpenSCAD/openscad.exe"; \
	do \
		if [ -f "$$p" ] || [ -f "$$(echo "$$p" | sed 's/C:/\/mnt\/c/')" ]; then \
			count=$$((count + 1)); \
			found="$${found}$${p}|"; \
		fi; \
	done; \
	echo "Found installations:"; \
	if [ "$$count" = "0" ]; then \
		echo "  (none found)"; \
	else \
		i=1; \
		oldIFS="$$IFS"; \
		IFS='|'; \
		for p in $$found; do \
			if [ -n "$$p" ]; then \
				echo "  $$i. $$p"; \
				i=$$((i + 1)); \
			fi; \
		done; \
		IFS="$$oldIFS"; \
	fi; \
	echo "  $$((count + 1)). Enter path manually"; \
	echo ""; \
	printf "Select option [1]: "; \
	read choice; \
	choice=$${choice:-1}; \
	if [ "$$choice" != "" ] && [ "$$choice" -ge 1 ] 2>/dev/null && [ "$$choice" -le "$$count" ] 2>/dev/null; then \
		i=1; \
		oldIFS="$$IFS"; \
		IFS='|'; \
		for p in $$found; do \
			if [ -n "$$p" ] && [ "$$i" = "$$choice" ]; then \
				scad_path="$$p"; \
				break; \
			fi; \
			i=$$((i + 1)); \
		done; \
		IFS="$$oldIFS"; \
	else \
		printf "Enter OpenSCAD executable path: "; \
		read scad_path; \
	fi; \
	echo ""; \
	printf "Target .scad filename [$(DEFAULT_TARGET_SCAD)]: "; \
	read scad_file; \
	scad_file=$${scad_file:-$(DEFAULT_TARGET_SCAD)}; \
	echo ""; \
	echo "Render quality ($$fn value):"; \
	echo "  Low quality (fast):    36-72"; \
	echo "  Medium quality:        108-144"; \
	echo "  High quality (slow):   180-360"; \
	printf "Enter $$fn value [$(DEFAULT_RENDER_FN)]: "; \
	read render_fn; \
	render_fn=$${render_fn:-$(DEFAULT_RENDER_FN)}; \
	printf 'OPENSCAD = "%s"\n' "$$scad_path" > .makeconfig; \
	printf 'TARGET_SCAD = "%s"\n' "$$scad_file" >> .makeconfig; \
	printf 'RENDER_FN = %s\n' "$$render_fn" >> .makeconfig; \
	echo ""; \
	echo ".makeconfig created with:"; \
	cat .makeconfig; \
	echo ""; \
	echo "Add .makeconfig to your .gitignore to keep project-specific settings local"

# Keep auto-generated .scad files to avoid constant rebuilds
.SECONDARY: $(shell echo "${TARGETS}" | sed 's/\.stl/.scad/g;s/\.png/.scad/g')

# Explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)


sed 's/^\*\/\* make\( image\)\? '\''$*'\'' \*\/\ /\!/;s/^$$fn \= [0-9]*\;/$$fn = 314\;/' 

%.scad:
	sed 's/^\*\/\* make '\''$*'\'' \*\/\ /\!/;s/^\*\/\* make image '\''$*'\'' \*\/\ /\!/;s/^$$fn \= [0-9]*\;/$$fn = $(RENDER_FN)\;/' $(TARGET_SCAD) > $@

#%.stl: %.scad
#	$(OPENSCAD) --enable fast-csg-safer --enable manifold -o $@ $

%.stl: %.scad
	"$(OPENSCAD)" --enable fast-csg-safer --enable manifold -o $@ $<

%.png: %.scad
	"$(OPENSCAD)" --enable fast-csg-safer --enable manifold --projection o --imgsize=1920,1080 -o $@ $<