GIT_REMOTE = $(shell git remote)
GIT_URL = $(shell git remote get-url online)
GIT_HOST=$(shell git remote get-url online | sed -n -e 's/git@\(.*\):.*/\1/p')
KEEPMYWORK_GIT = $(firstword $(subst :, ,$(GIT_URL))):keepmywork
