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

