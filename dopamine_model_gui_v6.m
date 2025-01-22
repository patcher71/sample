function dopamine_model_gui()

    % Create the main figure for the GUI
    hFig = figure('Position', [100, 100, 900, 700], 'MenuBar', 'none', 'Name', 'Dopamine Model Fitting', 'NumberTitle', 'off', 'Resize', 'off');

    % Create panels for each section
    hPanel1 = uipanel('Title', '1. Import and Display Data', 'Position', [0.05, 0.6, 0.9, 0.35]);
    hPanel2 = uipanel('Title', '2. Input Model Parameters', 'Position', [0.05, 0.5, 0.9, 0.1]);
    hPanel3 = uipanel('Title', '3. Overlay Modeled Parameters', 'Position', [0.05, 0.4, 0.9, 0.1]);
    hPanel4 = uipanel('Title', '4. Fit Data', 'Position', [0.05, 0.3, 0.9, 0.1]);
    hPanel5 = uipanel('Title', 'Parameter Comparison', 'Position', [0.05, 0.05, 0.9, 0.25]);

    % Panel 1: Import and Display Data
    uicontrol('Parent', hPanel1, 'Style', 'pushbutton', 'String', 'Import Data', 'Position', [20, 40, 80, 30], 'Callback', @importData);
    axes('Parent', hPanel1, 'Position', [0.25, 0.2, 0.7, 0.7]);  % Axis for data plot

    % Panel 2: Input Model Parameters
    uicontrol('Parent', hPanel2, 'Style', 'text', 'String', 'r:', 'Position', [10, 20, 20, 20]);
    hParamR = uicontrol('Parent', hPanel2, 'Style', 'edit', 'Position', [30, 20, 60, 25], 'String', '1');
    uicontrol('Parent', hPanel2, 'Style', 'text', 'String', 'ke:', 'Position', [100, 20, 20, 20]);
    hParamKE = uicontrol('Parent', hPanel2, 'Style', 'edit', 'Position', [120, 20, 60, 25], 'String', '1');
    uicontrol('Parent', hPanel2, 'Style', 'text', 'String', 'ku:', 'Position', [190, 20, 20, 20]);
    hParamKU = uicontrol('Parent', hPanel2, 'Style', 'edit', 'Position', [210, 20, 60, 25], 'String', '1');
    uicontrol('Parent', hPanel2, 'Style', 'text', 'String', 'kads:', 'Position', [280, 20, 40, 20]);
    hParamKads = uicontrol('Parent', hPanel2, 'Style', 'edit', 'Position', [320, 20, 60, 25], 'String', '1');
    uicontrol('Parent', hPanel2, 'Style', 'text', 'String', 'kdes:', 'Position', [390, 20, 40, 20]);
    hParamKdes = uicontrol('Parent', hPanel2, 'Style', 'edit', 'Position', [430, 20, 60, 25], 'String', '1');
    % Panel 3: Overlay Modeled Parameters
    uicontrol('Parent', hPanel3, 'Style', 'pushbutton', 'String', 'Overlay Model', 'Position', [20, 20, 100, 30], 'Callback', @overlayModel);
    uicontrol('Parent', hPanel3, 'Style', 'pushbutton', 'String', 'Clear Overlay', 'Position', [140, 20, 100, 30], 'Callback', @clearOverlay);
    uicontrol('Parent', hPanel3, 'Style', 'pushbutton', 'String', 'Accept Model Parameters', 'Position', [260, 20, 150, 30], 'Callback', @acceptModelParameters);

    % Panel 4: Fit Data
    uicontrol('Parent', hPanel4, 'Style', 'pushbutton', 'String', 'Fit Data', 'Position', [20, 20, 100, 30], 'Callback', @fitData);

    % Panel 5: Parameter Comparison
    uitable('Parent', hPanel5, 'Position', [20, 20, 820, 130], 'ColumnName', {'Parameter', 'Initial Value', 'Fitted Value', 'R²'}, 'ColumnWidth', {100, 200, 200, 200}, 'Tag', 'ParamTable');
    % Variables to store data and model parameters
    data = [];
    avg_time = [];
    avg_current = [];
    model_params = [1, 1, 1, 1, 1];
    hPlot = [];

    function importData(~, ~)
    [filenames, pathname] = uigetfile({'*.txt', 'Text Files (*.txt)'; '*.*', 'All Files (*.*)'}, 'Select Data Files', 'MultiSelect', 'on');
    if isequal(filenames, 0)
        return;
    end

    % Clear previous plot
    cla(hPanel1);

    all_time = [];
    all_current = [];
    shortest_file_length = inf;

    % First pass to determine the shortest file length
    for i = 1:length(filenames)
        filepath = fullfile(pathname, filenames{i});
        fileID = fopen(filepath, 'r');
        data = fscanf(fileID, '%f %f');
        fclose(fileID);
        data = reshape(data, 2, length(data) / 2)';
        time = data(:, 1);  % Time is already in seconds
        current = data(:, 2);
        shortest_file_length = min(shortest_file_length, length(time));
    end

    % Second pass to truncate data to the shortest length and accumulate
    for i = 1:length(filenames)
        filepath = fullfile(pathname, filenames{i});
        fileID = fopen(filepath, 'r');
        data = fscanf(fileID, '%f %f');
        fclose(fileID);
        data = reshape(data, 2, length(data) / 2)';
        time = data(:, 1);  % Time is already in seconds
        current = data(:, 2);
        if length(time) >= shortest_file_length
            time = time(1:shortest_file_length);
            current = current(1:shortest_file_length);
        end
        all_time = [all_time; time'];
        all_current = [all_current; current'];
    end

    % Calculate average time and current
    avg_time = mean(all_time, 1);
    avg_current = mean(all_current, 1);

    % Plot the averaged data
    axes(hPanel1);
    hPlot = plot(avg_time, avg_current, 'b', 'DisplayName', 'Averaged Data');
    xlabel('Time (s)');
    ylabel('Oxidation Current (nA)');
    title('Averaged Data');
    legend;
end


    function overlayModel(~, ~)
        model_params = [str2double(get(hParamR, 'String')), str2double(get(hParamKE, 'String')), str2double(get(hParamKU, 'String')), str2double(get(hParamKads, 'String')), str2double(get(hParamKdes, 'String'))];
        fitted_curve = model(model_params, avg_time);
        hold on;
        plot(avg_time, fitted_curve, 'r--', 'DisplayName', 'Modeled Data');
        legend;
    end

    function clearOverlay(~, ~)
        if ~isempty(hPlot)
            delete(findall(hPanel1, 'type', 'line', 'DisplayName', 'Modeled Data'));
            delete(findall(hPanel1, 'type', 'line', 'DisplayName', 'Fitted Data'));
        end
    end

    function acceptModelParameters(~, ~)
        model_params = [str2double(get(hParamR, 'String')), str2double(get(hParamKE, 'String')), str2double(get(hParamKU, 'String')), str2double(get(hParamKads, 'String')), str2double(get(hParamKdes, 'String'))];
    end
    
  function fitData(~, ~)
    options = optimoptions('lsqnonlin', 'Display', 'off');
    time_offset = 5;  % Signal of interest starts at 5 seconds
    fitted_params = lsqnonlin(@(params) model(params, avg_time - time_offset) - avg_current, model_params, [0, 0, 0, 0, 0], [inf, inf, inf, inf, inf], options);
    fitted_curve = model(fitted_params, avg_time - time_offset);
    hold on;
    plot(avg_time, fitted_curve, 'g-', 'DisplayName', 'Fitted Data');
    legend;

    % Update the input fields with the fitted parameters
    set(hParamR, 'String', num2str(fitted_params(1)));
    set(hParamKE, 'String', num2str(fitted_params(2)));
    set(hParamKU, 'String', num2str(fitted_params(3)));
    set(hParamKads, 'String', num2str(fitted_params(4)));
    set(hParamKdes, 'String', num2str(fitted_params(5)));

    % Calculate r² value
    r2 = 1 - sum((avg_current - fitted_curve).^2) / sum((avg_current - mean(avg_current)).^2);

    % Update the parameter table
    param_table = findobj(hPanel5, 'Tag', 'ParamTable');
    data = { 'r', model_params(1), fitted_params(1), ''; 
             'ke', model_params(2), fitted_params(2), ''; 
             'ku', model_params(3), fitted_params(3), ''; 
             'kads', model_params(4), fitted_params(4), ''; 
             'kdes', model_params(5), fitted_params(5), ''; 
             'R²', '', r2 };
    set(param_table, 'Data', data);
end

function DAmeasured = model(params, t)
    function dydt = diff_eqs(t, y, params)
        DA = y(1);
        DAads = y(2);
        r = params(1);
        ke = params(2);
        ku = params(3);
        kads = params(4);
        kdes = params(5);
        dydt = [r * exp(-ke * t) - ku * DA;
                kads * DA - kdes * DAads];
    end

    [~, y] = ode45(@(t, y) diff_eqs(t, y, params), t, [0, 0]);
    DAmeasured = y(:, 1) + y(:, 2);
end


end
