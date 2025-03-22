# https://github.com/FarManagerLegacy/HelpDown-scripts

# required user setting
BASE:=../..
#PANDOC:=C:\Apps\pandoc\pandoc.exe
HTMLTOFARHELP:="$(FARPROFILE)\tools\HtmlToFarHelp\HtmlToFarHelp.exe"
BASH:=sh.exe

# plug base Makefile
include $(BASE)/Makefile
.DEFAULT_GOAL:=hlf

# optional local customization

README.md: embed.md
	@echo $@
	@if exist $@ del $@
	@ren $< $@

.PHONY: all embed
all: README.md embed

embed: embed.lua embed.hlf
	@$(BASH) -c $(subst \,/,"$(BASE)/embed_hlf.sh $^") | unix2dos >_embed_.tmp
	@for %%a in ("_embed_.tmp") do if %%~za gtr 0 (del $<) else (exit /b 1)
	@ren _embed_.tmp $<
