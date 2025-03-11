function fitWithCursors_v7()
    % Create figure and grid layout
    fig = uifigure('Name', 'Fit with Cursors');
    grid = uigridlayout(fig, [8, 2]); % Adjusted to 8 rows
    grid.RowHeight = {30, '1x', 30, 30, 'fit', 30, 30, 30}; % Adjusted row heights

    % Open Files Button
    openFilesButton = uibutton(grid, 'Text', 'Open I vs. T Files', 'ButtonPushedFcn', @openFiles);
    openFilesButton.Layout.Row = 1;
    openFilesButton.Layout.Column = [1 2];

    % Axes
    ax = uiaxes(grid);
    ax.Layout.Row = 2;
    ax.Layout.Column = [1 2];

    % Start Time Input
    startTimeLabel = uilabel(grid, 'Text', 'Start Time (s):');
    startTimeLabel.Layout.Row = 3;
    startTimeLabel.Layout.Column = 1;
    startTimeEdit = uieditfield(grid, 'numeric', 'Value', 0, 'ValueChangedFcn', @updateCursors);
    startTimeEdit.Layout.Row = 3;
    startTimeEdit.Layout.Column = 2;

    % End Time Input
    endTimeLabel = uilabel(grid, 'Text', 'End Time (s):');
    endTimeLabel.Layout.Row = 4;
    endTimeLabel.Layout.Column = 1;
    endTimeEdit = uieditfield(grid, 'numeric', 'Value', 1, 'ValueChangedFcn', @updateCursors);
    endTimeEdit.Layout.Row = 4;
    endTimeEdit.Layout.Column = 2;

    % Fit Data Button
    fitDataButton = uibutton(grid, 'Text', 'Fit Data', 'ButtonPushedFcn', @fitData);
    fitDataButton.Layout.Row = 5;
    fitDataButton.Layout.Column = 1;

    % Parameters Table
    paramTable = uitable(grid, 'Data', {}, 'ColumnName', {'Parameter', 'Value'});
    paramTable.Layout.Row = 5;
    paramTable.Layout.Column = 2;

    % Save Parameters Button
    saveParamsButton = uibutton(grid, 'Text', 'Save Parameters', 'ButtonPushedFcn', @saveParams);
    saveParamsButton.Layout.Row = 6;
    saveParamsButton.Layout.Column = 1;

    % Save Data+Curve Button
    saveDataCurveButton = uibutton(grid, 'Text', 'Save Data+Curve', 'ButtonPushedFcn', @saveDataCurve);
    saveDataCurveButton.Layout.Row = 6;
    saveDataCurveButton.Layout.Column = 2;

    % Clear Data Button
    clearDataButton = uibutton(grid, 'Text', 'Clear Data', 'ButtonPushedFcn', @clearData);
    clearDataButton.Layout.Row = 7;
    clearDataButton.Layout.Column = [1 2];

    % Fit Data to Restricted Diffusion Model Button
    fitDiffusionButton = uibutton(grid, 'Text', 'Fit to Restricted Diffusion', 'ButtonPushedFcn', @fitDiffusion);
    fitDiffusionButton.Layout.Row = 8;
    fitDiffusionButton.Layout.Column = [1 2];

    % Callback function for the button
    function openFiles(~, ~)
        [fileNames, pathName] = uigetfile('*.txt', 'Select data files', 'MultiSelect', 'on');
        if isequal(fileNames, 0)
            disp('User canceled file selection.');
            return;
        end
        if ~iscell(fileNames)
            fileNames = {fileNames};
        end
        allTime = {};
        allCurrent = {};
        for i = 1:length(fileNames)
            fullFileName = fullfile(pathName, fileNames{i});
            data = readmatrix(fullFileName);
            allTime{i} = data(:, 1);
            allCurrent{i} = data(:, 2);
        end
        minLen = Inf;
        for i = 1:length(allTime)
            minLen = min(minLen, length(allTime{i}));
        end
        uniqueTime = allTime{1}(1:minLen);
        averageCurrent = zeros(minLen, 1);
        for i = 1:length(allTime)
            averageCurrent = averageCurrent + allCurrent{i}(1:minLen);
        end
        averageCurrent = averageCurrent / length(allTime);
        % Plot data
        plot(ax, uniqueTime, averageCurrent, 'o');
        hold(ax, 'on');
        % Store data in appdata
        setappdata(fig, 'uniqueTime', uniqueTime);
        setappdata(fig, 'averageCurrent', averageCurrent);
        % Update cursors
        startTimeEdit.Value = uniqueTime(1);
        endTimeEdit.Value = uniqueTime(end);
        % Create cursors after axes is created
        cursor1 = line(ax, [uniqueTime(1), uniqueTime(1)], [min(averageCurrent), max(averageCurrent)], 'Color', 'r', 'LineWidth', 2);
        cursor2 = line(ax, [uniqueTime(end), uniqueTime(end)], [min(averageCurrent), max(averageCurrent)], 'Color', 'b', 'LineWidth', 2);
        % Store cursor handles in appdata
        setappdata(fig, 'cursor1', cursor1);
        setappdata(fig, 'cursor2', cursor2);
        % Call updateCursors after creating cursors
        updateCursors();
        % Clear table and fitted curves
        paramTable.Data = {};
        if isappdata(fig, 'fittedCurveHandle')
            delete(getappdata(fig, 'fittedCurveHandle'));
            rmappdata(fig, 'fittedCurveHandle');
        end
    end

    % Callback function to update cursors
    function updateCursors(~, ~)
        uniqueTime = getappdata(fig, 'uniqueTime');
        averageCurrent = getappdata(fig, 'averageCurrent');
        startTime = startTimeEdit.Value;
        endTime = endTimeEdit.Value;
        % Get cursor handles from appdata
        cursor1 = getappdata(fig, 'cursor1');
        cursor2 = getappdata(fig, 'cursor2');
        % Adjust cursor positions
        cursor1.XData = [startTime, startTime];
        cursor2.XData = [endTime, endTime];
        cursor1.YData = [min(averageCurrent), max(averageCurrent)];
        cursor2.YData = [min(averageCurrent), max(averageCurrent)];
    end

    % Callback function to fit data
    function fitData(~, ~)
        uniqueTime = getappdata(fig, 'uniqueTime');
        averageCurrent = getappdata(fig, 'averageCurrent');
        startTime = startTimeEdit.Value;
        endTime = endTimeEdit.Value;
        % Extract data within the selected range
        timeRange = uniqueTime >= startTime & uniqueTime <= endTime;
        fitTime = uniqueTime(timeRange);
        fitCurrent = averageCurrent(timeRange);
        % Find the peak index
        [peakValue, peakIndex] = max(fitCurrent);
        peakTime = fitTime(peakIndex);
        % Rising phase data
        risingIndices = fitTime <= peakTime;
        risingTime = fitTime(risingIndices);
        risingCurrent = fitCurrent(risingIndices);
        risingTimeShifted = risingTime - min(risingTime);
        % Decay phase data
        decayIndices = fitTime >= peakTime;
        decayTime = fitTime(decayIndices);
        decayCurrent = fitCurrent(decayIndices);
        decayTimeShifted = decayTime - peakTime;
        % Rising phase fit (simple exponential)
        risingModelFun = @(params, t) params(1) * (1 - exp(-params(2) * t)) + params(3);
        A_rising_initial = peakValue - min(risingCurrent);
        k_rising_initial = 10;
        C_rising_initial = min(risingCurrent);
        risingParamsInitial = [A_rising_initial, k_rising_initial, C_rising_initial];
        try
            risingParams = lsqcurvefit(risingModelFun, risingParamsInitial, risingTimeShifted, risingCurrent);
        catch ME
            fprintf('Error fitting rising phase: %s\n', ME.message);
            return;
        end
        % Decay phase fit (exponential decay)
        decayModelFun = @(params, t) params(1) * exp(-params(2) * t) + params(3);
        A_decay_initial = peakValue - mean(decayCurrent(end - min(10, length(decayCurrent)):end));
        k_decay_initial = 0.5;
        C_decay_initial = mean(decayCurrent(end - min(10, length(decayCurrent)):end));
        decayParamsInitial = [A_decay_initial, k_decay_initial, C_decay_initial];
        try
            decayParams = lsqcurvefit(decayModelFun, decayParamsInitial, decayTimeShifted, decayCurrent);
        catch ME
            fprintf('Error fitting decay phase: %s\n', ME.message);
            return;
        end
        % Combine fits
        fittedCurve = zeros(size(uniqueTime));
        for i = 1:length(uniqueTime)
            if uniqueTime(i) <= peakTime
                if uniqueTime(i) >= min(risingTime)
                    fittedCurve(i) = risingModelFun(risingParams, uniqueTime(i) - min(risingTime));
                end
            else
                if uniqueTime(i) <= max(decayTime)
                    fittedCurve(i) = decayModelFun(decayParams, uniqueTime(i) - peakTime);
                end
            end
        end
        % Plot the fitted curve on the same axes
        if isappdata(fig, 'fittedCurveHandle') && isvalid(getappdata(fig, 'fittedCurveHandle'))
            delete(getappdata(fig, 'fittedCurveHandle'));
        end
        fittedCurveHandle = plot(ax, uniqueTime, fittedCurve, 'r-', 'DisplayName', 'Fitted Curve');
        setappdata(fig, 'fittedCurveHandle', fittedCurveHandle);
        % Calculate R-squared
        fittedCurrentFit = zeros(size(fitCurrent));
        for i = 1:length(fitCurrent)
            if fitTime(i) <= peakTime
                fittedCurrentFit(i) = risingModelFun(risingParams, fitTime(i) - min(risingTime));
            else
                fittedCurrentFit(i) = decayModelFun(decayParams, fitTime(i) - peakTime);
            end
        end
        SSres = sum((fitCurrent - fittedCurrentFit) .^ 2);
        SStot = sum((fitCurrent - mean(fitCurrent)) .^ 2);
        Rsq = 1 - SSres / SStot;
        % Display parameters in table
        paramTable.Data = {
            'Rising A', risingParams(1);
            'Rising k', risingParams(2);
            'Rising C', risingParams(3);
            'Decay A', decayParams(1);
            'Decay k', decayParams(2);
            'Decay C', decayParams(3);
            'R^2', Rsq
        };
    end

    % Callback function to fit data to restricted diffusion model
    function fitDiffusion(~, ~)
        uniqueTime = getappdata(fig, 'uniqueTime');
        averageCurrent = getappdata(fig, 'averageCurrent');
        startTime = startTimeEdit.Value;
        endTime = endTimeEdit.Value;

        % Extract data within the selected range
        timeRange = uniqueTime >= startTime & uniqueTime <= endTime;
        time_fit = uniqueTime(timeRange);
        fitCurrent = averageCurrent(timeRange);

        % Ensure time_fit is strictly increasing
        [time_fit, sortIdx] = sort(time_fit);
        fitCurrent = fitCurrent(sortIdx);

        % Find the peak index
        [peakValue, peakIndex] = max(fitCurrent);
        peakTime = time_fit(peakIndex);

        % Rising phase data
        risingIndices = time_fit <= peakTime;
        risingTime = time_fit(risingIndices);
        risingCurrent = fitCurrent(risingIndices);
        risingTimeShifted = risingTime - min(risingTime);

        % Decay phase data
        decayIndices = time_fit >= peakTime;
        decayTime = time_fit(decayIndices);
        decayCurrent = fitCurrent(decayIndices);
        decayTimeShifted = decayTime - peakTime;

        % Rising phase fit (simple exponential)
        risingModelFun = @(params, t) params(1) * (1 - exp(-params(2) * t)) + params(3);
        A_rising_initial = peakValue - min(risingCurrent);
        k_rising_initial = 10;
        C_rising_initial = min(risingCurrent);
        risingParamsInitial = [A_rising_initial, k_rising_initial, C_rising_initial];
        try
            risingParams = lsqcurvefit(risingModelFun, risingParamsInitial, risingTimeShifted, risingCurrent);
            ke_initial = risingParams(2); % Extract ke_initial
        catch ME
            fprintf('Error fitting rising phase: %s\n', ME.message);
            return;
        end
        % Decay phase fit (exponential decay)
        decayModelFun = @(params, t) params(1) * exp(-params(2) * t) + params(3);
        A_decay_initial = peakValue - mean(decayCurrent(end - min(10, length(decayCurrent)):end));
        k_decay_initial = 0.5;
        C_decay_initial = mean(decayCurrent(end - min(10, length(decayCurrent)):end));
        decayParamsInitial = [A_decay_initial, k_decay_initial, C_decay_initial];
        try
            decayParams = lsqcurvefit(decayModelFun, decayParamsInitial, decayTimeShifted, decayCurrent);
            ku_initial = decayParams(2); % Extract ku_initial
        catch ME
            fprintf('Error fitting decay phase: %s\n', ME.message);
            return;
        end

        % Get A_rising from the rising phase fit
        A_rising = risingParams(1);

        % Estimate r_initial
        r_initial = A_rising * ke_initial;

        % Initial guesses for kads and kdes
        kads_initial = 0.1; % Experiment with different values
        kdes_initial = 0.05; % Experiment with different values

        % Fit the restricted diffusion model
        paramsInitial = [ke_initial, ku_initial, r_initial, kads_initial, kdes_initial];
        [paramsFitted, Rsq, modelFun] = restrictedDiffusionFit(time_fit, fitCurrent, ke_initial, ku_initial, paramsInitial);

        % Display parameters
        paramTable.Data = {
            'ke', paramsFitted(1);
            'ku', paramsFitted(2);
            'r', paramsFitted(3);
            'kads', paramsFitted(4);
            'kdes', paramsFitted(5);
            'R^2', Rsq
        };

        % Plot the fitted curve
        if isappdata(fig, 'fittedCurveHandle') && isvalid(getappdata(fig, 'fittedCurveHandle'))
            delete(getappdata(fig, 'fittedCurveHandle'));
        end

        % Generate data for the fitted curve
        data_fit = modelFun(paramsFitted, time_fit); % Use the fitted parameters

        fittedCurveHandle = plot(ax, time_fit, data_fit, 'r-', 'DisplayName', 'Restricted Diffusion Fit');
        setappdata(fig, 'fittedCurveHandle', fittedCurveHandle);
    end

    % Callback function to save parameters
    function saveParams(~, ~)
        params = paramTable.Data;
        [file, path] = uiputfile('parameters.txt');
        if isequal(file, 0) || isequal(path, 0)
            disp('User selected Cancel')
        else
            fid = fopen(fullfile(path, file), 'w');
            if fid == -1
                error('Error opening file for writing.');
            end
            for i = 1:size(params, 1)
                fprintf(fid, '%s\t%f\n', params{i, 1}, params{i, 2});
            end
            fclose(fid);
        end
    end

    % Callback function to save data and fitted curve

    function saveDataCurve(~, ~)
    uniqueTime = getappdata(fig, 'uniqueTime');
    averageCurrent = getappdata(fig, 'averageCurrent');
    if isappdata(fig, 'fittedCurveHandle')
        fittedCurve = getappdata(fig, 'fittedCurveHandle').YData;
        dataToSave = [uniqueTime, averageCurrent, fittedCurve'];
        [file, path] = uiputfile('data_and_curve.txt');
        if isequal(file, 0) || isequal(path, 0)
            disp('User selected Cancel')
        else
            fid = fopen(fullfile(path, file), 'w');
            if fid == -1
                error('Error opening file for writing.');
            end
            fprintf(fid, 'Time\tCurrent\tFitted Curve\n');
            for i = 1:size(dataToSave, 1)
                fprintf(fid, '%f\t%f\t%f\n', dataToSave(i, 1), dataToSave(i, 2), dataToSave(i, 3));
            end
            fclose(fid);
        end
    end


% Callback function to clear data
function clearData(~, ~)
    % Clear the plot
    cla(ax);
    % Clear the table
    paramTable.Data = {};
    % Remove data from appdata
    if isappdata(fig, 'uniqueTime')
        rmappdata(fig, 'uniqueTime');
    end
    if isappdata(fig, 'averageCurrent')
        rmappdata(fig, 'averageCurrent');
    end
    if isappdata(fig, 'fittedCurveHandle')
        delete(getappdata(fig, 'fittedCurveHandle'));
        rmappdata(fig, 'fittedCurveHandle');
    end
end