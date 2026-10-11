# Atomic Hamiltonian and d4 Multiplets

using Symbolics
using SymbolicUtils

export ResolventOp
export atomic_hamiltonian, d4_multiplet_projectors, kanamori_eigenvalues, kanamori_resolvent_rules

struct ResolventOp <: AbstractQuantumOperator end

"""
    atomic_hamiltonian()::Vector{AbstractQuantumOperator}

Returns the unperturbed local Hubbard-Kanamori Hamiltonian partitions (V_N, V_S, V_L).
"""
function atomic_hamiltonian()::Vector{AbstractQuantumOperator}
    return [GenericOp(:V_N), GenericOp(:V_S), GenericOp(:V_L)]
end

"""
    d4_multiplet_projectors(site::Symbol = :i)::Tuple{ProjectorOp, ProjectorOp, ProjectorOp}

Returns the physical d4 projectors for the singlet (L=0, L=2) and triplet (L=1) channels.
"""
function d4_multiplet_projectors(site::Symbol = :i)::Tuple{ProjectorOp, ProjectorOp, ProjectorOp}
    return (MultipletProjector("P_[L=0]", site), MultipletProjector("P_[L=1]", site), MultipletProjector("P_[L=2]", site))
end

"""
    kanamori_eigenvalues(U::Num, JH::Num, site::Symbol = :i)::Dict{ProjectorOp, Num}

Maps each d4 angular momentum projector to its respective analytical exact energy (Delta E_L).
"""
function kanamori_eigenvalues(U::Num, JH::Num, site::Symbol = :i)::Dict{ProjectorOp, Num}
    return Dict(
        MultipletProjector("P_[L=0]", site) => U + 2*JH,
        MultipletProjector("P_[L=1]", site) => U - 3*JH,
        MultipletProjector("P_[L=2]", site) => U - JH
    )
end

"""
    kanamori_resolvent_rules(U::Num, JH::Num, site::Symbol = :i)::Vector{Any}

Constructs the SymbolicUtils rewriting rules that apply the resolvent operator 
\\mathcal{R} = (E_0 - H_0)^{-1} directly onto the projected angular momentum channels.
"""
function kanamori_resolvent_rules(U::Num, JH::Num, site::Symbol = :i)::Vector{Any}
    eigen_dict = kanamori_eigenvalues(U, JH, site)
    R = ResolventOp()

    rule_func = function(op)
        if op isa OperatorString
            # Need to find R * P
            for i in 1:length(op.factors)-1
                if op.factors[i] isa ResolventOp && op.factors[i+1] isa MultipletProjector && op.factors[i+1].site == site
                    P = op.factors[i+1]
                    val = -1 / eigen_dict[P]
                    new_factors = copy(op.factors)
                    deleteat!(new_factors, i)
                    new_op = length(new_factors) == 1 ? new_factors[1] : OperatorString(new_factors)
                    return ScaledOperator(val, new_op)
                end
            end
        end
        return nothing
    end
    
    return [
        @rule( ~(op)::(x -> x isa OperatorString) => rule_func(~(op)) )
    ]
end
