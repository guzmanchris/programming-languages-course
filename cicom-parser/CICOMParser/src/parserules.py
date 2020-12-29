# Module with rules for the parser
from lexrules import tokens


# ---------------------------------------------- Grammar Rules --------------------------------------------------------
# NOTE: Since the objective of this parser is just to verify if the syntax is correct, most of the methods do not
# manipulate the data or assign any value to p[0]
def p_exp(p):
    """
    exp : term
        | term binop exp
        | IF exp THEN exp ELSE exp
        | LET defrepetitions IN exp
        | MAP idlist TO exp
    defrepetitions : def
                   | defrepetitions def
    """
    # The return value at the end of the parse is the final value of p[0] returned by this rule. In this case,
    # since we just want to verify the syntax is correct. We assign the value 'Syntax is correct!'
    p[0] = 'Synyax is correct!'


def p_term(p):
    """
    term : unop term
        | factor
        | factor '(' explist ')'
        | empty
        | int
        | bool
    """
    pass


def p_factor(p):
    """
    factor : '(' exp ')'
           | prim
           | id
    """
    pass


def p_explist(p):
    """
    explist : propexplist
            | empty
    """
    pass


def p_propexplist(p):
    """
    propexplist : exp
                | exp ',' propexplist
    """
    pass


def p_idlist(p):
    """
    idlist : propidlist
           | empty
    """
    pass


def p_propidlist(p):
    """propidlist : id
                  | id ',' propidlist"""
    pass


def p_def(p):
    """def : id DEFINE exp ';'"""
    pass


def p_empty(p):
    """empty :"""
    pass


def p_bool(p):
    """bool : BOOL"""
    p[0] = p[1]


def p_unop(p):
    """
    unop : sign
         | '~'
    """
    p[0] = p[1]


def p_sign(p):
    """sign : SIGN"""
    p[0] = p[1]


def p_binop(p):
    """
    binop : sign
          | BINOP
    """
    p[0] = p[1]


def p_prim(p):
    """prim : PRIM"""
    p[0] = p[1]


def p_id(p):
    """id : ID"""
    p[0] = p[1]


def p_int(p):
    """int : INT"""
    p[0] = p[1]


# Raise syntax error if any errors are detected.
def p_error(p):
    raise SyntaxError('[Syntax Error] Invalid syntax on line {} : {}'.format(p.lineno, p.value))
