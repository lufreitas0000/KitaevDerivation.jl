# Auxiliary Composite Operators (Spin, Orbital, Number)

export CompositeOp, SpinComposite, OrbitalComposite, NumberComposite

abstract type CompositeOp <: AbstractQuantumOperator end

struct SpinComposite <: CompositeOp
    site::Symbol
    component::Symbol # :x, :y, :z
end

struct OrbitalComposite <: CompositeOp
    site::Symbol
    component::Symbol # :x, :y, :z
end

struct NumberComposite <: CompositeOp
    site::Symbol
end

# The equivalence maps to expand composites into fundamental fermions
# (Used strictly for Oracle verification, not macroscopic execution)
function expand_to_fermions(op::CompositeOp)::OperatorString
    # TODO: Implement expansion map (e.g., S_i^a -> 1/2 h_i^\dagger \sigma^a h_i)
    # based on Equations (19) and (20).
end
