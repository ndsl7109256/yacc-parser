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

%token AND OR NOt

%token LB RB  LSB RSB LCB RCB COMMA

%token PRINT 

%token IF ELSE FOR WHILE

%token VOID INT FLOAT BOOL

%token TRUE FALSE

%token RET

%token SEMICOLON
%token ID

/* Token with return, which need to sepcify type */
%token <i_val> I_CONST
%token <f_val> F_CONST
%token <string> STRING


/* Nonterminal with return, which need to sepcify type */
%type <f_val> stat
%type <string> type
%type <string> INT
%type <string> FLOAT
%type <string> BOOL
%type <string> VOID
%type <string> ID

/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : 
    |
;

stat
    : declaration
    | compound_stat
    | expression_stat
    | print_func
;

declaration
    : type ID '=' initializer SEMICOLON
    | type ID SEMICOLON
;

/* actions can be taken when meet the token or rule */
type
    : INT { $$ = $1; }
    | FLOAT { $$ = $1; }
    | BOOL  { $$ = $1; }
    | STRING { $$ = $1; }
    | VOID { $$ = $1; }
;

initializer:

;
/*compound_stat*/
compound_stat
    :

;


/*expression_stat*/
expression_stat
    :

;



/*print_func*/
print_func
    :PRINT LB ID RB SEMICOLON
    |PRINT LB STRING RB SEMICOLON
;
%%

/* C code section */
int main(int argc, char** argv)
{
    yylineno = 0;

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
