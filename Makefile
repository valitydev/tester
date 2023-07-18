MIX := MIX_HOME=$(shell pwd)/.mix $(shell which mix 2>/dev/null || which ./mix)
SUBMODULES = build_utils
SUBTARGETS = $(patsubst %,%/.git,$(SUBMODULES))

COMPOSE_HTTP_TIMEOUT := 300
export COMPOSE_HTTP_TIMEOUT

UTILS_PATH := build_utils
TEMPLATES_PATH := .

# Name of the service
SERVICE_NAME := test-transaction
# Service image default tag
SERVICE_IMAGE_TAG ?= $(shell git rev-parse HEAD)
# The tag for service image to be pushed with
SERVICE_IMAGE_PUSH_TAG ?= $(SERVICE_IMAGE_TAG)

# Base image for the service
BASE_IMAGE_NAME := service-erlang
BASE_IMAGE_TAG := 51bd5f25d00cbf75616e2d672601dfe7351dcaa4

BUILD_IMAGE_NAME := build-erlang
BUILD_IMAGE_TAG := 61a001bbb48128895735a3ac35b0858484fdb2eb

CALL_ANYWHERE := \
	submodules \
	all mix_deps compile escript dialyze format check_format test \
	start release clean distclean

CALL_W_CONTAINER := $(CALL_ANYWHERE)

.PHONY: $(CALL_W_CONTAINER) all

all: compile

-include $(UTILS_PATH)/make_lib/utils_container.mk
-include $(UTILS_PATH)/make_lib/utils_image.mk

$(SUBTARGETS): %/.git: %
	git submodule update --init $<
	touch $@

submodules: $(SUBTARGETS)

mix_hex:
	$(MIX) local.hex --force

mix_rebar:
	$(MIX) local.rebar rebar3 $(shell which rebar3) --force

mix_support: mix_hex mix_rebar

mix_deps: mix_support
	$(MIX) do deps.get, deps.compile

compile: submodules
	$(MIX) compile

start: submodules
	$(MIX) run

release: submodules distclean
	MIX_ENV=prod $(MIX) release

escript: submodules distclean
	MIX_ENV=escript $(MIX) escript.build

clean:
	$(MIX) clean
	rm -rf _build .mix

distclean:
	$(MIX) clean -a
	rm -rf _build

test: submodules
	MIX_ENV=test $(MIX) test

dialyze: submodules
	$(MIX) dialyzer

check_format: submodules
	$(MIX) format --check-formatted

format: submodules
	$(MIX) format
