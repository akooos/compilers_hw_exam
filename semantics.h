#ifndef SEMANTICS_H
#define SEMANTICS_H
/* 1. Include ezeket: */
#include <iostream>//std in/out miatt
#include <sstream>//szám stringé konvertálása miatt kell
#include <string>//szimbólumtábla kulcsai sztringek lesznek
#include <map>//map-ben tároljuk a szimbólumtáblát
#include <cstdlib>
/*-----*/

/* 2. Nyelvben előforduló típusok reprezentálása: */
enum Type{ integer, boolean };
/* 3. Az egyes változókhoz hozzárendelt adatok tárolására fogjuk használni. */
struct VariableData{
	unsigned decl_row; /* azt fogja tárolni, hogy az adott változó a program hányadik sorában volt deklarálva. */
	Type     type;     /* a változó típusát tárolja */
	VariableData(){}
	VariableData(unsigned decl_row, Type type):decl_row(decl_row), type(type) {}
};
struct Desc {
    int         row;
    std::string code;
    Desc(int row, const std::string &code):row(row),code(code){}
};
struct ExprDesc : Desc
{
    Type        type;
    ExprDesc( int row, Type type, const std::string &code ):Desc(row,code), type(type) {}
};

typedef Desc InstDesc;
typedef std::string VariableName;
/*A map kulcsa a változó neve (string) lesz, a hozzárendelt érték pedig tartalmazni fogja a változó típusát és a deklarációjának sorát*/
typedef std::map<VariableName,VariableData> SymbolsTable; 

#endif //SEMANTICS_H
