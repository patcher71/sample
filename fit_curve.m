function fit_curve(r_slider, ke_slider, ku_slider, kads_slider, kdes_slider, ax, time, avg_data)

    % Define the objective function for curve fitting
    objective_function = @(parameters) sum((simulate_model(parameters, time) - avg_data).^2);

    % Set initial parameter guesses
    initial_guess = [r_slider.Value, ke_slider.Value, ku_slider.Value, kads_slider.Value, kdes_slider.Value];

    % Perform curve fitting using fminsearch
    [fitted_parameters, residual] = fminsearch(objective_function, initial_guess);

    % Update slider values with fitted parameters
    r_slider.Value = fitted_parameters(1);
    ke_slider.Value = fitted_parameters(2);
    ku_slider.Value = fitted_parameters(3);
    kads_slider.Value = fitted_parameters(4);
    kdes_slider.Value = fitted_parameters(5);

    % Update plot with fitted curve
    update_plot(r_slider, ke_slider, ku_slider, kads_slider, kdes_slider, ax, time, avg_data);

    % Display goodness of fit
    fprintf('Residual: %f\n', residual);

end