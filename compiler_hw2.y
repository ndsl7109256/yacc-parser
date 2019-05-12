/*	Definition section */
%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

extern int yylineno;
extern int yylex();
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex

/* Symbol table function - you can add new function if needed. */
int lookup_symbol();
void create_symbol();
void insert_symbol();
void dump_symbol();

typedef struct{
	char *id;
	char *type;
	double data;
} Table;
Table table[100];

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
    | declaration 
;

function_definition
	: declaration_specifiers declarator declaration_list compound_stat
	| declaration_specifiers declarator compound_stat
    | declarator declaration_list compound_stat
	| declarator compound_stat
;

declaration
	: declaration_specifiers SEMICOLON
	| declaration_specifiers init_declarator_list SEMICOLON
	;

declaration_specifiers
	: type_specifier
	| type_specifier declaration_specifiers
	;



init_declarator_list
	: init_declarator
	| init_declarator_list COMMA init_declarator
	;

init_declarator
	: declarator
	| declarator ASGN initializer
	;

declarator
	: direct_declarator
	;

direct_declarator
	: ID
	| LB declarator RB
	| direct_declarator LB parameter_list RB
	| direct_declarator LB RB
	| direct_declarator LB identifier_list RB
	;

parameter_list
	: parameter_declaration
	| parameter_list COMMA parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
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
	: VOID
    | INT
    | FLOAT
	| STRING
	| BOOL
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
    |PRINT LB STR_CONST RB SEMICOLON {printf("88");}
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
    yylineno = 0;
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

void create_symbol() {}
void insert_symbol() {}
int lookup_symbol() {}
void dump_symbol() {
    printf("\n%-10s%-10s%-12s%-10s%-10s%-10s\n\n",
           "Index", "Name", "Kind", "Type", "Scope", "Attribute");
}
