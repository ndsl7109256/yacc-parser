/*	Definition section */
%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

extern int yylineno;
extern int yylex();
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex

/* Symbol table function - you can add new function if needed. */
int lookup_symbol();
void create_symbol();
void insert_symbol();
void dump_symbol();
void test(char *type,char *name);

typedef struct{
	int Index;
	char *Name;
	char *kind;
	char *type;
	int Scope;
	char Attribute[50][50];
	int AttriCount;
} Table;
Table global[50];
int globalCount = 0;
Table table[50];
int tableCount = 0;

%}

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    double f_val;
    char* string;
}

/* Token without return */
%token ADD SUB MUL DIV MOD
%token INC DEC

%token NE EQ LTE MTE LT MT

%token ASGN ADDASGN SUBASGN MULASGN DIVASGN MODASGN

%token AND OR NOT

%token LB RB  LSB RSB LCB RCB COMMA QUOTA

%token PRINT 

%token IF ELSE FOR WHILE BREAK CONT

%token VOID INT FLOAT BOOL

%token TRUE FALSE

%token RET

%token SEMICOLON
%token ID

%token STRING

/* Token with return, which need to sepcify type */
%token <i_val> I_CONST
%token <f_val> F_CONST
%token <string> STR_CONST


/* Nonterminal with return, which need to sepcify type */
//%type <f_val> stat
%type <string> INT
%type <string> FLOAT
%type <string> BOOL
%type <string> STRING
%type <string> VOID
%type <string> ID

%type <string> type_specifier
%type <string> declaration_specifiers
%type <string> init_declarator_list
%type <string> init_declarator
%type <string> declarator
%type <string> direct_declarator

/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : program external_declaration
    | external_declaration
;

external_declaration
    : function_definition {printf("\nOMMMMMMMMMMMMMMMMMMMMMM");}
    | declaration {printf("\nccccccccccccccccccccc");} 
;

function_definition
	: declaration_specifiers declarator declaration_list compound_stat	
	| declaration_specifiers declarator compound_stat	{/*"function end"*/;}
    	| declarator declaration_list compound_stat
	| declarator compound_stat
;

declaration
	: declaration_specifiers SEMICOLON
	| declaration_specifiers init_declarator_list SEMICOLON {test($1,$2);}
	;

declaration_specifiers
	: type_specifier  {$$ = $1; printf("||  %s  ||",$1);}
      /*| type_specifier declaration_specifiers {printf("bb%sbb",$1);}*/
	/* multiple type? */
	;



init_declarator_list
	: init_declarator { $$ = $1; }
	| init_declarator_list COMMA init_declarator 
	;

init_declarator
	: declarator { $$ = $1; }
	| declarator ASGN initializer { $$ = $1; }
	;

declarator
	: direct_declarator { $$ =$1; }
	;

direct_declarator
	: ID { $$ = strdup(yytext); }
	| LB declarator RB 
	| direct_declarator LB parameter_list RB {/*printf("function with NO attribute");*/}
	| direct_declarator LB RB {/*printf("function with attribute");*/}
	| direct_declarator LB identifier_list RB 
	;

parameter_list
	: parameter_declaration {/*printf("123");*/}
	| parameter_list COMMA parameter_declaration {/*printf("para end");*/}
	;

parameter_declaration
	: declaration_specifiers declarator {/*printf("this");*/}
	| declaration_specifiers
	;

identifier_list
	: ID
	| identifier_list COMMA ID
	;

initializer_list
	: initializer
	| initializer_list COMMA initializer 
	;

initializer
	: assignment_expression
	| LCB initializer_list RCB
	| LCB initializer_list COMMA RCB 
	;



declaration_list
	: declaration
	| declaration_list declaration
	;


/* actions can be taken when meet the token or rule */

type_specifier
	: VOID   {$$ = "void";}
	| INT	 {$$ = "int";}
	| FLOAT  {$$ = "float";}
	| STRING {$$ = "string";}
	| BOOL   {$$ = "bool";}
	;

/*compound_stat*/
compound_stat
    	: LCB RCB
	| LCB  block_item_list RCB
	;

block_item_list
    : block_item_list block_item
    | block_item
;

block_item
    : declaration
    | stat
;

declaration
	: declaration_specifiers SEMICOLON
	| declaration_specifiers init_declarator_list SEMICOLON
	;

stat
    : print_stat
    | expression_stat
    | selection_stat
    | iteration_stat
    | compound_stat
    | jump_stat
    | function_stat
;
/*expression_stat*/



/*print_func*/
print_stat
    :PRINT LB ID RB SEMICOLON
    |PRINT LB STR_CONST RB SEMICOLON    
;

expression_stat
    : COMMA
    | expression SEMICOLON
;

expression
    : assignment_expression
    | expression COMMA assignment_expression
;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
;

conditional_expression
	: logical_or_expression
;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR logical_and_expression
;

logical_and_expression
	: equality_expression
	| logical_and_expression AND equality_expression
;

equality_expression
	: relational_expression
	| equality_expression EQ relational_expression
	| equality_expression NE relational_expression
;

relational_expression
	: additive_expression
	| relational_expression LT additive_expression
	| relational_expression MT additive_expression
	| relational_expression LTE additive_expression
	| relational_expression MTE additive_expression
;


additive_expression
	: multiplicative_expression
	| additive_expression ADD multiplicative_expression
	| additive_expression SUB multiplicative_expression
;

multiplicative_expression
	: cast_expression
	| multiplicative_expression MUL cast_expression
	| multiplicative_expression DIV cast_expression
	| multiplicative_expression MOD cast_expression
;

cast_expression
	: unary_expression
;

unary_expression
    : postfix_expression
    | INC unary_expression
    | DEC unary_expression
    | unary_operator cast_expression
;

assignment_operator
	: ASGN
	| MULASGN
	| DIVASGN
	| MODASGN
	| ADDASGN
	| SUBASGN
;

unary_operator
	: '&'
	| MUL
	| ADD
	| SUB
	| '~'
	| NOT
	;

postfix_expression
    : primary_expression
    | postfix_expression INC
    | postfix_expression DEC
;

primary_expression
    : ID
    | constant
    | TRUE
    | FALSE
    | STR_CONST
    | LB expression RB
;

constant
    : I_CONST    
    | F_CONST    
;

selection_stat
    : IF LB expression RB stat ELSE stat 
	| IF LB expression RB stat
	;
iteration_stat
	: WHILE LB expression RB stat


jump_stat
	: CONT SEMICOLON
	| BREAK SEMICOLON
	| RET SEMICOLON
	| RET expression SEMICOLON
	;
function_stat
    : ID LB function_para RB SEMICOLON

function_para
    : function_para COMMA primary_expression
    | primary_expression

%%

/* C code section */
int main(int argc, char** argv)
{
    yylineno = 1;
    printf("1: ");
    yyparse();
	printf("\nTotal lines: %d \n",yylineno);

    return 0;
}

void yyerror(char *s)
{
    printf("\n|-----------------------------------------------|\n");
    printf("| Error found in line %d: %s\n", yylineno, buf);
    printf("| %s", s);
    printf("\n|-----------------------------------------------|\n\n");
}

void create_symbol() {
	tableCount = 0;	
}
void insert_symbol(int index,char *name,char *kind,char *type,int scope) {}
int lookup_symbol() {}
void dump_symbol() {
    printf("\n%-10s%-10s%-12s%-10s%-10s%-10s\n\n",
           "Index", "Name", "Kind", "Type", "Scope", "Attribute");
}

void test(char *type,char *name){
	printf("\n%s   :   %s\n",type,name);
}
