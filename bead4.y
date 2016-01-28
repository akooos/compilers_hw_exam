%baseclass-preinclude "semantics.h"
%lsp-needed


%token PROGRAM;
%token DATA;
%token MOVE;
%token TO;
%token FROM;
%token TYPE;
%token WHILE;
%token READ;
%token IF;
%token ELSE;
%token ENDIF;
%token ENDWHILE;
%token WRITE;
%token BY;
%token ADD;
%token SUBTRACT;
%token DIVIDE;
%token MULTIPLY;
%token MOD;
%token I;
%token B;
%token TRUE;
%token FALSE;
%token NOT;
%token OPENING_PARENTHESIS;
%token CLOSING_PARENTHESIS;
%token COLON;
%token COMMA;
%token DOT;

%token DOTDOT;
%token FOR;
%token IN;
%token ENDFOR;

%token <szoveg> INTEGER;
%token <szoveg> ID;

%left OR
%left AND
%left EQUAL
%left LESSER GREATER
%type <ed> expr
%type <id> pg_decl
%type <id> decl_sect
%type <id> decl

%type <id> pg_insts
%type <id> inst
%type <id> conditional_inst
%type <id> loop_inst 
%type <id> for_inst 
%type <id> move_inst 
%type <id> read_inst 
%type <id> write_inst 
%type <id> add_inst
%type <id> sub_inst
%type <id> mod_inst
%type <id> div_inst
%type <id> mul_inst

%union{
	InstDesc *id; 
	ExprDesc    *ed;
	std::string *szoveg;
}

%%

start:
PROGRAM ID DOT pg_decl pg_insts{
	std::cerr << "start -> pg_head pg_decl pg_insts" << std::endl;
	std::cout   << "extern be_egesz" << std::endl
		<< "extern ki_egesz" << std::endl
		<< "extern be_logikai" << std::endl
		<< "extern ki_logikai" << std::endl
		<< "global main" << std::endl << std::endl
		<< "section .bss" << std::endl
		<< $4->code 
		<< "section .text" << std::endl
		<< "main:" << std::endl
		<< $5->code
		<< "ret" << std::endl;
	delete $2;
	delete $4;
	delete $5;

}| PROGRAM ID DOT pg_decl{
	std::cerr << "start -> pg_head pg_decl" << std::endl;
	std::cout   << "extern be_egesz" << std::endl
		<< "extern ki_egesz" << std::endl
		<< "extern be_logikai" << std::endl
		<< "extern ki_logikai" << std::endl
		<< "global main" << std::endl << std::endl
		<< "section .bss" << std::endl
		<< $4->code
		<< "section .text" << std::endl
		<< "main:" << std::endl

		<< "ret" << std::endl;
	delete $2;
	delete $4;
};
//program deklarációs rész
pg_decl:
DATA COLON decl_sect DOT{
	std::cerr << "pg_decl -> DATA COLON decl_sect DOT" << std::endl;
	std::string code = $3->code;
	$$ = new InstDesc(d_loc__.first_line,code);
	delete $3;
}| /*üres*/{
	std::cerr << "pg_decl -> EPSZILON(EMPTY) " << std::endl;
	$$ = new InstDesc(d_loc__.first_line,"");
};
//deklaráció szekció
decl_sect:
decl{
	std::cerr << "decl_sect -> decl " << std::endl;
	std::string code = $1->code;
	$$ = new InstDesc(d_loc__.first_line,code);
	delete $1;
}|
decl COMMA decl_sect{
	std::cerr << "decl_sect -> decl COMMA decl_sect" << std::endl;
	std::string code = $1->code + $3->code;
	$$ = new InstDesc(d_loc__.first_line,code);
	delete $1;
	delete $3;
};
//deklaráció
decl: 
ID TYPE I{

	std::cerr << "decl -> ID TYPE I " << std::endl;

	if ( isDeclared(*$1) )
	{
		errorRedeclaredVar(*$1);
	} else{
		tblSymbols[*$1] = VariableData( d_loc__.first_line, integer );	
		std::cerr << "DECLARED VARIABLE:" << *$1 << std::endl;
		std::string code = *$1 + ": resd 1\n";
		$$ = new InstDesc(d_loc__.first_line,code);
	}
	delete $1;
}|
ID TYPE B{

	std::cerr << "decl -> ID TYPE B " << std::endl;

	if ( isDeclared(*$1) )
	{
		errorRedeclaredVar(*$1);
	} else{
		tblSymbols[*$1] = VariableData( d_loc__.first_line, boolean );	
		std::cerr << "DECLARED VARIABLE:" << *$1 << std::endl;
		std::string code = *$1 + ": resb 1\n";
		$$ = new InstDesc(d_loc__.first_line,code);
	}
	delete $1;
};
pg_insts:
inst DOT {
	std::cerr << "pg_insts -> inst DOT " << std::endl;
	$$ = new InstDesc(d_loc__.first_line,$1->code);
	delete $1;
}|
inst DOT pg_insts{
	std::cerr << "pg_insts -> inst DOT pg_insts" << std::endl;
	$$ = new InstDesc(d_loc__.first_line,$1->code + $3->code);
	delete $1;
	delete $3;
};
//instrukciók
inst: conditional_inst{
	      $$ = $1;
      }| loop_inst{
	      $$ = $1;
      }| move_inst{
	      $$ = $1;
      }| read_inst{
	      $$ = $1;
      }| write_inst{
	      $$ = $1;
      }| add_inst{
	      $$ = $1;
      }| sub_inst{
	      $$ = $1;
      }| mod_inst{
	      $$ = $1;
      }| div_inst{
	      $$ = $1;
      }| mul_inst{
	      $$ = $1;
      }| for_inst{
	      $$ = $1;

      };
