function curve_fitting_gui()

    % Call the modified import_and_average_data function
    [avg_data, time] = import_and_average_data();

    % Check if the user canceled file selection
    if isempty(avg_data)
        return; 
    end

    % Create GUI figure
    fig = figure('Name', 'Curve Fitting GUI', 'Position', [100, 100, 800, 600]); 

    % Create grid layout
    grid = gridlayout(fig, 3, 1); 

    % Row 1: Sliders
    ax1 = nexttile(grid, 1); 
    r_slider = uicontrol(ax1, 'Style', 'slider', 'Min', 0, 'Max', 500, 'Value', 240, 'Units', 'normalized', 'String', 'r');
    ke_slider = uicontrol(ax1, 'Style', 'slider', 'Min', 0, 'Max', 20, 'Value', 12, 'Units', 'normalized', 'String', 'ke');
    ku_slider = uicontrol(ax1, 'Style', 'slider', 'Min', 0, 'Max', 5, 'Value', 3, 'Units', 'normalized', 'String', 'ku');
    kads_slider = uicontrol(ax1, 'Style', 'slider', 'Min', 0, 'Max', 0.5, 'Value', 0.12, 'Units', 'normalized', 'String', 'kads');
    kdes_slider = uicontrol(ax1, 'Style', 'slider', 'Min', 0, 'Max', 0.2, 'Value', 0.06, 'Units', 'normalized', 'String', 'kdes');

    % Row 2: Parameter Table
    ax2 = nexttile(grid, 2); 
    parameter_table = uitable(ax2, 'Data', {
        'Parameter', 'Value'; 
        'r', r_slider.Value; 
        'ke', ke_slider.Value; 
        'ku', ku_slider.Value; 
        'kads', kads_slider.Value; 
        'kdes', kdes_slider.Value;
        });

    % Row 3: Plot
    ax3 = nexttile(grid, 3); 
    axes(ax3); 

    % Update plot callback
    update_plot_callback = @(hObject, eventdata) update_plot(r_slider, ke_slider, ku_slider, kads_slider, kdes_slider, ax3, time, avg_data, parameter_table);

    % Add listeners to sliders
    addlistener(r_slider, 'Value', 'PostSet', update_plot_callback);
    addlistener(ke_slider, 'Value', 'PostSet', update_plot_callback);
    addlistener(ku_slider, 'Value', 'PostSet', update_plot_callback);
    addlistener(kads_slider, 'Value', 'PostSet', update_plot_callback);
    addlistener(kdes_slider, 'Value', 'PostSet', update_plot_callback);

    % Initial plot
    update_plot_callback([], []);

    % Curve fitting button
    fit_button = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Fit Curve', 'Units', 'normalized', 'Position', [0.1, 0.05, 0.8, 0.05]);
    addlistener(fit_button, 'ButtonPress', @(hObject, eventdata) fit_curve(r_slider, ke_slider, ku_slider, kads_slider, kdes_slider, ax3, time, avg_data));

end

function update_plot(r_slider, ke_slider, ku_slider, kads_slider, kdes_slider, ax, time, avg_data, parameter_table)

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