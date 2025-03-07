function saveData(src, event)
    fig = gcbf;
    fitTime = getappdata(fig, 'fitTime');
    fitCurrent = getappdata(fig, 'fitCurrent');
    fittedCurve = getappdata(fig, 'fittedCurve');
    risingParams = getappdata(fig, 'risingParams');
    decayParams = getappdata(fig, 'decayParams');
    Rsq = getappdata(fig, 'Rsq');
    RT50 = getappdata(fig, 'RT50');
    DT50 = getappdata(fig, 'DT50');
    DT20 = getappdata(fig, 'DT20');
    indices = getappdata(fig, 'indices');

    % Save data and fitted curve to a text file
    [dataFileName, dataPathName] = uiputfile('*.txt', 'Save Data and Fitted Curve');
    if dataFileName ~= 0
        fullDataFileName = fullfile(dataPathName, dataFileName);
        dataToSave = [fitTime, fitCurrent, fittedCurve(indices)]; % No need to transpose here
        save(fullDataFileName, 'dataToSave', '-ascii');
    end

    % Save parameters to a separate text file
    [paramFileName, paramPathName] = uiputfile('*.txt', 'Save Parameters');
    if paramFileName ~= 0
        fullParamFileName = fullfile(paramPathName, paramFileName);
        paramData = {['Rising: A=', num2str(risingParams(1)), ', k=', num2str(risingParams(2)), ', C=', num2str(risingParams(3))], ...
                     ['Decay: A=', num2str(decayParams(1)), ', k=', num2str(decayParams(2)), ', C=', num2str(decayParams(3))], ...
                     ['RT50=', num2str(RT50)], ...
                     ['DT50=', num2str(DT50)], ...
                     ['DT20=', num2str(DT20)], ...
                     ['R^2=', num2str(Rsq)]};
        fileID = fopen(fullParamFileName, 'w');
        for i = 1:length(paramData)
            fprintf(fileID, '%s\n', paramData{i});
        end
        fclose(fileID);
    end
end