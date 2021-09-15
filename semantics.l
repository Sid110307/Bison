%{
	#include <string.h>
	#include <stdlib.h>
	#include "y.tab.h"
	void extern error(char*);
	void invalidToken();
%}

%%

"void"								|
"int"								|
"char"								|
"float"								|
"unsigned int"						|
"unsigned char"						|
"void*"								|
"int*"								|
"char*"								|
"float*"							{ lexerVal.dataType = strdup(text); return DATA_TYPE; }

"struct"							{ lexerVal.dataType = strdup(text); return STRUCT; }

"'"									{ return SINGLE_QUOTES; }
","									{ return COMMA; }
";"									{ return SEMICOLON; }
"="									{ return EQUALS; }
"("									{ return OPEN_BRACKET; }
")"									{ return CLOSE_BRACKET; }
"{"									{ return OPEN_CURLY_BRACE; }
"}"									{ return CLOSE_CURLY_BRACE; }
"["									{ return OPEN_ARRAY; }
"]"									{ return CLOSE_ARRAY; }

[\'][a-A-Z][\']						{ lexerVal.charVal = text[1]; return CHARACTER_VALUE; }
[-+]?[0-9]+							{ lexerVal.intVal = atoi(text); return INTEGER_VALUE; }
[-+]?[0-9]+*\.?[0-9]+				{ lexerVal.floatVal = atof(text); return FLOAT_VALUE; }

[a-zA-Z][_a-zA-Z0-9]*(\[[0-9]+\])+	{ lexerVal.strVal = strdup(text); return ARRAY_IDENTIFIER; }
[a-zA-Z][_a-zA-Z0-9]*				{ lexerVal.dataType = strdup(text); return IDENTIFIER; }

\"(\\.|[^"])*\"						{ lexerVal.strVal = strdup(text); return STRING_VALUE; }

\n									{lineNumber++;}
[ \t\r\v\f]							;
.									{invalidToken();}

%%

int wrap(void) {
	return 1;
}

void error(char* s) {
	fprintf(stderr, "\nStack Trace:\nError on line %d - %s\n", lineNumber, s);
	exit(0);
}

void invalidToken() {
	printf("Unexpected `%s` token on line %d\n", text, lineNumber);
	exit(0);
}