//Értékadás instrukció
move_inst:
MOVE expr TO ID{

	std::cerr << "move_inst -> MOVE expr TO ID" << std::endl;

	if ( isDeclared(*$4)  ){
		if ( $2->type != tblSymbols[*$4].type ){
			errorMismatchTypesInExpression();
		}else {
			std::string code = $2->code + "mov [" + *$4 + "],eax\n";
			$$ = new InstDesc(d_loc__.first_line,code); 
		}

	}else{
		errorVarNotDeclared(*$4);  
	}

	delete $2;
	delete $4;
};
//While ciklus
loop_inst:
WHILE expr DOT pg_insts ENDWHILE{

	std::cerr << "loop_inst -> WHILE expr DOT pg_insts ENDWHILE" << std::endl;

	if ( $2->type != boolean ){
		errorLogicalExpExpected();
	} else{
		std::stringstream out1;
		out1 << "label" << getSorszam();
		std::string eleje = out1.str();
		std::stringstream out2;
		out2 << "label" << getSorszam();
		std::string mag = out2.str();
		std::stringstream out3;
		out3 << "label" << getSorszam();
		std::string end = out3.str();
		$$ = new InstDesc( $2->row, eleje + ":\n" + $2->code
				+ "cmp al,1\nje " + mag + "\njmp " + end + "\n"
				+ mag + ":\n" + $4->code
				+ "jmp " + eleje + "\n"
				+ end + ":\n" );    
	}

	delete $2;
	delete $4;
};
//FOR ciklus
for_inst:
FOR ID IN INTEGER DOTDOT INTEGER DOT pg_insts ENDFOR{

	std::cerr << "for_inst -> FOR ID IN NUMBER DOTDOT pg_insts ENDFOR" << std::endl;

	if ( isDeclared(*$2) ){

		if (tblSymbols[*$2].type != integer ){
			errorNumberIdentifierExpected();
		} else{
			std::stringstream out1;
			out1 << "label" << getSorszam();
			std::string eleje = out1.str();
			std::stringstream out2;
			out2 << "label" << getSorszam();
			std::string mag = out2.str();
			std::stringstream out3;
			out3 << "label" << getSorszam();
			std::string end = out3.str();
			$$ = new InstDesc( $8->row,"mov dword["+*$2+"],"+*$4+"\n"  
					+ eleje + ":\nmov eax, dword[" + *$2 + "]\n"
					+ "mov ebx," + *$6 +"\n"
					+ "inc ebx\n"					
					+ "cmp eax,ebx\njne " + mag + "\njmp " + end + "\n"
					+ mag + ":\n" + $8->code
					+ "inc dword[" + *$2+ "]\njmp " + eleje + "\n"
					+ end + ":\n" );    
		}
	} else{
		errorVarNotDeclared(*$2);
	}

        delete $4;
        delete $6;
	delete $2;
	delete $8;
};

