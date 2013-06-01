COFFEE=coffee

all: lib/polygons.js

lib/polygons.js: src/polygons.coffee
	$(COFFEE) -c -o lib src/polygons.coffee
		
clean:
	$(RM) lib/polygons.js

.PHONY: all clean
