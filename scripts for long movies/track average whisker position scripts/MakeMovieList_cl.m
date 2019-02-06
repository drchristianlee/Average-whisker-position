clear
folder = dir;
n = 1;
for x = 1:size(folder, 1);
    if findstr(folder(x,1).name , 'avi');
        files(1, n) = {folder(x,1).name};
        n = n+1;
    else
    end
end

save('movie1list.mat' , 'files');
clear