//Egyszerű elágazás
conditional_inst:
IF expr DOT pg_insts ENDIF {

	std::cerr << "conditional_inst -> IF expr DOT pg_insts ENDIF" << std::endl;

	if ( $2->type != boolean ){
		errorLogicalExpExpected();
	}else{
		std::stringstream out1;
		out1 << "label" << getSorszam();
		std::string then = out1.str();
		std::stringstream out2;
		out2 << "label" << getSorszam();
		std::string end = out2.str();
		$$ = new InstDesc( $2->row,$2->code + "cmp al,1\nje " + then + "\n"
				+ "jmp " + end + "\n"
				+ then + ":\n"
				+ $4->code
				+ end + ":\n" ); 
	}

	delete $2;
	delete $4;

}|
IF expr DOT pg_insts ELSE DOT pg_insts ENDIF{

	std::cerr << "IF expr DOT pg_insts ELSE DOT pg_insts ENDIF" << std::endl;

	if ( $2->type != boolean ){
		errorLogicalExpExpected();
	}else{
		std::stringstream out1;

		out1 << "label" << getSorszam();
		std::string then = out1.str();
		std::stringstream out2;
		out2 << "label" << getSorszam();
		std::string elsec = out2.str();
		std::stringstream out3;
		out3 << "label" << getSorszam();
		std::string end = out3.str();
		$$ = new InstDesc( $2->row, $2->code + "cmp al,1\nje " + then + "\n"
				+ "jmp " + elsec + "\n"
				+ then + ":\n"
				+ $4->code
				+ "jmp " + end + "\n"
				+ elsec + ":\n"
				+ $7->code
				+ end + ":\n" ); 
	}

	delete $2;
	delete $4;
	delete $7;
};
//olvasás stdin-ről instrukció
read_inst:
READ TO ID{

	std::cerr << "read_inst -> READ TO ID" << std::endl;

	if ( !isDeclared(*$3) ){
		errorVarNotDeclared(*$3);
	} else{
		std::string func, reg;
		if( tblSymbols[*$3].type == integer )
		{
			func = "be_egesz";
			reg  = "eax";
		}else{
			func = "be_logikai";
			reg = "al";
		}
		$$ = new InstDesc( d_loc__.first_line, "call " + func + "\nmov [" + *$3 + "]," + reg + "\n" ); 
	}

	delete $3;
};
//kiírás stdout-ra instrukció
write_inst:
WRITE expr{
	std::cerr << "write_inst -> WRITE expr" << std::endl;
	std::string func;

	if( $2->type == integer )
		func = "ki_egesz";
	else
		func = "ki_logikai";

	$$ = new InstDesc( d_loc__.first_line, $2->code + "push eax\ncall " + func + "\nadd esp,4\n" );
	delete $2;
};
//hozzáadás instrukció
add_inst:
ADD expr TO ID{
	if ( isDeclared(*$4) ){
		if ( $2->type != integer || $2->type != tblSymbols[*$4].type ){
			errorMismatchTypesInExpression();
		}else{

			std::string code = "mov eax,["+*$4+"]\npush eax\n" + $2->code + "pop ebx\nadd eax,ebx\nmov ["+*$4 +"],eax\n";
			$$ = new ExprDesc( d_loc__.first_line,integer,code);
		}

	}else{
		errorVarNotDeclared(*$4);           
	}

	delete $2;
	delete $4;
};
//kivonás instrukció
sub_inst:
SUBTRACT expr FROM ID{

	std::cerr << "sub_inst -> SUBTRACT expr FROM ID" << std::endl;

	if ( isDeclared(*$4) ){
		if ( $2->type != tblSymbols[*$4].type || $2->type != integer ){
			errorMismatchTypesInExpression();
		}else{

			std::string code = $2->code + "push eax\nmov eax,["+*$4+"]\n" + "pop ebx\nsub eax,ebx\nmov ["+*$4 +"],eax\n";
			$$ = new ExprDesc( d_loc__.first_line,integer,code);
		}

	}else{
		errorVarNotDeclared(*$4);           
	}

	delete $2;
	delete $4;

};
//multiplikatív instrukció
mul_inst:
MULTIPLY ID BY expr{

	std::cerr << "mul_inst -> MULTIPLY ID BY expr" << std::endl;

	if ( isDeclared(*$2) ){

		if ( $4->type != tblSymbols[*$2].type ){
			errorMismatchTypesInExpression();
		}else{

			std::string code = $4->code + "push eax\nmov eax,[" + *$2 +"]\npop ebx\nmul ebx\nmov ["+*$2+"], eax\n";
			$$ = new ExprDesc( d_loc__.first_line,integer,code);
		}

	}else{
		errorVarNotDeclared(*$2);   
	}

	delete $2;
	delete $4;

};
//osztás instrukció
div_inst:
DIVIDE ID BY expr{

	std::cerr << "div_inst -> DIVIDE ID BY expr" << std::endl;

	if ( isDeclared(*$2) ){

		if ( $4->type != tblSymbols[*$2].type || $4->type != integer ){
			errorMismatchTypesInExpression();
		}else{

			std::string code = $4->code + "push eax\nmov eax,[" + *$2 + "]\npop ebx\ndiv ebx\nmov ["+*$2+"],eax\n";
			$$ = new ExprDesc( d_loc__.first_line,integer,code);
		}

	}else{
		errorVarNotDeclared(*$2);      
	}

	delete $2;
	delete $4;
};
//modulo instrukció
mod_inst:
MOD ID BY expr TO ID{

	std::cerr << "mod_inst -> MOD ID BY expr TO ID" << std::endl;

	if ( isDeclared(*$2) ){

		if ( isDeclared(*$6) ){

			if ( $4->type != integer || $4->type != tblSymbols[*$2].type || $4->type != tblSymbols[*$6].type ){
				errorMismatchTypesInExpression();
			} else{
				std::string code = $4->code + "push eax\nmov eax,["+ *$2 + "]\npop ebx\nmov edx,0\ndiv ebx\nmov ["+*$6+"],edx\n";
				$$ = new ExprDesc( d_loc__.first_line,integer,code);
			}

		}else 
			errorVarNotDeclared(*$6);
	}else
		errorVarNotDeclared(*$2);

	delete $2;
	delete $4;
	delete $6;
};
//logika kifejezes
expr:   
ID{
	std::cerr << "expr -> ID" << std::endl;
	if ( !isDeclared(*$1) ){
		errorVarNotDeclared(*$1);
	}else{
		std::string code = "mov eax,[" + *$1 + "]\n";
		$$ = new ExprDesc( d_loc__.first_line, tblSymbols[*$1].type,code);
	}
	delete $1;

}|
INTEGER{
	std::cerr << "expr -> INTEGER" << std::endl;
	std::string code = "mov eax," + *$1 + "\n";
	$$ = new ExprDesc( d_loc__.first_line,integer,code);
	delete $1;
}| 
TRUE{
	std::cerr << "expr -> TRUE" << std::endl;
	std::string code = "mov eax,1\n";
	$$ = new ExprDesc( d_loc__.first_line,boolean,code);
}|     
FALSE {
	std::cerr << "expr -> FALSE" << std::endl;
	std::string code = "xor eax,eax\n";
	$$ = new ExprDesc( d_loc__.first_line,boolean,code);
}|     
expr OR expr{
	std::cerr << "expr -> expr OR expr" << std::endl;
	if ( $1->type != boolean || $3->type != boolean ){
		errorMismatchTypesInExpression();
	} else{
		std::string code = $3->code + "push eax\n" + $1->code + "pop ebx\nor al,bl\n";
		$$ = new ExprDesc( d_loc__.first_line,boolean,code);
	}
	delete $1;
	delete $3;
}| 
expr AND expr{
	std::cerr << "expr -> expr AND expr" << std::endl;
	if ( $1->type != boolean || $3->type != boolean ){
		errorMismatchTypesInExpression();
	}else {
		std::string code = $3->code + "push eax\n" + $1->code + "pop ebx\nand al,bl\n";
		$$ = new ExprDesc( d_loc__.first_line,boolean,code);
	}
	delete $1;
	delete $3;
}|
NOT expr{
	std::cerr << "expr -> NOT expr" << std::endl;
	if ( $2->type != boolean ){
		errorMismatchTypesInExpression();
	}else{
		std::string code = $2->code + "xor al,1\n";
		$$ = new ExprDesc( d_loc__.first_line,boolean,code);
	}
	delete $2;
}|    
expr EQUAL expr{
	std::cerr << "expr -> expr EQUAL expr" << std::endl;
	if ( $1->type != $3->type ){
		errorMismatchTypesInExpression();
	}else{
		std::string code;
		std::stringstream out;
		out << "label" << getSorszam();
		std::string label = out.str();
		std::string r1,r2;
		if( $1->type == integer )
		{
			r1 = "eax";
			r2 = "ebx";
		}
		else
		{
			r1 = "al";
			r2 = "bl";
		}
		code = $3->code + "push eax\n" + $1->code + "pop ebx\n" + "cmp " + r1 + "," + r2 + "\n"
			+ "mov al,1\nje " + label + "\nmov al,0\n"
			+ label + ":\n" ;

		$$ = new ExprDesc( d_loc__.first_line,boolean,code);

	}

	delete $1;
	delete $3;
}|    
expr LESSER expr{

	std::cerr << "expr -> expr LESSER expr" << std::endl;

	if ( $1->type != $3->type || $1->type != integer ){
		errorMismatchTypesInExpression();
	}else {

		std::stringstream out;
		out << "label" << getSorszam();
		std::string label = out.str();
		$$ = new ExprDesc( d_loc__.first_line, boolean , $3->code
				+ "push eax\n" + $1->code + "pop ebx\ncmp eax,ebx\nmov al,1\n"
				+ "jb " + label + "\nmov al,0\n"
				+ label + ":\n" );
	}

	delete $1;
	delete $3;

}|
expr GREATER expr{

	std::cerr << "expr -> expr GREATER expr" << std::endl;

	if ( $1->type != integer || $3->type != integer ){
		errorMismatchTypesInExpression();
	}else{
		std::stringstream out;
		out << "label" << getSorszam();
		std::string label = out.str();
		$$ = new ExprDesc( d_loc__.first_line, boolean
				, $3->code
				+ "push eax\n"
				+ $1->code
				+ "pop ebx\n"
				+ "cmp eax,ebx\n"
				+ "mov al,1\n"
				+ "ja " + label + "\n"
				+ "mov al,0\n"
				+ label + ":\n" );

	}

	delete $1;
	delete $3;
}|
OPENING_PARENTHESIS expr CLOSING_PARENTHESIS{
	std::cerr << "expr -> OPENING_PARENTHESIS expr CLOSING_PARENTHESIS" << std::endl;
	$$ = $2;
};

