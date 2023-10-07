%{
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define LIST_SOURCE                 appendToCurrentLine(yytext)
#define LIST_TOKEN(name)            do { LIST_SOURCE; if(opt_tok) printf("<%s>\n", name); } while(0)
#define LIST_LITERAL(name, literal) do { LIST_SOURCE; if(opt_tok) printf("<%s: %s>\n", name, literal); } while(0)
#define MAX_LINE_LENG               512

uint32_t line_num = 1;
static char current_line[MAX_LINE_LENG];

static uint32_t opt_src = 1;
static uint32_t opt_tok = 1;
static char *current_line_ptr = current_line;

static void appendToCurrentLine(const char *yytext_ptr);

%}

digit [0-9]
letter [a-zA-Z]

%Start MULTILINE_COMMENT ONELINE_COMMENT

%%

<INITIAL>"," { LIST_TOKEN(","); }
<INITIAL>";" { LIST_TOKEN(";"); }
<INITIAL>":" { LIST_TOKEN(":"); }
<INITIAL>"(" { LIST_TOKEN("("); }
<INITIAL>")" { LIST_TOKEN(")"); }
<INITIAL>"[" { LIST_TOKEN("["); }
<INITIAL>"]" { LIST_TOKEN("]"); }

<INITIAL>"+" { LIST_TOKEN("+"); }
<INITIAL>"-" { LIST_TOKEN("-"); }
<INITIAL>"*" { LIST_TOKEN("*"); }
<INITIAL>"/" { LIST_TOKEN("/"); }
<INITIAL>"mod" { LIST_TOKEN("mod"); }
<INITIAL>":=" { LIST_TOKEN(":="); }
<INITIAL>"<" { LIST_TOKEN("<"); }
<INITIAL>"<=" { LIST_TOKEN("<="); }
<INITIAL>"<>" { LIST_TOKEN("<>"); }
<INITIAL>">=" { LIST_TOKEN(">="); }
<INITIAL>">" { LIST_TOKEN(">"); }
<INITIAL>"=" { LIST_TOKEN("="); }
<INITIAL>"and" { LIST_TOKEN("and"); }
<INITIAL>"or" { LIST_TOKEN("or"); }
<INITIAL>"not" { LIST_TOKEN("not"); }

<INITIAL>"var" { LIST_TOKEN("KWvar"); }
<INITIAL>"def" { LIST_TOKEN("KWdef"); }
<INITIAL>"array" { LIST_TOKEN("KWarray"); }
<INITIAL>"of" { LIST_TOKEN("KWof"); }
<INITIAL>"boolean" { LIST_TOKEN("KWboolean"); }
<INITIAL>"integer" { LIST_TOKEN("KWinteger"); }
<INITIAL>"real" { LIST_TOKEN("KWreal"); }
<INITIAL>"string" { LIST_TOKEN("KWstring"); }
<INITIAL>"true" { LIST_TOKEN("KWtrue"); }
<INITIAL>"false" { LIST_TOKEN("KWfalse"); }
<INITIAL>"while" { LIST_TOKEN("KWwhile"); }
<INITIAL>"do" { LIST_TOKEN("KWdo"); }
<INITIAL>"if" { LIST_TOKEN("KWif"); }
<INITIAL>"then" { LIST_TOKEN("KWthen"); }
<INITIAL>"else" { LIST_TOKEN("KWelse"); }
<INITIAL>"for" { LIST_TOKEN("KWfor"); }
<INITIAL>"to" { LIST_TOKEN("KWto"); }
<INITIAL>"begin" { LIST_TOKEN("KWbegin"); }
<INITIAL>"end" { LIST_TOKEN("KWend"); }
<INITIAL>"print" { LIST_TOKEN("KWprint"); }
<INITIAL>"read" { LIST_TOKEN("KWread"); }
<INITIAL>"return" { LIST_TOKEN("KWreturn"); }

<INITIAL>{letter}[a-zA-Z0-9]* { LIST_LITERAL("id", yytext); }

<INITIAL>0[0-7]+ { LIST_LITERAL("oct_integer", yytext); }

<INITIAL>0|[1-9]{digit}* { LIST_LITERAL("integer", yytext); }

<INITIAL>(0|[1-9]{digit}*)\.(0|{digit}*[1-9]) { LIST_LITERAL("float", yytext); }

<INITIAL>((0|[1-9]{digit}*)|((0|[1-9]{digit}*)\.(0|{digit}*[1-9])))(e|E)(\+|\-)?(0|[1-9]{digit}*) { LIST_LITERAL("scientific", yytext); } // (integer|float)(e|E)(+|-)?integer

<INITIAL>\"([^"\n]|\"\")*\" {
    char str[512];
    int i = 1, j = 0;
    while(yytext[i] != '\0')
    {
        if(yytext[i] == '"' && yytext[i + 1] == '"'){
            str[j] = '"';
            i += 2;
        }
        else if(yytext[i] == '"' && yytext[i + 1] == '\0'){
            str[j] = '\0';
            break;
        }
        else{
            str[j] = yytext[i];
            i++;
        }
        j++;
    }

    LIST_LITERAL("string", str);
}

<INITIAL>[\t ] { LIST_SOURCE; }

<INITIAL>"/*" { LIST_SOURCE; BEGIN MULTILINE_COMMENT; }
<MULTILINE_COMMENT>. { LIST_SOURCE; }
<MULTILINE_COMMENT>"*/" { LIST_SOURCE; BEGIN INITIAL; }

<INITIAL>"//" { LIST_SOURCE; BEGIN ONELINE_COMMENT; }
<ONELINE_COMMENT>. { LIST_SOURCE; }
<ONELINE_COMMENT>\n { BEGIN INITIAL; REJECT; }

<INITIAL>"//&S+" { opt_src = 1; LIST_SOURCE; BEGIN ONELINE_COMMENT; }
<INITIAL>"//&S-" { opt_src = 0; LIST_SOURCE; BEGIN ONELINE_COMMENT; }
<INITIAL>"//&T+" { opt_tok = 1; LIST_SOURCE; BEGIN ONELINE_COMMENT; }
<INITIAL>"//&T-" { opt_tok = 0; LIST_SOURCE; BEGIN ONELINE_COMMENT; }

\n {
    if (opt_src) {
        printf("%d: %s\n", line_num, current_line);
    }
    ++line_num;
    current_line[0] = '\0';
    current_line_ptr = current_line;
}

    /* Catch the character which is not accepted by rules above */
. {
    printf("Error at line %d: bad character \"%s\"\n", line_num, yytext);
    exit(-1);
}

%%

static void appendToCurrentLine(const char *yytext_ptr) {
    while (*yytext_ptr) {
        *current_line_ptr = *yytext_ptr;
        ++current_line_ptr;
        ++yytext_ptr;
    }
    *current_line_ptr = '\0';
}

int main(int argc, const char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s [filename]\n", argv[0]);
        exit(-1);
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Open file error\n");
        exit(-1);
    }

    yylex();

    fclose(yyin);
    /* Free resources used by the scanner; otherwise, unused data structures
    will persist throughout the successive compiler phases. */
    yylex_destroy();

    return 0;
}
