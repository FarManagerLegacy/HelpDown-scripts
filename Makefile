.DEFAULT_GOAL:=help
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

Notes:
  1. pandoc.exe and HtmlToFarHelp.exe must be available.
     It is also possible to define full paths in env variables PANDOC/HTMLTOFARHELP.
  2. Some conversions may require additional lua filters, which must be present in current directory.
     Alternatively they can reside in $(APPDATA)\pandoc\filters
  3. Some conversions may require lua writers, which must be present in current directory.
     Alternatively they can reside in $(APPDATA)\pandoc\custom
endef

SOURCE_EXT:=text
TARGET_EXT:=hlfhtml htm html md bbcode native json hlf
ifneq (,$(filter $(TARGET_EXT),$(SOURCE_EXT)))
  $(error TARGET_EXT cannot include SOURCE_EXT)
else ifneq (1,$(words $(SOURCE_EXT)))
  $(error SOURCE_EXT must be single ext)
endif

#https://pandoc.org/installing.html
PANDOC?=pandoc.exe
FLAGS:=--from=markdown-auto_identifiers --wrap=preserve
EXTRA:=--strip-comments --lua-filter=extra.lua

#https://www.nuget.org/packages/HtmlToFarHelp
HTMLTOFARHELP?=HtmlToFarHelp.exe

RM:=del

%.hlf: %.hlfhtml
	@$(HTMLTOFARHELP) from="$<"; to="$@"
	$(info $@)

%.hlfhtml: FLAGS+= --to=html --no-highlight #intermediate file for hlf
%.hlfhtml: EXTRA:=

%.html: FLAGS+= --standalone

%.md: FLAGS+= --to=gfm --lua-filter=gfm.lua #github-flavored markdown

%.bbcode: bbcode.lua
%.bbcode: FLAGS+= --to=bbcode.lua

#prevent circular dependencies
%.text %.lua: ;
Makefile: ;
.SECONDEXPANSION: #https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html#Secondary-Expansion
%: $$(basename %).$(SOURCE_EXT) Makefile $(wildcard *.lua)
	@$(PANDOC) $(FLAGS) $(EXTRA) --output=$@ $<
	$(info $@)

.PHONY: $(TARGET_EXT) clean help

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
