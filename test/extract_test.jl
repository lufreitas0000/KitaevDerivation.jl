using Symbolics
@variables U J_H t lambda_soc
expr = (-(t^2)) / (2*J_H + U)
println(Symbolics.get_variables(expr))
