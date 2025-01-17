function update_plot(r_slider, ke_slider, ku_slider, kads_slider, kdes_slider, ax, time, avg_data)

    % Get parameter values from sliders
    r = r_slider.Value;
    ke = ke_slider.Value;
    ku = ku_slider.Value;
    kads = kads_slider.Value;
    kdes = kdes_slider.Value;

    % Simulate the model
    [DA, DAads, DAtotal] = simulate_model([r, ke, ku, kads, kdes], time);

    % Clear previous plot
    cla(ax); 

    % Plot the simulated data
    plot(ax, time, DA, 'LineWidth', 2, 'DisplayName', 'Simulated DA');
    hold(ax, 'on');
    plot(ax, time, DAads, 'LineWidth', 2, 'DisplayName', 'Simulated DA-ads');
    plot(ax, time, DAtotal, 'LineWidth', 2, 'DisplayName', 'Simulated DA-Total');
    plot(ax, time, avg_data, 'r--', 'LineWidth', 2, 'DisplayName', 'Experimental');
    hold(ax, 'off');

    % Set labels and legend
    xlabel(ax, 'Time (s)');
    ylabel(ax, 'Oxidation Current (nA)');
    legend(ax, 'Location', 'best'); 

    % Update parameter table
    set(parameter_table, 'Data', {
    'Parameter', 'Value'; 
    'r', r; 
    'ke', ke; 
    'ku', ku; 
    'kads', kads; 
    'kdes', kdes;
    });
end