SRC = $(wildcard src/*.coffee)
LIB = $(SRC:src/%.coffee=lib/%.js)

lib: $(LIB)
lib/%.js: src/%.coffee
	./node_modules/.bin/coffee -bcps < $< > $@
