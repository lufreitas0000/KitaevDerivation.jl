using Symbolics
using KitaevDerivation

@variables J_H t U t_prime

T1 = build_T1_operator(:z, t, 0, :i, :j)
Tm1 = build_Tm1_operator(:z, t, 0, :j, :i)
H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)

site_i = :i
site_j = :j

bra = KitaevDerivation.pseudospin_ket(site_i, :up, site_j, :down)
ket = KitaevDerivation.pseudospin_ket(site_i, :up, site_j, :down)

for (initial_state, initial_coeff) in ket
    ket_single = Dict(initial_state => initial_coeff)
    element = 0.0 + 0.0im
    for term in H_eff.terms
        if term isa ScaledOperator
            res_state = KitaevDerivation.evaluate_string(term.op, ket_single)
            overlap = 0.0 + 0.0im
            for (k, v) in res_state
                overlap += conj(get(bra, k, 0.0)) * v
            end
            global element = element + term.scalar * overlap
        end
    end
    element = Symbolics.simplify(element)
    if !Symbolics._iszero(element)
        println("Initial state ", initial_state, " gives: ", element)
    end
end
