from wisepy2 import wise
from subprocess import call
from json import dumps

def cmd(*vargs, name="main", sig="", outDir="./"):

    srcFiles = []
    for a in vargs:
        mod, path = a.split('=')
        srcFiles.append(f"Symbol({dumps(mod)}) => {dumps(path)}")
    srcFiles = "Pair{Symbol, String}[" + ','.join(srcFiles) + "]"
    
    sigFiles = ','.join(map(dumps, filter(lambda x: x, sig.split(";"))))
    sigFiles = f"String[{sigFiles}]"
    
    args = ["julia", "--compile=min", "-e", f"using MLFS;smlfsCompile({srcFiles}, {sigFiles}, {dumps(name)}, {dumps(outDir)})"]
    call(args)

if __name__ == "__main__":
    wise(cmd)()