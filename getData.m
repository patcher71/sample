function getData(src, event)
    % Load and process data
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

    % Find GUI elements using their tags
    fig = findobj('Tag', 'figure1'); % Replace 'figure1' with your figure's tag
    ax = findobj('Tag', 'axes1'); % Replace 'axes1' with your axes' tag
    startTimeEdit = findobj('Tag', 'startTimeEdit'); % Replace 'startTimeEdit' with your edit text tag
    endTimeEdit = findobj('Tag', 'endTimeEdit'); % Replace 'endTimeEdit' with your edit text tag

    % Plot initial data
    plot(ax, uniqueTime, averageCurrent, 'o');
    hold(ax, 'on');

    % Store handles
    setappdata(fig, 'ax', ax);
    setappdata(fig, 'startTimeEdit', startTimeEdit);
    setappdata(fig, 'endTimeEdit', endTimeEdit);

    % Create cursors
    cursor1 = line(ax, [str2double(get(startTimeEdit, 'String')), str2double(get(startTimeEdit, 'String'))], [min(averageCurrent), max(averageCurrent)], 'Color', 'r', 'LineWidth', 2);
    cursor2 = line(ax, [str2double(get(endTimeEdit, 'String')), str2double(get(endTimeEdit, 'String'))], [min(averageCurrent), max(averageCurrent)], 'Color', 'b', 'LineWidth', 2);

    % Store data and cursors in appdata
    setappdata(fig, 'uniqueTime', uniqueTime);
    setappdata(fig, 'averageCurrent', averageCurrent);
    setappdata(fig, 'cursor1', cursor1);
    setappdata(fig, 'cursor2', cursor2);
    setappdata(fig, 'fittedCurveHandle',);
end