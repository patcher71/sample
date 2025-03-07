function fitWithCursors()
    % Load and process data (replace with your data loading)
    [fileNames, pathName] = uigetfile('*.txt', 'Select data files', 'MultiSelect', 'on');
    if isequal(fileNames, 0)
        disp('User canceled file selection.');
        return;
    end
    if ~iscell(fileNames)
        fileNames = {fileNames};
    end
    allTime = {}; allCurrent = {};
    for i = 1:length(fileNames)
        fullFileName = fullfile(pathName, fileNames{i});
        data = readmatrix(fullFileName);
        allTime{i} = data(:, 1); allCurrent{i} = data(:, 2);
    end
    minLen = Inf; for i = 1:length(allTime), minLen = min(minLen, length(allTime{i})); end
    uniqueTime = allTime{1}(1:minLen); averageCurrent = zeros(minLen, 1);
    for i = 1:length(allTime), averageCurrent = averageCurrent + allCurrent{i}(1:minLen); end
    averageCurrent = averageCurrent / length(allTime);

    % Create figure and axes
    fig = figure('Name', 'Fit with Cursors', 'NumberTitle', 'off', 'Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8]); % Larger figure
    figPos = get(fig, 'OuterPosition'); % Get figure size

    % Get screen size
    screenSize = get(0, 'ScreenSize');

    ax = axes('Parent', fig, 'Position', [0.3, 0.3, 0.6, 0.6]); % Adjust axes position
    plot(ax, uniqueTime, averageCurrent, 'o');
    hold(ax, 'on');

    % Input fields for start and end times
    uicontrol('Style', 'text', 'String', 'Start cursor time (s)', 'Position', [figPos(3) * 0.3, figPos(4) * 0.1, figPos(3) * 0.15, figPos(4) * 0.03], 'Units', 'pixels', 'FontSize', 12);
    startTimeEdit = uicontrol('Style', 'edit', 'Position', [figPos(3) * 0.45, figPos(4) * 0.1, figPos(3) * 0.08, figPos(4) * 0.03], 'Units', 'pixels', 'String', '5', 'FontSize', 12);
    uicontrol('Style', 'text', 'String', 'End cursor time (s)', 'Position', [figPos(3) * 0.55, figPos(4) * 0.1, figPos(3) * 0.15, figPos(4) * 0.03], 'Units', 'pixels', 'FontSize', 12);
    endTimeEdit = uicontrol('Style', 'edit', 'Position', [figPos(3) * 0.7, figPos(4) * 0.1, figPos(3) * 0.08, figPos(4) * 0.03], 'Units', 'pixels', 'String', num2str(uniqueTime(end)), 'FontSize', 12);

    % Buttons
    fitDataButton = uicontrol('Style', 'pushbutton', 'String', 'Fit Data', 'Position', [figPos(3) * 0.3, figPos(4) * 0.2, figPos(3) * 0.1, figPos(4) * 0.05], 'Units', 'pixels', 'Callback', @fitData, 'FontSize', 12);
    clearFitButton = uicontrol('Style', 'pushbutton', 'String', 'Clear Fit', 'Position', [figPos(3) * 0.45, figPos(4) * 0.2, figPos(3) * 0.1, figPos(4) * 0.05], 'Units', 'pixels', 'Callback', {@clearFit, ax}, 'FontSize', 12); % Pass ax to clearFit
    saveDataButton = uicontrol('Style', 'pushbutton', 'String', 'Save Data and Parameters', 'Position', [figPos(3) * 0.6, figPos(4) * 0.2, figPos(3) * 0.2, figPos(4) * 0.05], 'Units', 'pixels', 'Callback', @saveData, 'FontSize', 12);

    % Table to display fit parameters
    tableData = {'Rise', 'A = '; ' ', 'k = '; ' ', 'C = '; ' ', '50% RT = '; 'Decay', 'A = '; ' ', 'k = '; ' ', 'C = '; ' ', '50% Decay = '; ' ', '80% Decay = '; 'R^2', ' '};
    paramTable = uitable('Parent', fig, 'Data', tableData, 'ColumnName', {'Parameter', 'Value'}, 'Position', [figPos(3) * 0.05, figPos(4) * 0.3, figPos(3) * 0.2, figPos(4) * 0.5], 'Units', 'pixels', 'FontSize', 12);

    % Store handles
    setappdata(fig, 'ax', ax); % Store ax
    setappdata(fig, 'startTimeEdit', startTimeEdit);
    setappdata(fig, 'endTimeEdit', endTimeEdit);
    setappdata(fig, 'paramTable', paramTable);

    % Create cursors
    cursor1 = line(ax, [str2double(get(startTimeEdit, 'String')), str2double(get(startTimeEdit, 'String'))], [min(averageCurrent), max(averageCurrent)], 'Color', 'r', 'LineWidth', 2);
    cursor2 = line(ax, [str2double(get(endTimeEdit, 'String')), str2double(get(endTimeEdit, 'String'))], [min(averageCurrent), max(averageCurrent)], 'Color', 'b', 'LineWidth', 2);

    % Store data and cursors in appdata
    setappdata(fig, 'uniqueTime', uniqueTime);
    setappdata(fig, 'averageCurrent', averageCurrent);
    setappdata(fig, 'cursor1', cursor1);
    setappdata(fig, 'cursor2', cursor2);
    setappdata(fig, 'fittedCurveHandle', []);
end