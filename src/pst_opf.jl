function solve_pstopf(file::String, model_type::Type, optimizer; kwargs...)
    data = PowerModels.parse_file(file)
    scale_pst_data!(data)
    return _PM.solve_model(data, model_type, optimizer, build_cbaopf; ref_extensions = [ref_add_pst!], kwargs...)
end

function solve_pstopf(data::Dict{String,Any}, model_type::Type, optimizer; kwargs...)
    return _PM.solve_model(data, model_type, optimizer, build_cbaopf; ref_extensions = [ref_add_pst!], kwargs...)
end

""
function build_cbaopf(pm::_PM.AbstractPowerModel)
    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    variable_pst(pm)


    _PM.constraint_model_voltage(pm)
    _PM.objective_min_fuel_cost(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        constraint_power_balance(pm, i)   # OUR NEW CONSTRAINT FOR POWER BALANCE
    end

    for i in _PM.ids(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)
        _PM.constraint_voltage_angle_difference(pm, i)
        _PM.constraint_thermal_limit_from(pm, i)
        _PM.constraint_thermal_limit_to(pm, i)
    end

    for i in _PM.ids(pm, :pst) # OUR NEW CONSTRAINTS FOR PST LIMITS AND POWER FLOW
        constraint_ohms_y_from_pst(pm, i)
        constraint_ohms_y_to_pst(pm, i)
        constraint_limits_pst(pm, i)
    end
end
