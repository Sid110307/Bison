%{
	#include <stdio.h>
	#include <string.h>

	#include "include/langFunctions.h"
	#include "include/validators.h"

	extern char data_Type[50];

	extern void error();
	extern int lex();
	extern char* text;
	extern int lineNo;

	void storeDataType(char*);
	int isDuplicate(char*, char*);
	void storeIdentifier(char*, char*);
	void duplicateIdentifierError(char*);
	char* retrieveDataType();
	void clearBuffers();
	int isValidAssignment(char*);
	void assignmentError(char*);
	char* extractIdentifier(char[]);

	int arrayIdentifierCount = 0;
	char extractedIdentifier[50][50];
%}

%define parse.lac full
%define parse.error verbose

%union {
	int intVal;
	char* dataType;
	char* strVal;
	float floatVal;
	char charVal;
}

%token SINGLE_QUOTES COMMA SEMICOLON EQUALS
%token OPEN_BRACKET CLOSE_BRACKET OPEN_CURLY_BRACE CLOSE_CURLY_BRACE OPEN_ARRAY CLOSE_ARRAY

%token <charVal> CHARACTER_VALUE
%token <intVal> INTEGER_VALUE
%token <floatVal> FLOAT_VALUE
%token <strVal> STRING_VALUE

%token <intVal> INT
%token <floatVal> FLOAT
%token <strVal> STRING
%token <dataType> DATA_TYPE
%token <strVal> IDENTIFIER ARRAY_IDENTIFIER
%token <strVal> STRUCT

%type <strVal> DECLARATION
%type <strVal> EXPRESSION
%type <strVal> FUNCTION_DECLARATION

%%

DECLARATION:
			EXPRESSION SEMICOLON { clearBuffers(); }
			|	FUNCTION_DECLARATION SEMICOLON
			|	STRUCT IDENTIFIER STRUCTURE_DEFINITION SEMICOLON
			|	STRUCT IDENTIFIER STRUCTURE_DEFINITION IDENTIFIER_LIST SEMICOLON
			|	DECLARATION EXPRESSION SEMICOLON { clearBuffers(); }
			|	DECLARATION FUNCTION_DECLARATION SEMICOLON
			|	DECLARATION STRUCT IDENTIFIER STRUCTURE_DEFINITION SEMICOLON
			|	DECLARATION STRUCT IDENTIFIER STRUCTURE_DEFINITION IDENTIFIER_LIST SEMICOLON
			|	error '>'
			;

EXPRESSION:
			IDENTIFIER ':' DATA_TYPE 												{
																						if (!isDuplicate($1, retrieveDataType())) {
																							storeIdentifier($1, retrieveDataType());
																							storeDataType($3);
																						}
																						else
																							duplicateIdentifierError($1);
										 											}
			|	EXPRESSION EQUALS NUMBER											{ ; }
			|	EXPRESSION COMMA IDENTIFIER											{
																						if (!isDuplicate($3, retrieveDataType()))
																							storeIdentifier($3, retrieveDataType());
																						else
																							duplicateIdentifierError($3);
																					}
			|	ARRAY_IDENTIFIER ':' DATA_TYPE										{
																						strcpy(extractedIdentifier[arrayIdentifierCount], extractIdentifier($1));
																						if (!isDuplicate(extractedIdentifier[arrayIdentifierCount], retrieveDataType())) {
																							storeIdentifier(extractedIdentifier[arrayIdentifierCount], retrieveDataType())
																							storeDataType($3)
																						}
																						else
																							duplicateIdentifierError(extractedIdentifier[arrayIdentifierCount]);
																						arrayIdentifierCount++;
																					}
			|	EXPRESSION EQUALS OPEN_CURLY_BRACE PARAM_LIST CLOSE_CURLY_BRACE
			|	EXPRESSION COMMA ARRAY_IDENTIFIER									{
																						strcpy(extractedIdentifier[arrayIdentifierCount], extractIdentifier($3));
																						if (!isDuplicate(extractedIdentifier[arrayIdentifierCount], retrieveDataType()))
																							storeIdentifier(extractedIdentifier[arrayIdentifierCount], retrieveDataType())
																						else
																							duplicateIdentifierError(extractedIdentifier[arrayIdentifierCount]);
																						arrayIdentifierCount++;
																					}
			|	error '>'
			;

NUMBER:
			INTEGER_VALUE															{ if (!isValidAssignment("int")) assignmentError(itoa($1)); }
			|	FLOAT_VALUE															{ if (!isValidAssignment("float")) assignmentError(ftoa($1)); }
			|	CHARACTER_VALUE														{ if (!isValidAssignment("char")) assignmentError(ctoa($1)); }
			|	STRING_VALUE														{ if (!isValidAssignment("char*")) assignmentError($1); }
			;

PARAM_LIST:
			NUMBER
			|	PARAM_LIST COMMA NUMBER
			|	NUMBER EQUALS NUMBER												{ error("Multiple assignments are not allowed."); }
			|	error '>'
			;

STRUCTURE_DEFINITION:
			OPEN_CURLY_BRACE DECLARATION CLOSE_CURLY_BRACE
			;

FUNCTION_DECLARATION:
			IDENTIFIER ':' DATA_TYPE OPEN_BRACKET DATA_TYPE_LIST CLOSE_BRACKET		{
																						if (!isDuplicate($1, retrieveDataType())) {
																							storeIdentifier($1, retrieveDataType());
																							storeDataType($3);
																						}
																						else
																							duplicateIdentifierError($1);
																					}
			;

IDENTIFIER_LIST:
			IDENTIFIER
			|	IDENTIFIER_LIST COMMA IDENTIFIER
			;

DATA_TYPE_LIST:
			DATA_TYPE
			|	DATA_TYPE_LIST COMMA DATA_TYPE
			;

%%

int main()
{
	printf("Compiling... ");
	parse();
	printf("Done.\n");
	return 0;
}