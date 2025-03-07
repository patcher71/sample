% --- Executes on button press in getDataButton.
function getDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to getDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
    fig = findobj('Tag', 'CurveFit_v1'); % Replace 'figure1' with your figure's tag
    ax = findobj(fig, 'Tag', 'axes1'); % Search within the figure
    startTimeEdit = findobj('Tag', 'startTimeEdit'); % Replace 'startTimeEdit' with your edit text tag
    endTimeEdit = findobj('Tag', 'endTimeEdit'); % Replace 'endTimeEdit' with your edit text tag

    % Check if axes object was found
    if isempty(ax) || ~ishandle(ax)
        disp('Error: Axes object not found!');
        return; % Exit the function if axes is not found
    end

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