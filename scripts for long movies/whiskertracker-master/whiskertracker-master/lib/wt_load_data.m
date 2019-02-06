function wt_load_data(varargin)
% WT_LOAD_DATA Load movie data from disk
%
% WT_LOAD_DATA()
%

global g_tWT
sOldMovieName = '';

% Load whisker data and parameters
try
    vStrIndx = 1:findstr(g_tWT.MovieInfo.Filename, '.avi') - 1;
    if isempty(vStrIndx)
        vStrIndx = 1:findstr(g_tWT.MovieInfo.Filename, '.bin') - 1;
    end
    sFilename = sprintf('%s.mat', g_tWT.MovieInfo.Filename(vStrIndx));

    % If sFilename does not exist, this file may have copied to a different
    % system with a different directory structure as compared to when it
    % was tracked. Check if 2 ascending directories match the filename from
    % the current directory; if there is a match, then update the filename
    if ~exist(sFilename, 'file')
        iSep = unique([findstr(sFilename, '\') findstr(sFilename, '/')]);
        sFilename(iSep) = filesep;
        if ~isempty(iSep)
            sRelFilename = sprintf('..%s..%s', filesep, sFilename(iSep(end-2):end));
            [sRelPath, sRelFile, eExt] = fileparts(sRelFilename);
            if ~isempty(dir(sRelFilename)) % file match
                sFilename = sprintf('%s%s%s%s', pwd, filesep, sRelFile, eExt);
            end
        end
    end
    
    % Let user select data file to load (otherwise load default)
    if nargin==1
        switch varargin{1}
            case 'deffile'
                [sFilename, sFilepath] = uigetfile('*.mat;*.gz', 'Select data file');
                sFilename = sprintf('%s%s', sFilepath, sFilename);
                sOldMovieName = g_tWT.MovieInfo.Filename; % we keep the old filename
        end
    end

    % Uncompress .gz file if it exists
    if exist([sFilename '.gz'], 'file') == 2 % archive exists
        eval(sprintf('!copy %s %s', [sFilename '.gz'], [sFilename '.gz.bak']));
        % gzip path
        sPath = which('wt_load_data');
        eval(sprintf('!%s\\bin\\gzip -d %s', sPath(1:(end-14)), [sFilename '.gz']))
        
        tLoadedStruct = load(sprintf('%s', sFilename));
        if isfield(tLoadedStruct, 'g_tWT.MovieInfo')
            g_tWT.MovieInfo = tLoadedStruct.g_tWT.MovieInfo;
        elseif isfield(tLoadedStruct, 'g_tMovieInfo')
            g_tWT.MovieInfo = g_tMovieInfo;
        end
        
        %load(sprintf('%s', sFilename), 'g_tWT.MovieInfo');
        delete(sFilename)
        eval(sprintf('!move %s %s', [sFilename '.gz.bak'], [sFilename '.gz']));
    else
        temp = load(sprintf('%s', sFilename), 'g_tMovieInfo');
    end

    g_tWT.MovieInfo = assign_struct_array_elem(g_tWT.MovieInfo, 1, temp.g_tMovieInfo);
    %wt_set_status(sprintf('Data file found: %s', sFilename))
    
    % Extract saved frame buffer
    if isfield(g_tWT.MovieInfo, 'FrameBuffer')
        g_tWT.CurrentFrameBuffer.Img = g_tWT.MovieInfo.FrameBuffer.Img;
        g_tWT.CurrentFrameBuffer.Frame = g_tWT.MovieInfo.FrameBuffer.Frame;
    else
        g_tWT.CurrentFrameBuffer.Img  = zeros(g_tWT.MovieInfo.Width, g_tWT.MovieInfo.Height);
        g_tWT.CurrentFrameBuffer.Frame = 1;
    end
    
    if ~isempty(sOldMovieName)
        g_tWT.MovieInfo.Filename = sOldMovieName;
        sFilename = [sOldMovieName(1:end-3) 'mat'];
    end

    g_tWT.DefaultSavePath = sFilename;

catch
    if isempty(sFilename), return, end
    wt_set_status('Data file not found.', sFilename)
end

% If the path of the video in g_tWT.MovieInfo is not the same as the
% selected/loaded movie, then change the path in g_tWT.MovieInfo *by default*
sTargetPath = fileparts(sFilename);
[sLoadPath, sLoadFile, sLoadExt] = fileparts(g_tWT.MovieInfo.Filename);
if ~strcmp(sTargetPath, sLoadPath)
    g_tWT.MovieInfo.Filename = fullfile(sTargetPath, [sLoadFile sLoadExt]);
end

% Refresh frame
wt_display_frame(1)

return
