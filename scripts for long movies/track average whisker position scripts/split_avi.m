tic;
clear;
folder = uigetdir;
cd(folder);
filePattern = fullfile(folder, '*.avi');
matfiles = dir(filePattern);
count = length(matfiles);

for f = 1:count;

%Script to split a video into multiple AVIs of 4000 frames each 

movie = char({matfiles(f,1).name})
M = mmreader(movie);
nFrames = M.NumberOfFrames;
vidHeight = M.Height;
vidWidth = M.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'single'),...
           'colormap', []);

%Determine last allowed startFrame position
for i=  1:4000:nFrames
    if nFrames - i < 4000
        break;
    end
end
%start videos @ frame 1, 4001, 8001, etc;  
for startFrame = 1:4000:i
    newVideo = VideoWriter(strcat(M.Name(1:length(M.Name)-4),'_', num2str(startFrame)), 'Grayscale AVI');
    newVideo.FrameRate = M.FrameRate;
    open(newVideo);
    if startFrame == i %if at last video, end at last frame
        lastFrame = nFrames;
    else %else end at 4000 frames
        lastFrame = startFrame + 3999;
    end
    for k = startFrame: lastFrame;
        k;
        mov(k).cdata = read(M, k);
        writeVideo(newVideo,mov(k));
        mov(k).cdata = [];
    end
    clear newVideo
end
end
toc;
