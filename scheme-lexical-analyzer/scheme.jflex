/* Import statements */
import java.util.ArrayList;

%%

/* -----------------------Class definition and variable initialization------------------------------- */
%class Scheme
%standalone
%line
%column

%{
  ArrayList<Object[]> list = new ArrayList<>();
%}

/* End of file actions */ 

%eof{
     System.out.println("");
     System.out.println("----------------------------------------------------------------------");
     System.out.println("  LINE     COLUMN              LEXEME               TOKEN   ");
     System.out.println("----------------------------------------------------------------------");
     for(Object[] row : list) {
         System.out.format("%5s%10s%20s%30s\n", row);
     }
%eof}

/* ------------------------------------------------ Macronims ----------------------------------------- */

/* scheme tockens (Used in general) */

open_parenthesis = "("
open_vector_parenthesis = "#("
close_parenthesis = ")"
dotted_pair_maker = "."
abbreviation_key = "'"|"`"|","|",@"
comment = ";"~\n

/* scheme keywords as interpreted from formal syntax documentation (Used in Definitions and Expressions) */

form_type= "let-syntax"|"letrec-syntax"|"syntax-rules"|"define"|"define-syntax"
core_expression = "quote"|"lambda"|"if"|"set!"
derived_expression = "and"|"begin"|"case"|"cond"|"delay"|"do"|"let"|"let*"|"letrec"|"or"|"quasiquote"

/* scheme identifiers as interpreted from formal syntax documentation */

initial = [a-zA-Z]|"!"|"$"|"%"|"&"|"!"|"/"|":"|"<"|"="|">"|"?"|"~"|"_"|"^"
subsequent = {initial}|\d|"."|"+"|"-"
identifier = {initial}{subsequent}*|"+"|"-"|"..."

/* scheme data as interpreted from formal syntax documentation */

boolean = #t|#f|#T|#F
character = #\\[a-zA-Z]|#\\[nN][eE][wW][lL][iI][nN][eE]|#\\[sS][pP][aA][cC][eE]
string = \"{string_character}*\"
string_character = \\\"|\\{2}|[^\"\\]

/* scheme numbers as interpreted from formal syntax documentation*/

number = {prefix}{complex}
complex = {real}|{real}"@"{real}|{real}"+"{imaginary}|{real}"-"{imaginary}
imaginary = i|{unreal}i
real = {sign}?{unreal}
unreal = {uninteger}|{uninteger}\/{uninteger}|{decimal_ten}
uninteger = {digit}+#*
prefix = {radix}?{exactness}?|{exactness}?{radix}?
decimal_ten = {uninteger}{exponent}|"."\d+#*{suffix}?|\d+"."\d*#*{suffix}?|\d+#+"."#*{suffix}?
suffix = {exponent}
exponent = {exponent_marker}{sign}?\d+
exponent_marker = e|s|f|d|l
sign = "+"?|"-"?
exactness = #i|#e|#I|#E
radix = #b|#o|#d|#x|#B|#O|#D|#X
digit = [0-9a-fA-F]

%%

/* ------------------------------------match and add to list---------------------------------------------- */

/* scheme tokens */

{open_parenthesis} { list.add(new Object[] {yyline, yycolumn, yytext(), "OPEN PARENTHESIS"}); }

{open_vector_parenthesis} { list.add(new Object[] {yyline, yycolumn, yytext(), "OPEN VECTOR PARENTHESIS"}); }

{close_parenthesis} { list.add(new Object[] {yyline, yycolumn, yytext(), "CLOSE PARENTHESIS"}); }

{comment} { list.add(new Object[] {yyline, yycolumn, yytext().substring(0,yytext().length() - 2), "COMMENT"}); }

/* scheme keywords */

{form_type} { list.add(new Object[] {yyline, yycolumn, yytext(), "FORM KEYWORD"}); }

{core_expression} { list.add(new Object[] {yyline, yycolumn, yytext(), "CORE EXPRESSION"}); }

{derived_expression} { list.add(new Object[] {yyline, yycolumn, yytext(), "DERIVED EXPRESSION"}); }

/* scheme identifier */

{identifier} { list.add(new Object[] {yyline, yycolumn, yytext(), "IDENTIFIER"}); }

/* scheme data */

{boolean} { list.add(new Object[] {yyline, yycolumn, yytext(), "BOOLEAN"}); }

{number} { list.add(new Object[] {yyline, yycolumn, yytext(), "NUMBER"}); }

{character} { list.add(new Object[] {yyline, yycolumn, yytext(), "CHARACTER"}); }

{string} { list.add(new Object[] {yyline, yycolumn, yytext(), "STRING"}); }

{dotted_pair_maker} { list.add(new Object[] {yyline, yycolumn, yytext(), "DOTTED PAIR MAKER"}); }

{abbreviation_key} { list.add(new Object[] {yyline, yycolumn, yytext(), "ABBREVIATION KEY"}); }













