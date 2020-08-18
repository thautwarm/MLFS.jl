@data TypeInfo begin
    InstTo(HMT)
    NoProp
end

function gTrans(self::Function, root::HMT)
    @match root begin
        Var(_) || Nom(_) || Fresh(_) => root
        App(f, arg) => App(self(f), self(arg))
        Arrow(arg, ret) => Arrow(self(arg), self(ret))
        Tup(xs) => Tup(Tuple(self(x) for x in xs))
        Forall(ns, p) => Forall(ns, self(p))
        Record(row) =>
            let rec(row) =
                @match row begin
                    RowMono => root
                    RowCons(f, t, poly) =>
                        RowCons(f, self(t), rec(row))
                    RowPoly(t) =>
                        let t = self(t)
                            while true
                                @switch t begin
                                @case Record(RowPoly(a))
                                    t = a
                                    continue
                                @case _
                                    break
                                end
                            end
                            RowPoly(t)
                        end
                end
                
                Record(rec(row))
            end
    end
end
