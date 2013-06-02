COFFEE=coffee
DOCCO=docco -l linear

all: lib/polygons.js docs/polygons.html

lib/polygons.js: src/polygons.coffee
	$(COFFEE) -c -o lib src/polygons.coffee

docs/polygons.html: src/polygons.coffee
	$(DOCCO) src/polygons.coffee
		
clean:
	$(RM) lib/polygons.js
	$(RM) -r docs

.PHONY: all clean
