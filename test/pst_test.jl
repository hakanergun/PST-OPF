using PowerModels
const _PM = PowerModels
using PSTOPF
using Ipopt
using Memento
using JuMP

file = "/Users/hergun/.julia/dev/PSTOPF/PSTOPF/test/data/case5_base.m"
file_pst = "/Users/hergun/.julia/dev/PSTOPF/PSTOPF/test/data/case5_pst.m"
file_2pst = "/Users/hergun/.julia/dev/PSTOPF/PSTOPF/test/data/case5_2pst.m"

ipopt = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0)

s = Dict("output" => Dict("branch_flows" => true))
result = _PM.solve_opf(file, ACPPowerModel, ipopt; setting = s)
_PM.print_summary(result["solution"])
result_pst = PSTOPF.solve_pstopf(file_pst, ACPPowerModel, ipopt; setting = s)
_PM.print_summary(result_pst["solution"])
result_2pst = PSTOPF.solve_pstopf(file_2pst, ACPPowerModel, ipopt; setting = s)
_PM.print_summary(result_2pst["solution"])
