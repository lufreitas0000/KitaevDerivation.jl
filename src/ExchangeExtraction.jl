# Tensor Extraction and Magnetic Coefficients

"""
    pauli_trace(op::AbstractQuantumOperator, pauli_string::AbstractQuantumOperator)::Num

Extracts the scalar coefficient of a specific Pauli string from the effective Hamiltonian using trace identities.
"""
function pauli_trace(op::AbstractQuantumOperator, pauli_string::AbstractQuantumOperator)::Num end

"""
    extract_exchange_tensor(Heff::AbstractQuantumOperator)::Dict{Symbol, Num}

Analyzes the projected effective Hamiltonian and returns a dictionary with the coefficients J, K, Gamma, Gamma', and D.
"""
function extract_exchange_tensor(Heff::AbstractQuantumOperator)::Dict{Symbol, Num} end
