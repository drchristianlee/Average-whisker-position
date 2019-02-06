%this script calculates the grand average from the output of behavior
%analysis 3. Place the .mat files of a given response type into a folder
%named with the response type, thus Gos, NoGos etc. On 9.12.2014 CL added
%calculation for sem into column 2 of grand average based on grand
%average_js_v1_0.m. This script additionally calculates the data as
%percentage of baseline. 

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
for matrices = 1:(length(holdercells));
    currmatrix = cell2mat(holdercells(1, matrices));
    numcols = size(currmatrix, 2);
    for cols = 1:numcols;
        decisioncol = currmatrix(:, cols);
        if isnan(nanmean(decisioncol, 1))==0
            for rows = 1:(size(currmatrix, 1));
                %done this way to avoid having to pad data to account for
                %different file lengths.
                averagekeeper(rows,keepercol) = currmatrix(rows, cols);
            end
            keepercol = keepercol + 1;
        end
    end
end
%now convert zeros in averagekeeper to NaNs
averagekeeper(averagekeeper==0) = NaN;

%now calculate the average and standard error
grandaverage = nanmean(averagekeeper, 2);
nanValues = isnan(averagekeeper);
nanTrials = size(averagekeeper, 2) - sum(nanValues, 2);
grandaverage(:, 2) = nanstd(averagekeeper, 0, 2) ./ sqrt(nanTrials);

%now calculate the average and standard error using percentages
normvalue = grandaverage(1,1);
percentkeeper = averagekeeper/normvalue;
percentkeeper = percentkeeper*100;
grandaverage(:,4) = nanmean(percentkeeper, 2);
percentnan = isnan(percentkeeper);
percentnantrials = size(percentkeeper, 2) - sum(percentnan, 2);
grandaverage(:,5) = nanstd(percentkeeper, 0, 2) ./ sqrt(percentnantrials);

%now plot the grand average data
% figure;
% plot(grandaverage(:, 1));
% figure;
% plot(grandaverage(:, 4));
%now save the average data
save(char(strcat(name, '_average')), 'grandaverage');
save(char(strcat(name, '_whole')), 'percentkeeper');