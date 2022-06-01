function scale_pst_data!(data)
    MVAbase = data["baseMVA"]
    rescale_power = x -> x/MVAbase
    for (p, pst) in data["pst"]
        _PM._apply_func!(pst, "rate_a", rescale_power)
        _PM._apply_func!(pst, "rate_b", rescale_power)
        _PM._apply_func!(pst, "rate_c", rescale_power)
        _PM._apply_func!(pst, "angle", deg2rad)
        _PM._apply_func!(pst, "angmin", deg2rad)
        _PM._apply_func!(pst, "angmax", deg2rad)
    end
end