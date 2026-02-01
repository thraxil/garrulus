.PHONY: all deps format test server setup

all: deps format test

deps:
	mix deps.get

format:
	mix format

test:
	mix test

server:
	mix phx.server

setup: deps
	mix ecto.setup
