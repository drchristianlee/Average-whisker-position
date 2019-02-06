clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);
for f = 1:count;
    B = matfiles(f, 1).name;
    currkeeper = load(B);
    holdercells(1, f) = {currkeeper};
end

for num = 1:count;
    sizekeeper(1 , num) = size(holdercells{1,num}.MovieInfo.AvgWhiskerAngle , 2);
end

maxlength = max(sizekeeper);

anglekeeper = NaN(count, maxlength);

for cells = 1:count;
    anglekeeper(cells, :) = holdercells{1, cells}.MovieInfo.AvgWhiskerAngle;
end

save('anglekeeper.mat' , 'anglekeeper');