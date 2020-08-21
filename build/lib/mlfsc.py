from wisepy2 import wise
from subprocess import call
from json import dumps
from mlfsf import mlfsf
from pathlib import Path

def mlfsc(*vargs, name="main", sig="", o="./"):
    if o.endswith('.jl'):
        assert len(vargs) == 1
        oDir = vargs[0]
        args = [
            "julia", "--compile=min", "-e",
            f"using MLFS;ir2jl({dumps(oDir)}, {dumps(o)})"
        ]
        call(args)
        return
    outDir = o

        
    vargs = list(vargs)
    for i, varg in enumerate(vargs):
        if varg.endswith(".mlfs"):
            p = Path(varg)
            f = str(p.with_suffix('.mlfsf'))
            mlfsf(varg, f)
            vargs[i] = f
            
    srcFiles = ','.join(map(dumps, vargs))
    srcFiles = f"String[{srcFiles}]"
    
    sigFiles = ','.join(map(dumps, filter(lambda x: x, sig.split(";"))))
    sigFiles = f"String[{sigFiles}]"
    
    args = ["julia", "--compile=min", "-e", f"using MLFS;smlfsCompile({srcFiles}, {sigFiles}, {dumps(name)}, {dumps(outDir)})"]
    call(args)


def entry():
    wise(mlfsc)()

if __name__ == "__main__":
    wise(mlfsc)()