%{
    open Grammar
%}

%start grammar
%token<string> ID TID TYPE CODE
%token DTOKEN DTYPE DSTART DLEFT DRIGHT DNONASSOC DSEP
%token COLON SEMI BAR EQ
%token EOF

%%

grammar:
    | header decls DSEP rules EOF { { header; decls; rules } }
;

header:
    | header=CODE { header }
;

decls:
    | (* empty *) { [] }
    | decl decls  { decl :: decls }
;

decl:
    | DTOKEN tp=TYPE tids { DeclToken (Some tp, tids) }
    | DTOKEN tids         { DeclToken (None, tids) }
    | DSTART ids          { DeclStart ids }
    | DTYPE tp=TYPE ids   { DeclType (tp, ids) }           
    | DLEFT ids           { DeclLeft ids }
    | DRIGHT ids          { DeclRight ids }
    | DNONASSOC ids       { DeclNonassoc ids }
;

tids:
    | (* empty *)  { [] }
    | id=TID tids { id :: tids }
;

ids:
    | (* empty *) { [] }
    | id=ID ids   { id :: ids }
;

rules:
    | (* empty *) { [] }
    | rule rules  { rule :: rules }
;

rule:
    | id=ID COLON prods=rule_prods SEMI { { id; prods } }
;

rule_prods:
    | productions            { productions }
    | production productions { production :: productions }
;

productions:
    | (* empty *)                { [] }
    | BAR production productions { production :: productions }
;

production:
    | prod=producers action=CODE { { prod; action } }
;

producers:
    | (* empty *)        { [] }
    | producer producers { producer :: producers }
;

producer:
    | id=ID EQ actual { { id = Some id; actual } }
    | actual          { { id = None; actual } }
;

actual:
    | name=ID  { NTerm name }
    | name=TID { Term name }
;
