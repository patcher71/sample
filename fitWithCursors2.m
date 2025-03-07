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
    fig = figure('Name', 'Fit with Cursors', 'NumberTitle', 'off'); 

    ax = axes('Parent', fig); 
    plot(ax, uniqueTime, averageCurrent, 'o');
    hold(ax, 'on');

    % Input fields for start and end times
    uicontrol('Style', 'text', 'String', 'Start cursor time (s)');
    startTimeEdit = uicontrol('Style', 'edit', 'String', '5');
    uicontrol('Style', 'text', 'String', 'End cursor time (s)');
    endTimeEdit = uicontrol('Style', 'edit', 'String', num2str(uniqueTime(end)));

    % Buttons
    fitDataButton = uicontrol('Style', 'pushbutton', 'String', 'Fit Data', 'Callback', @fitData);
    clearFitButton = uicontrol('Style', 'pushbutton', 'String', 'Clear Fit', 'Callback', {@clearFit, ax}); 
    saveDataButton = uicontrol('Style', 'pushbutton', 'String', 'Save Data and Parameters', 'Callback', @saveData);

    % Table to display fit parameters
    tableData = {'Rise', 'A = '; ' ', 'k = '; ' ', 'C = '; ' ', '50% RT = '; 'Decay', 'A = '; ' ', 'k = '; ' ', 'C = '; ' ', '50% Decay = '; ' ', '80% Decay = '; 'R^2', ' '};
    paramTable = uitable('Parent', fig, 'Data', tableData, 'ColumnName', {'Parameter', 'Value'});

    % Store handles
    setappdata(fig, 'ax', ax); 
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
    setappdata(fig, 'fittedCurveHandle',[]);
end