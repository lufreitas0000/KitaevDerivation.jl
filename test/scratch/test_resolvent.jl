using KitaevDerivation
using Symbolics
using SymbolicUtils

@variables U J_H
var"P_[L=0]" = MultipletProjector("P_[L=0]", :i)
R = ResolventOp()
X = GenericOp(:X)

rules = kanamori_resolvent_rules(U, J_H, :i)

# Test 1: R * P
op1 = R * var"P_[L=0]"
println("Test 1 (R * P):")
for r in rules
    res = r(op1)
    if res !== nothing
        println(res)
        break
    end
end

# Test 2: R * P * X
op2 = OperatorString([R, var"P_[L=0]", X])
println("Test 2 (R * P * X):")
matched = false
for r in rules
    res = r(op2)
    if res !== nothing
        println(res)
        matched = true
        break
    end
end
if !matched
    println("No match for R * P * X")
end

