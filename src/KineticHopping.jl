# Kinetic Hopping Matrices and Fermionic Expansions

using Symbolics

export directional_hopping_matrix, build_T1_operator, build_Tm1_operator

"""
    directional_hopping_matrix(bond::Symbol, t::Num, t_prime::Num)::Matrix{Num}

Returns the 3x3 orbital hopping matrix T_ij for a given Kitaev bond (:x, :y, or :z).
"""
function directional_hopping_matrix(bond::Symbol, t::Num, t_prime::Num)::Matrix{Num}
    mat = zeros(Num, 3, 3)
    if bond == :x
        mat[2, 3] = mat[3, 2] = t # |y><z| + |z><y|
    elseif bond == :y
        mat[1, 3] = mat[3, 1] = t # |x><z| + |z><x|
    elseif bond == :z
        mat[1, 2] = mat[2, 1] = t # |x><y| + |y><x|
    else
        throw(ArgumentError("Bond must be :x, :y, or :z"))
    end
    # Note: Next-nearest neighbor (t') inclusions would expand this matrix.
    return mat
end

"""
    build_T1_operator(bond::Symbol, t::Num, t_prime::Num, site_i::Symbol, site_j::Symbol)::OperatorSum

Constructs T_1 = - \\sum P_i^{(2)} h_i^\\dagger \\tilde{T}_{ij} h_j P_j^{(1)}.
Creates a d4 virtual state on site i by hopping a hole from site j to site i.
"""
function build_T1_operator(bond::Symbol, t::Num, t_prime::Num, site_i::Symbol, site_j::Symbol)::OperatorSum
    T_mat = directional_hopping_matrix(bond, t, t_prime)
    orbitals = [:x, :y, :z]
    spins = [:up, :down]
    terms = AbstractQuantumOperator[]

    P2_i = ParticleProjector(2, site_i)
    P1_j = ParticleProjector(1, site_j)

    for (idx_a, a) in enumerate(orbitals)
        for (idx_b, b) in enumerate(orbitals)
            val = T_mat[idx_a, idx_b]
            if !isequal(val, 0)
                for sigma in spins
                    c_dag = FermionC(site_i, a, sigma)
                    c_ann = FermionA(site_j, b, sigma)
                    # Flanked by particle-number projectors to restrict subspace action
                    op_str = OperatorString([P2_i, c_dag, c_ann, P1_j])
                    push!(terms, ScaledOperator(-val, op_str))
                end
            end
        end
    end
    return OperatorSum(terms)
end

"""
    build_Tm1_operator(bond::Symbol, t::Num, t_prime::Num, site_i::Symbol, site_j::Symbol)::OperatorSum

Constructs T_{-1} = - \\sum P_i^{(1)} h_i^\\dagger \\tilde{T}_{ij} h_j P_j^{(2)}.
Destroys a d4 virtual state on site j, bringing the hole to site i.
"""
function build_Tm1_operator(bond::Symbol, t::Num, t_prime::Num, site_i::Symbol, site_j::Symbol)::OperatorSum
    T_mat = directional_hopping_matrix(bond, t, t_prime)
    orbitals = [:x, :y, :z]
    spins = [:up, :down]
    terms = AbstractQuantumOperator[]

    P1_i = ParticleProjector(1, site_i)
    P2_j = ParticleProjector(2, site_j)

    for (idx_a, a) in enumerate(orbitals)
        for (idx_b, b) in enumerate(orbitals)
            # Utilizing the transposed matrix conceptually, though T is symmetric for NN bonds
            val = T_mat[idx_b, idx_a] 
            if !isequal(val, 0)
                for sigma in spins
                    c_dag = FermionC(site_i, a, sigma)
                    c_ann = FermionA(site_j, b, sigma)
                    op_str = OperatorString([P1_i, c_dag, c_ann, P2_j])
                    push!(terms, ScaledOperator(-val, op_str))
                end
            end
        end
    end
    return OperatorSum(terms)
end
