# CAR (Canonical Anti-commutation Relations) and Projector Algebra

export FermionC, FermionA, Projector, OperatorString
export apply_algebraic_rules, sort_normal_order

# 1. Concrete Operator Types
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

struct Projector <: ProjectorOp
    channel::Symbol # :L0, :L1, :L2, :Singlet, :Triplet
end

# Represents a multiplicative string of operators
struct OperatorString <: AbstractQuantumOperator
    factors::Vector{AbstractQuantumOperator}
end

# 2. Base Equivalence and Ordering Logic
Base.:(==)(a::FermionC, b::FermionC) = (a.site == b.site) && (a.orbital == b.orbital) && (a.spin == b.spin)
Base.:(==)(a::FermionA, b::FermionA) = (a.site == b.site) && (a.orbital == b.orbital) && (a.spin == b.spin)
Base.:(==)(a::Projector, b::Projector) = a.channel == b.channel
Base.hash(a::FermionC, h::UInt) = hash(a.site, hash(a.orbital, hash(a.spin, hash(:FermionC, h))))
Base.hash(a::FermionA, h::UInt) = hash(a.site, hash(a.orbital, hash(a.spin, hash(:FermionA, h))))
Base.hash(a::Projector, h::UInt) = hash(a.channel, hash(:Projector, h))

# Lexicographical ordering for canonical sorting
function Base.isless(a::FermionOp, b::FermionOp)
    if typeof(a) != typeof(b)
        return typeof(a) <: FermionC # Creation operators sort to the left (Normal Ordering)
    end
    if a.site != b.site return a.site < b.site end
    if a.orbital != b.orbital return a.orbital < b.orbital end
    return a.spin < b.spin
end

# 3. Canonical Anticommutation Relations (CAR) Engine
function anticommutator(A::FermionOp, B::FermionOp)::Int
    if (typeof(A) == FermionC && typeof(B) == FermionA) || (typeof(A) == FermionA && typeof(B) == FermionC)
        return (A.site == B.site && A.orbital == B.orbital && A.spin == B.spin) ? 1 : 0
    end
    return 0
end

# 4. Projector Algebra Engine
function evaluate_projector_product(P1::Projector, P2::Projector)
    if P1.channel == P2.channel
        return P1 # Idempotency
    end
    orthogonal_pairs = [(:L0, :L1), (:L1, :L2), (:L0, :L2), (:Singlet, :Triplet)]
    pair = (P1.channel, P2.channel)
    reverse_pair = (P2.channel, P1.channel)
    
    if pair in orthogonal_pairs || reverse_pair in orthogonal_pairs
        return 0
    end
    return nothing
end

# 5. AST Rewriting Engine
function apply_algebraic_rules(op_seq::Vector{AbstractQuantumOperator})
    if isempty(op_seq) return op_seq end
    simplified = AbstractQuantumOperator[]
    for op in op_seq
        if isempty(simplified)
            push!(simplified, op)
            continue
        end
        prev_op = simplified[end]
        
        # Rule 1: Projector Algebra
        if typeof(prev_op) == Projector && typeof(op) == Projector
            result = evaluate_projector_product(prev_op, op)
            if result == 0
                return AbstractQuantumOperator[] # Entire string vanishes
            elseif result isa Projector
                simplified[end] = result
                continue
            end
        end
        
        # Rule 2: Fermion Nilpotency
        if typeof(prev_op) <: FermionOp && typeof(op) <: FermionOp && typeof(prev_op) == typeof(op)
            if prev_op == op
                return AbstractQuantumOperator[] # Pauli exclusion 
            end
        end
        push!(simplified, op)
    end
    return simplified
end

# 6. Wick Contraction and Normal Ordering Algorithm
"""
    sort_normal_order(op_seq::Vector{AbstractQuantumOperator})

Evaluates Wick contractions by sorting Fermion operators into normal order.
Returns a Vector of Pairs mapping the generated Operator Strings to their integer scalar coefficients.
Empty AbstractQuantumOperator vectors represent the scalar identity (1).
"""
function sort_normal_order(op_seq::Vector{AbstractQuantumOperator})::Vector{Pair{Vector{AbstractQuantumOperator}, Int}}
    queue = [op_seq => 1]
    final_terms = Pair{Vector{AbstractQuantumOperator}, Int}[]
    
    while !isempty(queue)
        seq, coeff = popfirst!(queue)
        swapped = false
        
        for i in 1:(length(seq)-1)
            A, B = seq[i], seq[i+1]
            # If both are fermions and are out of canonical order
            if A isa FermionOp && B isa FermionOp && isless(B, A)
                # Check for contraction: c_i c_i^\dagger = 1 - c_i^\dagger c_i
                if A isa FermionA && B isa FermionC && A.site == B.site && A.orbital == B.orbital && A.spin == B.spin
                    # Branch 1: The +1 contraction (remove both operators)
                    seq_contracted = copy(seq)
                    deleteat!(seq_contracted, i:i+1)
                    push!(queue, seq_contracted => coeff)
                    
                    # Branch 2: The - c^\dagger c swapped term
                    seq_swapped = copy(seq)
                    seq_swapped[i], seq_swapped[i+1] = B, A
                    push!(queue, seq_swapped => -coeff)
                else
                    # Distinct fermions simply anticommute: A B = - B A
                    seq_swapped = copy(seq)
                    seq_swapped[i], seq_swapped[i+1] = B, A
                    push!(queue, seq_swapped => -coeff)
                end
                swapped = true
                break
            end
        end
        
        if !swapped
            # Sequence is fully sorted. Apply algebraic pruners (nilpotency, projectors)
            pruned_seq = apply_algebraic_rules(seq)
            # If the pruned sequence didn't evaluate to zero (represented by an artificial marker, or we rely on logic above)
            push!(final_terms, pruned_seq => coeff)
        end
    end
    
    # Combine like terms to prevent combinatorial branching explosion
    combined = Dict{Vector{AbstractQuantumOperator}, Int}()
    for (s, c) in final_terms
        combined[s] = get(combined, s, 0) + c
    end
    
    return [k => v for (k, v) in combined if v != 0]
end
