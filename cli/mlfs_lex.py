from warnings import warn

class Token:
    offset: int
    lineno: int
    colno: int
    filename: str
    idint: int
    value: str
    __slots__ = ("offset", "lineno", "colno", "filename", "idint", "value")

    def __init__(self, offset, lineno, colno, filename, type, value):
        self.offset = offset
        self.lineno = lineno
        self.colno = colno
        self.filename = filename
        self.idint = type
        self.value = value

    def __eq__(self, other: "Token"):
        if not isinstance(other, Token):
            return False

        return (
            self.offset == other.offset
            and self.filename == other.filename
            and self.idint == other.idint
            and self.value == other.value
            and self.colno == other.colno
            and self.lineno == other.lineno
        )

    def __hash__(self):
        return (
            (self.offset ^ self.lineno ^ self.colno + 2333 + self.idint)
            ^ hash(self.filename)
            ^ hash(self.value)
        )

    def __repr__(self):
        return (
            "Token(offset=%d, lineno=%d, colno=%d, filename=%s, type=%d, value=%s)"
            % (
                self.offset,
                self.lineno,
                self.colno,
                self.filename,
                self.idint,
                repr(self.value),
            )
        )

def lexer(filename, text: str, *, pos=0, use_bof=True, use_eof=True):
    text_length = len(text)
    colno = 0
    lineno = 0
    newline = "\n"
    match = REGEX_STR.match
    ignores = IGNORES
    unionall_info = UNIONALL_INFO
    _Token = Token
    tokens = []
    append = tokens.append
    if use_bof:
        append(_Token(0, 0, 0, filename, BOF, ""))
    while True:
        if text_length <= pos:
            break
        
        res = match(text, pos)
        if not res:
            warn(f"No handler for character `{text[pos].__repr__()}`.")
            ch = text[pos]
            append(Token(pos, lineno, colno, filename, -1, ch))
            if ch == "\n":
                lineno += 1
                colno = 0
            pos += 1
            continue
        pat = res.group()
        typeid, cast_map = unionall_info[res.lastindex]
        if typeid in ignores:
            n = len(pat)
            line_inc = pat.count(newline)
            if line_inc:
                latest_newline_idx = pat.rindex(newline)
                colno = n - latest_newline_idx
                lineno += line_inc
            else:
                colno += n
            pos += n
            continue

        if cast_map:
            typeid = cast_map.get(pat, typeid)
        
        append(_Token(pos, lineno, colno, filename, typeid, pat))
        n = len(pat)
        line_inc = pat.count(newline)
        if line_inc:
            latest_newline_idx = pat.rindex(newline)
            colno = n - latest_newline_idx
            lineno += line_inc
        else:
            colno += n
        pos += n

    if use_eof:
        append(Token(pos, lineno, colno, filename, EOF, ""))
    return tokens

def lexer_lazy_bytes(filename, text: bytes, *, pos=0, use_bof=True, use_eof=True):
    text_length = len(text)
    colno = 0
    lineno = 0
    match = REGEX_BYTES.match
    ignores = IGNORES
    unionall_info = UNIONALL_INFO_BYTES
    _Token = Token
    if use_bof:
        yield _Token(0, 0, 0, filename, BOF, b"")
    
    while True:
        if text_length <= pos:
            break
        
        res = match(text, pos)
        if not res:
            warn(f"No handler for character `{str(text[pos]).__repr__()}`.")
            ch = text[pos]
            yield _Token(pos, lineno, colno, filename, -1, ch)
            if ch == b'\n':
                lineno += 1
                colno = 0
            pos += 1
            continue
        pat = res.group()
        typeid, cast_map = unionall_info[res.lastindex]
        if typeid in ignores:
            n = len(pat)
            line_inc = pat.count(b'\n')
            if line_inc:
                latest_newline_idx = pat.rindex(b'\n')
                colno = n - latest_newline_idx
                lineno += line_inc
            else:
                colno += n
            pos += n
            continue

        if cast_map:
            typeid = cast_map.get(pat, typeid)
        
        yield _Token(pos, lineno, colno, filename, typeid, pat)
        n = len(pat)
        line_inc = pat.count(b'\n')
        if line_inc:
            latest_newline_idx = pat.rindex(b'\n')
            colno = n - latest_newline_idx
            lineno += line_inc
        else:
            colno += n
        pos += n

    if use_eof:
        yield _Token(pos, lineno, colno, filename, EOF, "")

EOF = 1
BOF = 0
REGEX = '(\\s+)|([+-]?([0-9]*[.])[0-9]+)|((0|[1-9][0-9]*|0[oO]?[0-7]+|0[xX][0-9a-fA-F]+|0[bB][01]+)[lL]?)|("([^\\\\\\"]+|\\\\.)*?"|\'([^\\\\\\\']+|\\\\.)*?\')|([a-zA-Z_][a-zA-Z0-9_]*)|(\\})|(\\{)|(@)|(\\?)|(=)|(:)|(\\.)|(\\->)|(,)|(\\))|(\\()'
REGEX_STR = __import__('re').compile(REGEX)
REGEX_BYTES = __import__('re').compile(REGEX.encode())
IGNORES = (31,)
UNIONALL_INFO = ((None, None), (31, None), (30, None), (None, None), (29, None), (None, None), (14, None), (None, None), (None, None), (5, {'let': 19, 'else': 25, 'val': 17, 'if': 23, 'fun': 27, 'as': 4, 'import': 3, 'then': 24, 'forall': 6, 'module': 2, 'check': 21, 'extern': 28, 'open': 22, 'in': 26}), (13, None), (12, None), (15, None), (16, None), (20, None), (18, None), (7, None), (8, None), (11, None), (10, None), (9, None))
UNIONALL_INFO_BYTES = ((None, None), (31, None), (30, None), (None, None), (29, None), (None, None), (14, None), (None, None), (None, None), (5, {b'let': 19, b'else': 25, b'val': 17, b'if': 23, b'fun': 27, b'as': 4, b'import': 3, b'then': 24, b'forall': 6, b'module': 2, b'check': 21, b'extern': 28, b'open': 22, b'in': 26}), (13, None), (12, None), (15, None), (16, None), (20, None), (18, None), (7, None), (8, None), (11, None), (10, None), (9, None))
numbering = {'BOF': 0, 'EOF': 1, 'quote module': 2, 'quote import': 3, 'quote as': 4, 'name': 5, 'quote forall': 6, 'quote .': 7, 'quote ->': 8, 'quote (': 9, 'quote )': 10, 'quote ,': 11, 'quote {': 12, 'quote }': 13, 'str': 14, 'quote @': 15, 'quote ?': 16, 'quote val': 17, 'quote :': 18, 'quote let': 19, 'quote =': 20, 'quote check': 21, 'quote open': 22, 'quote if': 23, 'quote then': 24, 'quote else': 25, 'quote in': 26, 'quote fun': 27, 'quote extern': 28, 'int': 29, 'float': 30, 'space': 31}
