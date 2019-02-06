clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);
keepercol = 1;
for f = 1:count;
    B = matfiles(f, 1).name;
    currkeeper = load(B);
    name = char(fieldnames(currkeeper));
    holdercells(1, f) = {currkeeper.(name)};
end

for loader = 1:size(holdercells, 2);
    tempkeeper = holdercells{1, loader};
    for col = 1:size(tempkeeper, 2);
        anglekeeper(loader, col) = tempkeeper(1, col);
    end
end

anglekeeper(anglekeeper == 0) = NaN;

save('anglekeeper.mat', 'anglekeeper')