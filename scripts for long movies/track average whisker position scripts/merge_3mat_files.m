clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);
keepercol = 1;

for f = 1:3:count;
%import the next 3 videos, save the angle data
first = importdata(matfiles(f,1).name);
first = first.MovieInfo.AvgWhiskerAngle;
second = importdata(matfiles(f+1,1).name);
second= second.MovieInfo.AvgWhiskerAngle;
third = importdata(matfiles(f+2,1).name);
third = third.MovieInfo.AvgWhiskerAngle;
%concatenate data from 3 videos
merged = horzcat(first, second, third);
%save merged data
movieName = matfiles(f,1).name;
movieName = movieName(1:length(movieName)-23);%removes '_Whisker_Tracking.mat'
                                                %from file names
save(strcat(movieName, '_', 'angle_data'), 'merged');

end
