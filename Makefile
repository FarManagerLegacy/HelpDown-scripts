ifeq (1,$(words $(MAKEFILE_LIST))) # if not included
  .DEFAULT_GOAL:=help
endif

define HELP
Makefile for documents converting using pandoc.
  Source: *.text (extension defined by SOURCE_EXT).
  Target(s): enumerated in commandline (otherwise can be set in .DEFAULT_GOAL)

Usage:
make some_doc.html
  Convert some_doc.text to some_doc.html.
  Instead of ".html" any other pandoc-supported file type can be used.

make some_doc.hlf
  Convert some_doc.text to some_doc.hlf using pandoc and HtmlToFarHelp.

make html
  Convert *.text to *.html.
  Instead of ".html" any other supported extension can be used, incl. hlf (must be enumerated in TARGET_EXT).

make clean
  Clean current directory from all files with extensins specified in TARGET_EXT.

make help
  This help

make install
  Copy *.lua to $(APPDATA)\pandoc\filters

Notes:
  1. pandoc.exe and HtmlToFarHelp.exe must be available.
     It is also possible to define full paths in env variables PANDOC/HTMLTOFARHELP.
  2. Some conversions may require additional lua filters, which must be present in current directory.
     Alternatively they can reside in $(APPDATA)\pandoc\filters
     (See `make install`)
  3. Some conversions may require lua writers, which must be present in current directory.
     Alternatively they can reside in $(APPDATA)\pandoc\custom
  4. The best way to customize this Makefile is including it in own Makefile, adding new rules
     and (re)defining corresponding variables.
endef

SOURCE_EXT:=text
SOURCE_FORMAT?=--from=markdown-auto_identifiers-raw_tex+autolink_bare_uris

TARGET_EXT+=hlfhtml htm html md plain native json hlf
ifneq (,$(filter $(TARGET_EXT),$(SOURCE_EXT)))
  $(error TARGET_EXT cannot include SOURCE_EXT)
else ifneq (1,$(words $(SOURCE_EXT)))
  $(error SOURCE_EXT must be single ext)
endif

#https://pandoc.org/installing.html
PANDOC?=pandoc.exe
TARGET_FORMAT:= # deduced from extension; defaulting to html
FLAGS+=--wrap=preserve
EXTRA+=--lua-filter=FarLinks.lua

#https://www.nuget.org/packages/HtmlToFarHelp
HTMLTOFARHELP?=HtmlToFarHelp.exe

RM:=del

# Far Manager help file
%.hlf: %.hlfhtml
	@$(HTMLTOFARHELP) from="$<"; to="$@"
	$(info $@)

# intermediate file for hlf
%.hlfhtml: TARGET_FORMAT:= --to=html --no-highlight
%.hlfhtml: EXTRA:=

# full-featured html, with headers, styles, ... (otherwise use `htm`)
%.html: FLAGS+= --standalone --strip-comments --lua-filter=HeaderToTitle.lua

# github-flavored markdown (pandoc --list-extensions=gfm)
%.md: TARGET_FORMAT:= --to=gfm --lua-filter=DefinitionToBulletList.lua

#prevent circular dependencies
%.text %.lua: ;
$(MAKEFILE_LIST): ;
.SECONDEXPANSION: #https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html#Secondary-Expansion
%: $$(basename %).$(SOURCE_EXT) $(MAKEFILE_LIST) $(wildcard *.lua)
	@$(PANDOC) $(SOURCE_FORMAT) $(TARGET_FORMAT) $(FLAGS) $(EXTRA) --output=$@ $<
	$(info $@)

.PHONY: $(TARGET_EXT) clean help install

# targets like html md hlf...
SOURCES:=$(wildcard *.$(SOURCE_EXT))
NAMES:=$(basename $(SOURCES))
$(TARGET_EXT): %: $(addsuffix .%,$(NAMES))

TARGETS_MASK:=$(addprefix *.,$(TARGET_EXT))
clean:
	$(info $(wildcard $(TARGETS_MASK)))
	@$(RM) $(TARGETS_MASK)

help:
	$(info $(HELP))
	@rem

INSTALL_DIR:=$(APPDATA)/pandoc/filters
install: $(INSTALL_DIR) $(addprefix $(INSTALL_DIR)/, $(wildcard *.lua))
$(INSTALL_DIR):
	mkdir $(subst /,\,$@)
$(INSTALL_DIR)/%: %
	@rem cmd /c mklink $(subst /,\, $@ $(realpath $<))
	copy $< $(subst /,\,$@)
