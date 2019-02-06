%this script is used after creating average mat files. Copy and paste each average
%mat file into the same folder and then run this script to plot them on the
%same set of axes. This script additionally plots average percentage
%traces.

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
number = size(holdercells);
% figure
% plot (holdercells{1, 1}(:, 1));
% hold on
% plot(holdercells{1, 2}(:, 1));
% hold on
% plot(holdercells{1, 3}(:, 1));
% hold on
% plot(holdercells{1, 4}(:, 1));
% hold on

for trace = 1: number(1, 2);
    figure
    tracemean = (holdercells{1, trace}(:, 1));
    tracesem = (holdercells{1, trace}(:, 2));
    triallength = length(tracemean);
    frame = colon(1, triallength).';
    shadedErrorBar(frame, tracemean, tracesem, 'b', 0);
end
%figure
% for trace = 1: number(1, 2);
%     perctracemean = (holdercells{1, trace}(:, 4));
%     perctracesem = (holdercells{1, trace}(:, 5));
%     triallength = length(perctracemean);
%     frame = colon(1, triallength).';
%     if trace == 1;
%         figure
%         shadedErrorBar(frame, perctracemean, perctracesem, 'b', 0);
%         axis([0 350 95 125])
%         set(gca,'TickDir','out')
%         set(gca, 'box', 'off')
%     elseif trace == 2;
%         figure
%         shadedErrorBar(frame, perctracemean, perctracesem, 'r', 0);
%         axis([0 350 95 125])
%         set(gca,'TickDir','out')
%         set(gca, 'box', 'off')
%     elseif trace == 3;
%         figure
%         shadedErrorBar(frame, perctracemean, perctracesem, 'g', 0);
%         axis([0 350 95 125])
%         set(gca,'TickDir','out')
%         set(gca, 'box', 'off')
%     elseif trace ==4;
%         figure
%         shadedErrorBar(frame, perctracemean, perctracesem, 'y', 0);
%         axis([0 350 95 125])
%         set(gca,'TickDir','out')
%         set(gca, 'box', 'off')
%     end
%     %hold on
% end