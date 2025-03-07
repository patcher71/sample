function fitData(src, event)
    fig = gcbf;
    uniqueTime = getappdata(fig, 'uniqueTime');
    averageCurrent = getappdata(fig, 'averageCurrent');
    cursor1 = getappdata(fig, 'cursor1');
    cursor2 = getappdata(fig, 'cursor2');
    startTimeEdit = getappdata(fig, 'startTimeEdit');
    endTimeEdit = getappdata(fig, 'endTimeEdit');
    fittedCurveHandle = getappdata(fig, 'fittedCurveHandle');

    startTime = str2double(get(startTimeEdit, 'String'));
    endTime = str2double(get(endTimeEdit, 'String'));

    % Update cursors
    set(cursor1, 'XData', [startTime, startTime]);
    set(cursor2, 'XData', [endTime, endTime]);

    indices = uniqueTime >= min(startTime, endTime) & uniqueTime <= max(startTime, endTime);
    fitTime = uniqueTime(indices);
    fitCurrent = averageCurrent(indices);

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
    A_decay_initial = peakValue - mean(decayCurrent(end-min(10,length(decayCurrent)):end));
    k_decay_initial = 0.5;
    C_decay_initial = mean(decayCurrent(end-min(10,length(decayCurrent)):end));
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

    % Calculate RT50, DT50, and DT80
    halfPeakValue = peakValue / 2;
    eightyPeakValue = peakValue * 0.2;

    RT50 = interp1(risingCurrent, risingTime, halfPeakValue) - min(risingTime);

    % Handle duplicate values in decayCurrent
    [uniqueDecayCurrent, uniqueIndices] = unique(decayCurrent);
    uniqueDecayTime = decayTime(uniqueIndices);

    % Interpolate DT50 and DT80
    if halfPeakValue >= min(uniqueDecayCurrent) && halfPeakValue <= max(uniqueDecayCurrent)
        DT50 = interp1(uniqueDecayCurrent, uniqueDecayTime, halfPeakValue) - peakTime;
    else
        DT50 = NaN; % Handle edge case
    end

    if eightyPeakValue >= min(uniqueDecayCurrent) && eightyPeakValue <= max(uniqueDecayCurrent)
        DT80 = interp1(uniqueDecayCurrent, uniqueDecayTime, eightyPeakValue) - peakTime;
    else
        DT80 = NaN; % Handle edge case
    end
    
    % Plot the fitted curve
    if ~isempty(fittedCurveHandle) && isvalid(fittedCurveHandle)
        delete(fittedCurveHandle);
    end
    fittedCurveHandle = plot(gca, uniqueTime, fittedCurve, 'r-', 'DisplayName', 'Fitted Curve');
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

    SSres = sum((fitCurrent - fittedCurrentFit).^2);
    SStot = sum((fitCurrent - mean(fitCurrent)).^2);
    Rsq = 1 - SSres/SStot;

   % Update table with fit parameters
    paramTable = getappdata(fig, 'paramTable');
    tableData = get(paramTable, 'Data');
    tableData{2, 2} = num2str(risingParams(1)); % Rise A
    tableData{3, 2} = num2str(risingParams(2)); % Rise k
    tableData{4, 2} = num2str(risingParams(3)); % Rise C
    tableData{5, 2} = num2str(RT50); % 50% RT
    tableData{7, 2} = num2str(decayParams(1)); % Decay A
    tableData{8, 2} = num2str(decayParams(2)); % Decay k
    tableData{9, 2} = num2str(decayParams(3)); % Decay C
    tableData{10, 2} = num2str(DT50); % 50% Decay
    tableData{11, 2} = num2str(DT20); % 80% Decay
    tableData{12, 2} = num2str(Rsq); % R^2
    set(paramTable, 'Data', tableData);

    % Store indices in appdata
    setappdata(fig, 'indices', indices);
    
    % Store data for saving
    setappdata(fig, 'fitTime', fitTime);
    setappdata(fig, 'fitCurrent', fitCurrent);
    setappdata(fig, 'fittedCurve', fittedCurve);
    setappdata(fig, 'risingParams', risingParams);
    setappdata(fig, 'decayParams', decayParams);
    setappdata(fig, 'Rsq', Rsq);
    setappdata(fig, 'RT50', RT50);
    setappdata(fig, 'DT50', DT50);
    setappdata(fig, 'DT80', DT80);;
end