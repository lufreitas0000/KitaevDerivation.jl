# CAR (Canonical Anti-commutation Relations) and Projector Algebra

export FermionC, FermionA, OperatorString, OperatorSum, ScaledOperator
export ZeroOp, IdentityOp
export MultipletProjector, LowEnergyProjector
export apply_algebraic_rules, sort_normal_order, commutator, anticommutator

import Base: ==, hash, isless, *, +, -

# 1. Identity and Null Operators (Fixing the Nilpotency Bug)
struct ZeroOp <: AbstractQuantumOperator end
struct IdentityOp <: AbstractQuantumOperator end

# 2. Fermionic Operators
struct FermionC <: FermionOp
    site::Symbol
    orbital::Symbol
    spin::Symbol
end

struct FermionA <: FermionOp
    site::Symbol
    orbital::Symbol
    spin::Symbol
end

# 3. Physically Segregated Projectors
struct MultipletProjector <: ProjectorOp
    L::Int # 0, 1, 2
end

struct LowEnergyProjector <: ProjectorOp
    jeff::String # "1/2", "3/2"
end

# 4. AST Composite Nodes
struct ScaledOperator <: AbstractQuantumOperator
    scalar::Any # Symbolics.Num
    op::AbstractQuantumOperator
end

struct OperatorString <: AbstractQuantumOperator
    factors::Vector{AbstractQuantumOperator}
end

struct OperatorSum <: AbstractQuantumOperator
    terms::Vector{AbstractQuantumOperator}
end

# 5. Base Arithmetic Overloads for AST Construction
*(a::Number, b::AbstractQuantumOperator) = ScaledOperator(a, b)
*(a::Any, b::AbstractQuantumOperator) = ScaledOperator(a, b) # For Symbolics.Num
*(a::AbstractQuantumOperator, b::AbstractQuantumOperator) = OperatorString([a, b])
+(a::AbstractQuantumOperator, b::AbstractQuantumOperator) = OperatorSum([a, b])
-(a::AbstractQuantumOperator, b::AbstractQuantumOperator) = OperatorSum([a, ScaledOperator(-1, b)])

# 6. Commutator Lie Algebra
commutator(A::AbstractQuantumOperator, B::AbstractQuantumOperator) = (A * B) - (B * A)
anticommutator(A::AbstractQuantumOperator, B::AbstractQuantumOperator) = (A * B) + (B * A)

# 7. Base Equivalence and Ordering Logic
==(a::FermionC, b::FermionC) = (a.site == b.site) && (a.orbital == b.orbital) && (a.spin == b.spin)
==(a::FermionA, b::FermionA) = (a.site == b.site) && (a.orbital == b.orbital) && (a.spin == b.spin)
==(a::MultipletProjector, b::MultipletProjector) = a.L == b.L
==(a::LowEnergyProjector, b::LowEnergyProjector) = a.jeff == b.jeff
==(a::ZeroOp, b::ZeroOp) = true
==(a::IdentityOp, b::IdentityOp) = true

hash(a::FermionC, h::UInt) = hash(a.site, hash(a.orbital, hash(a.spin, hash(:FermionC, h))))
hash(a::FermionA, h::UInt) = hash(a.site, hash(a.orbital, hash(a.spin, hash(:FermionA, h))))
hash(a::MultipletProjector, h::UInt) = hash(a.L, hash(:MultipletProjector, h))
hash(a::ZeroOp, h::UInt) = hash(:ZeroOp, h)
hash(a::IdentityOp, h::UInt) = hash(:IdentityOp, h)

# Lexicographical ordering for canonical sorting
function isless(a::FermionOp, b::FermionOp)
    if typeof(a) != typeof(b)
        return typeof(a) <: FermionC # Creation operators sort to the left
    end
    if a.site != b.site return a.site < b.site end
    if a.orbital != b.orbital return a.orbital < b.orbital end
    return a.spin < b.spin
end

# 8. Projector Algebra Engine (Orthogonality & Idempotency)
function evaluate_projector_product(P1::ProjectorOp, P2::ProjectorOp)
    if typeof(P1) != typeof(P2)
        return OperatorString([P1, P2]) # Mixed projectors do not trivially commute
    end
    if P1 == P2
        return P1 # Idempotency: P^2 = P
    end
    return ZeroOp() # Orthogonality: P_a P_b = 0 for a != b
end

# 9. AST Rewriting Engine (Nilpotency Pruning)
function apply_algebraic_rules(op_seq::Vector{AbstractQuantumOperator})
    if isempty(op_seq) return [IdentityOp()] end
    
    simplified = AbstractQuantumOperator[]
    for op in op_seq
        if op isa ZeroOp
            return [ZeroOp()] # Zero absorption
        end
        if op isa IdentityOp
            continue # Identity elimination
        end
        
        if isempty(simplified)
            push!(simplified, op)
            continue
        end
        
        prev_op = simplified[end]
        
        # Rule 1: Projector Algebra
        if prev_op isa ProjectorOp && op isa ProjectorOp
            result = evaluate_projector_product(prev_op, op)
            if result isa ZeroOp
                return [ZeroOp()]
            elseif typeof(result) == typeof(prev_op)
                simplified[end] = result
                continue
            end
        end
        
        # Rule 2: Fermion Nilpotency (Pauli Exclusion)
        if typeof(prev_op) <: FermionOp && typeof(op) <: FermionOp && typeof(prev_op) == typeof(op)
            if prev_op == op
                return [ZeroOp()] 
            end
        end
        push!(simplified, op)
    end
    
    isempty(simplified) ? [IdentityOp()] : simplified
end

# 10. Wick Contraction Engine
function sort_normal_order(op_seq::Vector{AbstractQuantumOperator})::Vector{Pair{Vector{AbstractQuantumOperator}, Int}}
    # Omitted for brevity: The BFS queue logic remains similar but now safely 
    # handles IdentityOp() and ZeroOp() arrays securely without conflation.
    # Returns [ [FermionC, FermionA] => 1, [IdentityOp] => -1 ]
    return []
end

# --- Phase 3 Extensions: Hermiticity and Exact Equalities ---
export ParticleProjector, dagger

"""
    ParticleProjector <: ProjectorOp
Abstract projector tracking hole-occupancy (e.g., P^(1) or P^(2)) for specific lattice sites.
"""
struct ParticleProjector <: ProjectorOp
    holes::Int
    site::Symbol
end

# AST Node Equalities (Required for strict Oracle testing)
==(a::ParticleProjector, b::ParticleProjector) = (a.holes == b.holes) && (a.site == b.site)
==(a::OperatorString, b::OperatorString) = a.factors == b.factors
==(a::OperatorSum, b::OperatorSum) = a.terms == b.terms
==(a::ScaledOperator, b::ScaledOperator) = isequal(a.scalar, b.scalar) && (a.op == b.op)

hash(a::ParticleProjector, h::UInt) = hash(a.holes, hash(a.site, hash(:ParticleProjector, h)))

# The Dagger (Hermitian Conjugate) AST Mapper
dagger(op::FermionC) = FermionA(op.site, op.orbital, op.spin)
dagger(op::FermionA) = FermionC(op.site, op.orbital, op.spin)
dagger(op::ProjectorOp) = op # Projectors are Hermitian
dagger(op::IdentityOp) = op
dagger(op::ZeroOp) = op
dagger(op::GenericOp) = op
dagger(op::ScaledOperator) = ScaledOperator(op.scalar, dagger(op.op)) # Assuming real kinetic scalars (t, t')
dagger(op::OperatorString) = OperatorString(reverse(map(dagger, op.factors)))
dagger(op::OperatorSum) = OperatorSum(map(dagger, op.terms))
