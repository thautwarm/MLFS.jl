import warnings
warnings.filterwarnings("ignore", category=SyntaxWarning, message='"is" with a literal')

from mlfs_lex import *
from mlfs_parser import *
from wisepy2 import wise
import json


def parse(text: str, filename: str = "unknown"):
    def _find_n(s: str, ch, n: int):
        since = 0
        for _ in range(0, n - 1):
            since = s.find(ch, since)

        return s[since : s.find(ch, since)]

    _parse = mk_parser()
    tokens = lexer(filename, text)
    res = _parse(None, Tokens(tokens))
    if res[0]:
        return res[1]
    msgs = []
    assert res[1]
    maxline = 0
    for each in res[1]:
        i, msg = each
        token = tokens[i]
        lineno = token.lineno
        maxline = max(lineno, maxline)
        colno = token.colno
        msgs.append(f"Line {lineno + 1}, column {colno}, {msg}")

    e = SyntaxError()
    e.lineno = maxline + 1
    e.msg = "\n".join(msgs)
    e.filename = filename
    off = token.offset
    e.offset = off
    e.text = text[: text.find("\n", off)]
    raise e

def mlfsf(file, o):
    parser = mk_parser()

    
    with open(file) as f:
        src = f.read()
    res = parse(src, file)
    
    with open(o, 'w') as f:
        f.write(json.dumps(res))
    return


if "__main__" == __name__:
    wise(mlfsf)()
