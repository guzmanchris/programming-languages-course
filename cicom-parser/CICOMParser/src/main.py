# Create the lexer and the parser and select which one to use on custom or default input.
import os
import sys
from ply import yacc, lex
import lexrules
import parserules

lexer = lex.lex(module=lexrules)
parser = yacc.yacc(module=parserules)

try:  # Try to read file specified from command line
    file = open(sys.argv[1], 'r')
    data = file.read()
    file.close()
except IndexError:  # No file given in command line.
    data = None
except FileNotFoundError as e:
    data = None
    print(e)


while True:
    if not data:
        print("""Choose an option:
        1. Use a custom text file
        2. Use the default text file
        3. Exit program
        """)

        selection = int(input())
        file = None
        if selection == 1:
            print('Please enter the full path to the file: ')
            try:
                file = open(input().replace('\\', '/'))
            except FileNotFoundError as e:
                print(e)
                continue
        elif selection == 2:
            try:
                base_dir = os.path.dirname(os.path.abspath(__file__))
                file = open(os.path.join(base_dir, 'CorrectSyntax.txt'))
            except FileNotFoundError as e:
                print('File was not found. Make sure you have a file named: CorrectSyntax.txt in the same directory as main.py')
                continue
        elif selection == 3:
            break

        if file:
            data = file.read()
            file.close()

    print("""Choose an option:
    1. Output all tokens found on file
    2. Parse file to verify if the syntax is correct
    3. Change File
    4. Exit""")
    selection = int(input())

    if lexer.lineno > 1:
        lexer.lineno = 1  # Reset the line count (It is not reset by default).

    if selection == 1:
        try:
            lexer.input(data)
            for token in lexer:
                print(token)
        except SyntaxError as e:
            print(e)
    elif selection == 2:
        try:
            print(parser.parse(data))
        except SyntaxError as e:
            print(e)
    elif selection == 3:
        data = None
    elif selection == 4:
        break
