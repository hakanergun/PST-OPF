##############################################
# PST Constraints
function constraint_ohms_y_from_pst(pm::_PM.AbstractACPModel, n::Int, i::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr)
    alpha = _PM.var(pm, n,  :psta, i)
    p_fr  = _PM.var(pm, n,  :ppst, f_idx)
    q_fr  = _PM.var(pm, n,  :qpst, f_idx)
    vm_fr = _PM.var(pm, n, :vm, f_bus)
    vm_to = _PM.var(pm, n, :vm, t_bus)
    va_fr = _PM.var(pm, n, :va, f_bus)
    va_to = _PM.var(pm, n, :va, t_bus)

    JuMP.@NLconstraint(pm.model, p_fr ==  (g+g_fr)*(vm_fr)^2 - g*vm_fr*vm_to*cos(va_fr-va_to-alpha) + -b*vm_fr*vm_to*sin(va_fr-va_to-alpha) )
    JuMP.@NLconstraint(pm.model, q_fr == -(b+b_fr)*(vm_fr)^2 + b*vm_fr*vm_to*cos(va_fr-va_to-alpha) + -g*vm_fr*vm_to*sin(va_fr-va_to-alpha) )
end
"""
constraint_ohms_y_to_pst
this function foes somthing
"""
function constraint_ohms_y_to_pst(pm::_PM.AbstractACPModel, n::Int, i::Int, f_bus, t_bus, f_idx, t_idx, g, b, g_to, b_to)
    alpha = _PM.var(pm, n,  :psta, i)
    p_to  = _PM.var(pm, n,  :ppst, t_idx)
    q_to  = _PM.var(pm, n,  :qpst    , t_idx)
    vm_fr = _PM.var(pm, n, :vm, f_bus)
    vm_to = _PM.var(pm, n, :vm, t_bus)
    va_fr = _PM.var(pm, n, :va, f_bus)
    va_to = _PM.var(pm, n, :va, t_bus)

    JuMP.@NLconstraint(pm.model, p_to ==  (g+g_to)*vm_to^2 - g*vm_to*vm_fr*cos(va_to-va_fr+alpha) + -b*vm_to*vm_fr*sin(va_to-va_fr+alpha) )
    JuMP.@NLconstraint(pm.model, q_to == -(b+b_to)*vm_to^2 + b*vm_to*vm_fr*cos(va_to-va_fr+alpha) + -g*vm_to*vm_fr*sin(va_to-va_fr+alpha) )
end

function constraint_limits_pst(pm::_PM.AbstractACPModel, i::Int; nw::Int=_PM.nw_id_default)
    pst = _PM.ref(pm, nw, :pst, i)
    srated = pst["rate_a"]
    angmin = pst["angmin"]
    angmax = pst["angmax"]

    f_bus = pst["f_bus"]
    t_bus = pst["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    alpha = _PM.var(pm, nw,  :psta, i)
    p_fr  = _PM.var(pm, nw,  :ppst, f_idx)
    q_fr  = _PM.var(pm, nw,  :qpst, f_idx)
    p_to  = _PM.var(pm, nw,  :ppst, t_idx)
    q_to  = _PM.var(pm, nw,  :qpst, t_idx)

    JuMP.@NLconstraint(pm.model, p_fr^2 + q_fr^2 <= srated^2)
    JuMP.@NLconstraint(pm.model, p_to^2 + q_to^2 <= srated^2)
    JuMP.@constraint(pm.model, alpha <= angmax)
    JuMP.@constraint(pm.model, alpha >= angmin)
end

function constraint_power_balance(pm::_PM.AbstractACPModel, n::Int, i::Int, bus_arcs, bus_arcs_pst,bus_gens, bus_loads, bus_gs, bus_bs, bus_pd, bus_qd)
    vm   = _PM.var(pm, n, :vm, i)
    p    = _PM.var(pm, n, :p)
    q    = _PM.var(pm, n, :q)
    ppst    = _PM.var(pm, n,    :ppst)
    qpst    = _PM.var(pm, n,    :qpst)
    pg   = _PM.var(pm, n,   :pg)
    qg   = _PM.var(pm, n,   :qg)


    cstr_p = JuMP.@constraint(pm.model,
        sum(p[a] for a in bus_arcs)
        + sum(ppst[a] for a in bus_arcs_pst)
        ==
        sum(pg[g] for g in bus_gens)
        - sum(pd for (i,pd) in bus_pd)
        - sum(gs for (i,gs) in bus_gs)*vm^2
    )
    cstr_q = JuMP.@constraint(pm.model,
        sum(q[a] for a in bus_arcs)
        + sum(qpst[a] for a in bus_arcs_pst)
        ==
        sum(qg[g] for g in bus_gens)
        - sum(qd for (i,qd) in bus_qd)
        + sum(bs for (i,bs) in bus_bs)*vm^2
    )
end