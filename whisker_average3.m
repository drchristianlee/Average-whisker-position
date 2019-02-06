clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);
for f = 1:count;
    B = matfiles(f, 1).name;
    load(B);
end
anglekeeper_rows = transpose(anglekeeper);
sizeGos = size(Gos);
numGos = sizeGos(1,2);
sizeMisses = size(Misses);
numMisses = sizeMisses(1,2);
sizeNoGos = size(NoGos);
numNoGos = sizeNoGos(1,2);
sizeFAs = size(FAs);
numFAs = sizeFAs(1,2);
sizeradius = size(anglekeeper_rows);
radiusheight = sizeradius(1,1);
radiuslength = sizeradius(1,2);
Goskeeper = NaN(radiusheight, radiuslength);
for g = 1:numGos;
    gocolumn = Gos(1, g);
    Goskeeper (:,gocolumn) = anglekeeper_rows(:,gocolumn);
end

Goskeeper(Goskeeper==0) = NaN;
Gosmean = nanmean(Goskeeper, 2);

Misseskeeper = NaN(radiusheight, radiuslength);
for m = 1:numMisses;
    Missescolumn = Misses(1, m);
    Misseskeeper (:,Missescolumn) = anglekeeper_rows(:,Missescolumn);
end

Misseskeeper(Misseskeeper==0) = NaN;
Missesmean = nanmean(Misseskeeper, 2);

NoGoskeeper = NaN(radiusheight, radiuslength);
for n = 1:numNoGos;
    nogocolumn = NoGos(1, n);
    NoGoskeeper (:,nogocolumn) = anglekeeper_rows(:,nogocolumn);
end

NoGoskeeper(NoGoskeeper==0) = NaN;
NoGosmean = nanmean(NoGoskeeper, 2);

FAskeeper = NaN(radiusheight, radiuslength);
for f = 1:numFAs;
    facolumn = FAs(1, f);
    FAskeeper (:,facolumn) = anglekeeper_rows(:,facolumn);
end

FAskeeper(FAskeeper==0) = NaN;
FAsmean = nanmean(FAskeeper, 2);
figure;
plot(Gosmean)
hold all;
plot(NoGosmean);
hold all;
plot(FAsmean);
hold all;
plot(Missesmean);
hold all;
legend('Gosmean', 'Nogosmean', 'FAsmean', 'Missesmean');
substring = strsplit(folder, '\');
lengthsubstring = length(substring);
subname = substring(1, lengthsubstring);
Goskeepername = char(strcat(subname, 'GosWhiskerkeeper.mat'));
save(Goskeepername, 'Goskeeper');
NoGoskeepername = char(strcat(subname, 'NoGosWhiskerkeeper.mat'));
save(NoGoskeepername, 'NoGoskeeper');
Misseskeepername = char(strcat(subname, 'MissesWhiskerkeeper.mat'));
save(Misseskeepername, 'Misseskeeper');
FAskeepername = char(strcat(subname, 'FAsWhiskerkeeper.mat'));
save(FAskeepername, 'FAskeeper');
