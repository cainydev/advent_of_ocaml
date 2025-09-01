# Use .PHONY to tell Make that these are command names, not files.
.PHONY: run build clean

# The default command to run when you just type "make"
all: run

# Command to build the project
build:
	@dune build

# Command to run the interactive application
# This depends on `build`, so it will automatically build first if needed.
run: build
	@./_build/default/bin/main.exe $(filter-out $@,$(MAKECMDGOALS))

day: build
	@./_build/default/bin/gen_day.exe $(filter-out $@,$(MAKECMDGOALS))


# A standard command to clean up build artifacts
clean:
	dune clean

%:
	@:
