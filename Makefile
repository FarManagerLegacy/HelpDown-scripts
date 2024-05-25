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

make html
  Convert *.text to *.html.
  Instead of ".html" any other supported extension can be used, incl. hlf (must be enumerated in TARGET_EXT).

make some_doc.hlf
make hlf
  Convert to .hlf using pandoc and HtmlToFarHelp.

make some_doc.forum
make forum
  Convert to phpBB-flavored markdown (Litedown).

make clean
  Clean current directory from all files with extensions specified in TARGET_EXT.

make help
  This help

make install
  Copy *.lua to $(APPDATA)\pandoc\filters
  Or to $$(DATA_DIR)\filters (if defined).

Notes:
  1. pandoc.exe and HtmlToFarHelp.exe must be available.
     It is also possible to define full paths in env variables PANDOC/HTMLTOFARHELP.
  2. Some conversions may require additional lua filters, which must be present in current directory.
     Alternatively they can reside in $(DATA_DIR)\filters
     (See `make install`)
  3. Some conversions may require lua writers, which must be present in current directory.
     Alternatively they can reside in $(DATA_DIR)\custom
  4. The best way to customize this Makefile is including it in own Makefile, adding new rules
     and (re)defining corresponding variables.
endef

SOURCE_EXT:=text
SOURCE_FORMAT?=--from=markdown-auto_identifiers-raw_tex+autolink_bare_uris

TARGET_EXT+=hlfhtml htm html md plain native json forum hlf
ifneq (,$(filter $(TARGET_EXT),$(SOURCE_EXT)))
  $(error TARGET_EXT cannot include SOURCE_EXT)
else ifneq (1,$(words $(SOURCE_EXT)))
  $(error SOURCE_EXT must be single ext)
endif

#https://pandoc.org/installing.html
PANDOC?=pandoc.exe
TARGET_FORMAT:= # deduced from extension; defaulting to html
FLAGS+=--wrap=preserve
EXTRA+=--lua-filter=FarLinks.lua --strip-comments

#https://www.nuget.org/packages/HtmlToFarHelp
HTMLTOFARHELP?=HtmlToFarHelp.exe

SHELL:=$(ComSpec)
RM:=del

ifdef DATA_DIR
  FLAGS+= --data-dir=$(DATA_DIR)
else
  DATA_DIR:=$(APPDATA)\pandoc#default
endif
LUA_PATH:=$(LUA_PATH);$(DATA_DIR)\filters\?.lua;$(DATA_DIR)\filters\?\init.lua

# Far Manager help file
%.hlf: %.hlfhtml
	@$(HTMLTOFARHELP) from="$<"; to="$@"
	$(info $@)

# intermediate file for hlf
%.hlfhtml: TARGET_FORMAT:= --to=html --no-highlight
%.hlfhtml: FLAGS+= --lua-filter=ChmLinks.lua --lua-filter=unDetails.lua
%.hlfhtml: EXTRA:=

# full-featured html, with headers, styles, ... (otherwise use `htm`)
%.html: FLAGS+= --standalone --lua-filter=HeaderToTitle.lua

# github-flavored markdown (pandoc --list-extensions=gfm)
%.md: TARGET_FORMAT:= --to=gfm --lua-filter=DefinitionToBulletList.lua --lua-filter=mdHeadersLinks.lua

# prepare text for posting on forum.farmanager.com
%.forum: TARGET_FORMAT:=--to=markdown_strict+fenced_code_blocks-raw_html-smart --lua-filter=DefinitionToBulletList.lua
%.forum: FLAGS+= --lua-filter=fold.lua --lua-filter=forum.lua --lua-filter=DetailsToSpoiler.lua
%.forum: EXTRA:=--shift-heading-level-by=1

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

install: $(DATA_DIR)/filters $(addprefix $(DATA_DIR)/filters/, $(wildcard *.lua))
$(DATA_DIR)/filters:
	mkdir $(subst /,\,$@)
$(DATA_DIR)/filters/%: %
	@rem cmd /c mklink $(subst /,\, $@ $(realpath $<))
	copy $< $(subst /,\,$@)
