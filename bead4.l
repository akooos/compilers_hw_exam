%option noyywrap c++ yylineno


%{
#include "Parserbase.h"
%}

AZON [a-z][_a-z0-9]*
INTEGER [1-9]*[0-9]+
WS  [ \t\n]
LINECOMMENT ^[*].*$

%%
"PROGRAM"     return Parser::PROGRAM;
"DATA"        return Parser::DATA;
"MOVE"	      return Parser::MOVE;
"TO"	      return Parser::TO;
"FROM"	      return Parser::FROM;
"TYPE"        return Parser::TYPE;
"WHILE"       return Parser::WHILE;

"FOR"         return Parser::FOR;
"IN"          return Parser::IN;
".."          return Parser::DOTDOT;
"ENDFOR"      return Parser::ENDFOR;

"READ"        return Parser::READ;
"IF"          return Parser::IF;
"ELSE"        return Parser::ELSE;
"ENDIF"       return Parser::ENDIF;
"ENDWHILE"    return Parser::ENDWHILE;
"WRITE"       return Parser::WRITE;
"BY"          return Parser::BY;
"ADD"         return Parser::ADD;
"SUBTRACT"    return Parser::SUBTRACT;
"DIVIDE"      return Parser::DIVIDE;
"MULTIPLY"    return Parser::MULTIPLY;
"MOD"         return Parser::MOD;
"I"           return Parser::I;
"B"           return Parser::B;
"TRUE"        return Parser::TRUE;
"FALSE"       return Parser::FALSE;
"AND"         return Parser::AND;
"OR"          return Parser::OR;
"NOT"         return Parser::NOT;
"("	      return Parser::OPENING_PARENTHESIS;
")"	      return Parser::CLOSING_PARENTHESIS;
"<"	      return Parser::LESSER;
">"	      return Parser::GREATER;
"="	      return Parser::EQUAL;
":"	      return Parser::COLON;
","	      return Parser::COMMA;
"."           return Parser::DOT;
{INTEGER}     return Parser::INTEGER;
{AZON}        return Parser::ID;
{LINECOMMENT} {}
{WS}+      { } 
.       {
                std::cerr << lineno() << ":Lexikalis hiba: " << YYText() << std::endl;
                exit(1);
            }

%%
