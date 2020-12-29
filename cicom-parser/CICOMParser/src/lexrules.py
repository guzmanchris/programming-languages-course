# Module with token definitions for the lexer
from ply.lex import TOKEN

# Handle reserved words (Avoid them being identified as ID)
reserved = {
    'if': 'IF',
    'then': 'THEN',
    'else': 'ELSE',
    'let': 'LET',
    'in': 'IN',
    'map': 'MAP',
    'to': 'TO',
    'true': 'BOOL',
    'false': 'BOOL'
}

# Required list of token names. (Will be used by parser)
tokens = tuple({
    'SIGN',
    'BINOP',
    'PRIM',
    'ID',
    'INT',
    'DEFINE',
    *reserved.values()
    })

#  ------------------------------------------ Define the tokens -------------------------------------------------------
# Specify delimiters and ~ as literals
literals = ['(', ')', '[', ']', ',', ';', '~']

character = r'[a-zA-Z\?_]'

t_SIGN = r'[+\-]'
t_BINOP = r'!=|<=|>=|[*/=<>&|]'  # sign rule handled on the parser side
t_PRIM = r'number\?|function\?|list\?|empty\?|cons\?|cons|first|rest|arity'
t_DEFINE = ':='
id = character + r'(' + character + r'|\d)*'


@TOKEN(id)
def t_ID(t):
    # Handle reserved words are not mistakenly typed as ID
    t.type = reserved.get(t.value, 'ID')
    # Update value of BOOL to the appropriate boolean.
    if t.value == 'true':
        t.value = True
    elif t.value == 'false':
        t.value = False
    return t


def t_INT(t):
    r"""\d+"""
    # Cast the value to an int type
    t.value = int(t.value)
    return t


# --------------------- Useful rules recommended or required as specified in documentation ----------------------------
# Ignore whitespaces and tabs
t_ignore = ' \t'


# Keep track of new lines. (PLY doesn't do it by default).
def t_newline(t):
    r"""\n+"""
    t.lexer.lineno += len(t.value)


# Error handling. Raise error on illegal characters.
def t_error(t):
    raise SyntaxError("[Syntax Error] Illegal character on line {}: '{}'".format(t.lineno, t.value[0]))
