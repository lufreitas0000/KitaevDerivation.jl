using Symbolics
using KitaevDerivation

@variables J_H t U t_prime

T1 = build_T1_operator(:z, t, t_prime, :i, :j)
Tm1 = build_Tm1_operator(:z, t, t_prime, :j, :i)
H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)

site_i = :i
site_j = :j

bra = KitaevDerivation.pseudospin_ket(site_i, :down, site_j, :down)
ket = KitaevDerivation.pseudospin_ket(site_i, :up, site_j, :up)

element = 0.0 + 0.0im
for term in H_eff.terms
    if term isa ScaledOperator
        res_state = KitaevDerivation.evaluate_string(term.op, ket)
        overlap = 0.0 + 0.0im
        for (k, v) in res_state
            overlap += conj(get(bra, k, 0.0)) * v
        end
        global element = element + term.scalar * overlap
    end
end
println("Off-diag element = ", Symbolics.simplify(element))
