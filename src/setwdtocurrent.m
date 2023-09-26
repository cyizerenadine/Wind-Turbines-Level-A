function setwdtocurrent()
    currentMlxPath = mfilename('fullpath');
    [currentMlxDir, ~, ~] = fileparts(currentMlxPath);

    % Move up one directory level (parent directory)
    parentDir = fileparts(currentMlxDir);
    cd(parentDir);
    % cd(currentMlxDir);
end