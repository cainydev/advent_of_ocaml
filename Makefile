.PHONY: run build clean

all: run

build:
	@dune build

run: build
	@./_build/default/bin/main.exe $(filter-out $@,$(MAKECMDGOALS))

day: build
	@./_build/default/bin/gen_day.exe $(filter-out $@,$(MAKECMDGOALS))


clean:
	dune clean

%:
	@:
