function [avg_data, time] = import_and_average_data()

    % Get file selection from user
    [filenames, pathname] = uigetfile({'*.txt', 'Text Files (*.txt)'; '*.*', 'All Files (*.*)'}, 'Select Data Files', 'MultiSelect', 'on');

    % Check for canceled selection
    if isequal(filenames, 0)
        avg_data = [];
        time = [];
        return;
    end

    % Handle single file selection
    if ~iscell(filenames)
        filenames = {filenames};
    end

    % Load and process data
    num_files = length(filenames);
    all_data = cell(num_files, 1); 
    first_file_loaded = false; 

    for i = 1:num_files
        % Construct full file path
        filepath = fullfile(pathname, filenames{i});

        % Load data, assuming two columns (time, current)
        data = load(filepath);

        % Check for unexpected format
        if size(data, 2) ~= 2
            warning(['File ', filenames{i}, ' has unexpected format (should have 2 columns)']);
            continue; 
        end

        % Remove 5 seconds of baseline (if applicable)
        if size(data, 1) > 5
            data = data(6:end, :); 
        end

        % Store the data
        all_data{i} = data; 

        % Extract time vector from the first file
        if ~first_file_loaded
            time = data(:, 1); 
            first_file_loaded = true;
        end
    end

    % Check if any files were loaded successfully
    if isempty(all_data)
        avg_data = [];
        time = [];
        return;
    end

    % Ensure all data has the same number of rows (should be redundant)
    min_length = min(cellfun(@(x) size(x, 1), all_data)); 
    for i = 1:num_files
        all_data{i} = all_data{i}(1:min_length, :); 
    end

    % Calculate average data
    avg_data = mean(cell2mat(all_data), 1);

    % Display the averaged data in a separate figure
    figure;
    plot(time, avg_data);
    xlabel('Time (s)');
    ylabel('Oxidation Current (nA)');
    title('Averaged Data');

end

