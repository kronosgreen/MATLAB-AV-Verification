function jsonToMatrix
    folder = uigetdir();
    disp(folder);
    files = dir(fullfile(folder, '*.json'));
    
    for i = 1:size(files)
        disp(files(i).name)
        file = fopen(files(i).name, 'r');
        content = fscanf(file, "%s");
        disp(content);
        fclose(file);
    end
end