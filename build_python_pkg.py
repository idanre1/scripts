#!/usr/bin/env python
import ast
import sys
from pathlib import Path
import argparse

def top_level_functions(body):
    def cond(d):
        return isinstance(d, ast.FunctionDef) and (not d.name.startswith('_'))
    return (f for f in body if cond(f))

def parse_ast(filename):
    with open(filename, "rt") as file:
        return ast.parse(file.read(), filename=filename)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", required=True, help="path to package")
    args = parser.parse_args()    

    pgk=Path(args.path).resolve().name

    files = []
    for path in Path(args.path).rglob('*.py'):
        files.append(path)    

    with open(f'{args.path}/__init__.py', 'w') as f:

        for filename in files:
            tree = parse_ast(filename)
            for func in top_level_functions(tree.body):
                hier = filename.relative_to(args.path)
                hier = f'{hier.parent}'.replace('/','.')
                if (hier == '.'):
                    hier = "" # In case there is no subfolders
                else:
                    hier = hier + '.'
                print(f'from {pgk}.{hier}{filename.stem} import {func.name}', file=f)

# from stats_math.src.tests.py.tests import white_test
