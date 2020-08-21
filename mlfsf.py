import warnings
warnings.filterwarnings("ignore", category=SyntaxWarning, message='"is" with a literal')

from mlfs_lex import *
from mlfs_parser import *
from wisepy2 import wise
import json

def mlfsf(file, o):
    parser = mk_parser()

    
    with open(file) as f:
        src = f.read()
    
    tokens = Tokens(lexer(file, src))

    res = parser(None, tokens)
    if res[0] == True:
        with open(o, 'w') as f:
            f.write(json.dumps(res[1]))
        return
    
    print(res[1])


if "__main__" == __name__:
    wise(mlfsf)()
