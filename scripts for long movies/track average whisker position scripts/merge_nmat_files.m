%Remember- this script will only work if the original AVIs in the set 
%had file names of precisely 21 characters, not including '.avi' 
%This seems to be true of all streampix movies, which are named 
%**-**-**_**-**-**.***.avi, but if you know that all videos are of the same
%length, it is preferable to use merge_2mat_files.m or merge_3mat_files.m

clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);
keepercol = 1;

merged = [];
for f = 1:count;
    whisker_data = importdata(matfiles(f,1).name);
    whisker_data = whisker_data.MovieInfo.AvgWhiskerAngle;
    if f == 1; %for first file
        movieName = matfiles(f,1).name; 
        movieName = movieName(1:length(movieName)-23);
        merged = whisker_data(:,:);
    elseif matfiles(f,1).name(1:21) == matfiles(f-1, 1).name(1:21); %if part of same original video
        merged = horzcat(merged, whisker_data); %append to merged
    else %matfiles(f,1).name(1:21) ~= matfiles(f-1,1).name(1:21);  %file is part of a new video
        save(strcat(movieName, '_angle_data'), 'merged'); %save everything from previous vid
        movieName = matfiles(f,1).name; %this name will be used for the next save
        movieName = movieName(1: length(movieName)-23); %remove _Whisker_Tracking from name
        merged = whisker_data(:,:); %overwrite merged
    end
end
save(strcat(movieName, '_angle_data'), 'merged'); %save the last file
