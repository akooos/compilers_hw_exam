all: clean flex bisoncpp bead4
bead4: bead4.cc lex.yy.cc parse.cc Parser.ih Parser.h
	g++ -obead4 bead4.cc parse.cc lex.yy.cc  

flex: bead4.l
	flex bead4.l
bisoncpp: bead4.y
	bisonc++ bead4.y
clean:
	rm -rf lex.yy.cc Parserbase.h parse.cc bead4 *~ tesztfajlok/*.o tesztfajlok/*.asm tesztfajlok/*.out

