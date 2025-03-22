# https://github.com/FarManagerLegacy/HelpDown-scripts

# required user setting
BASE:=..
#PANDOC:=C:\Apps\pandoc\pandoc.exe
HTMLTOFARHELP:="$(FARPROFILE)\tools\HtmlToFarHelp\HtmlToFarHelp.exe"

# plug base Makefile
include $(BASE)/Makefile
.DEFAULT_GOAL:=README.md

# optional local customization
.PHONY: all post
all: hlf forum md

post: README.forum
	@env \
	  PASSWORD=$(shell KeePassCommand.cmd getfieldraw forum.farmanager.com Password) \
	  USERNAME="John Doe" \
	  POST_ID=177959 \
	  FILE="$<" \
	  CLEANUP=false \
	  $(BASE)/update_post.sh
