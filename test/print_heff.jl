using Symbolics
using KitaevDerivation

@variables U J_H t t_prime

T1 = build_T1_operator(:z, t, t_prime, :i, :j)
Tm1 = build_Tm1_operator(:z, t, t_prime, :i, :j) # Wait, should it be j, i?

H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)
println("Number of terms: ", length(H_eff.terms))
println("First few terms: ")
for i in 1:min(5, length(H_eff.terms))
    println(H_eff.terms[i])
end
