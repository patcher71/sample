function clearFit(src, event)
    fig = gcbf;
    fittedCurveHandle = getappdata(fig, 'fittedCurveHandle');
    if ~isempty(fittedCurveHandle) && isvalid(fittedCurveHandle)
        delete(fittedCurveHandle);
        setappdata(fig, 'fittedCurveHandle', []);
        title(gca, ''); % Clear title
    end
end