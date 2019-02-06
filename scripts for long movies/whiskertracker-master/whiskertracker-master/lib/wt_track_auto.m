function wt_track_auto(sSpeed)
% wt_track_auto
%
%

global g_tWT
g_tWT.StopProc=0;

sMethod = 'nearest'; % method of interpolation during image rotation

if ~isfield(g_tWT, 'RepositionOnly')
    g_tWT.RepositionOnly = 0;
end
if ~g_tWT.DisplayMode, wt_toggle_display_mode, end

% Start matlabpool if not open already
if g_tWT.ParallelMode
    try
        if matlabpool('size') == 0
            wt_set_status('Warning: Matlab worker pool not initialized. Starting pool now...')
            matlabpool; % open default pool
            wt_set_status(sprintf('Matlab worker pool started with %d workers.', matlabpool('size')))
        end
    catch
            wt_set_status('Error: Failed starting Matlab worker pool.')
            wt_toggle_parallel();
    end
end

% Disable 'play' buttons
hBut = findobj('label','>'); set(hBut, 'enable','off')
hBut = findobj('label','>>'); set(hBut, 'enable','off')

% Initial parameters
if length(g_tWT.MovieInfo.HorJitter) ~= 3
    sErrString = 'Length of horizontal jitter parameter must be 3! Correct in Parameters... dialog from the Tracker menu.';
    wt_error(sErrString);
end
if length(g_tWT.MovieInfo.HorJitterSlow) ~= 3
    sErrString = 'Length of horizontal jitter SLOW parameter must be 3! Correct in Parameters... dialog from the Tracker menu.';
    wt_error(sErrString);
end
if isempty(g_tWT.MovieInfo.SplinePoints)
    sErrString = 'No whiskers have been marked. Select Whiskers->Mark New, and then try tracking again.';
    wt_error(sErrString);
end

% Create filters
if isempty(g_tWT.FiltVec)
    g_tWT.FiltVec = wt_create_filters(g_tWT.MovieInfo.WhiskerWidth, g_tWT.MovieInfo.FilterLen); 
end

% Determine from which frame to start tracking
% First frame is the frame after the *last* frame in which whisker position
% is known. Thus, if whisker was initially marked in frame 500, then the
% first frame to track will be frame 501. Frames before 500 are ignored.

% (i.e. 1st frame with missing splinepoints for at least one whisker)
vLastKnownFrames = [];
for w = 1:size(g_tWT.MovieInfo.SplinePoints,4) % iterate over all whiskers
    vKnownFrames = find(g_tWT.MovieInfo.SplinePoints(1,1,:,w));
    nLast = min(vKnownFrames(diff(vKnownFrames)>1));
    if isempty(nLast), nLast = vKnownFrames(end); end
    vLastKnownFrames = [vLastKnownFrames; nLast];
end
vIndx = vLastKnownFrames(:) ~= g_tWT.MovieInfo.LastFrame';
nStartFrame = min(vLastKnownFrames(vIndx))+1;
if g_tWT.RepositionOnly
    nStartFrame = round(get(g_tWT.Handles.hSlider, 'Value'));
end

counter = 1;
% Iterate over all frames
vTrackFrames = nStartFrame:g_tWT.MovieInfo.NoFramesToLoad:g_tWT.MovieInfo.NumFrames;
for nStepRange = vTrackFrames
    % Prevent frame-range not to exceed actual max number of frames
    vFrames = nStepRange:nStepRange+g_tWT.MovieInfo.NoFramesToLoad-1;
    vFrames = vFrames(find(vFrames <= g_tWT.MovieInfo.NumFrames));
    
    % Load frames in current range
    if isempty(g_tWT.MovieInfo.FilenameUncompressed)
        mFrames = wt_load_avi(g_tWT.MovieInfo.Filename, vFrames);
    else
        mFrames = wt_load_avi(g_tWT.MovieInfo.FilenameUncompressed, vFrames);
    end

    % Iterate over frames in current range
    vScore = [];
    vScoreStd = [];
    for nFrame = 1:length(vFrames)
        nRealFrameNumber = vFrames(nFrame);

        % Stop tracking if last frame has been reached
        if all(nRealFrameNumber > g_tWT.MovieInfo.LastFrame)
            g_tWT.StopProc = 1;
            break
        end

        % Determine if head is tracked in current frame
        if ~isempty(g_tWT.MovieInfo.EyeNoseAxLen), bHeadIsTracked = 1;
        else bHeadIsTracked = 0; end

        % Subtract background frame
        mFrame = wt_subtract_bg_frame(mFrames(:,:,nFrame), nRealFrameNumber);            

        if bHeadIsTracked
            % Abort if head-movements are not known for the current frame
            if isnan(g_tWT.MovieInfo.Nose(nRealFrameNumber,1))
                sMsg = sprintf('Stopped tracking as head location is not known for current frame (%d)', nRealFrameNumber);
                if g_tWT.VerboseMode, wt_error(sMsg)
                else wt_set_status(sMsg), end
                g_tWT.StopProc = 1; break
            end
            
            % Pre-process (crop, rotate & invert)
            [mFrame, ~] = wt_image_preprocess(mFrame);

            % Crop frame according to head-position
            if ~isnan(g_tWT.MovieInfo.RightEye(nRealFrameNumber,1)) && ~isnan(g_tWT.MovieInfo.LeftEye(nRealFrameNumber,1))
                mImg = wt_crop_behaving_video(mFrame, ...
                    [g_tWT.MovieInfo.RightEye(nRealFrameNumber,:); ...
                        g_tWT.MovieInfo.LeftEye(nRealFrameNumber,:); ...
                        g_tWT.MovieInfo.Nose(nRealFrameNumber,:)] , ...
                    g_tWT.MovieInfo.HorExt, g_tWT.MovieInfo.RadExt, sMethod);
            end
            
            % Join two images
            mImgCroppedOnly = cat(2, mImg{1}, mImg{2});
        else
            % Movie with no head-movements
            try
                [mImg, mImgCroppedOnly] = wt_image_preprocess(mFrame);
            catch meException
                wt_error('Failed pre-processing image. Try Debug.');
            end
        end

        % Process whisker-by-whisker
        for w = 1:size(g_tWT.MovieInfo.SplinePoints, 4)

            % Skip whisker if its position in PREVIOUS frame is unknown
            if nRealFrameNumber-1 > 0
                if ~any(g_tWT.MovieInfo.SplinePoints(:,1,nRealFrameNumber-1,w))
                    continue
                end
            end
            
            % Skip whisker if its last frame has been reached
            if nRealFrameNumber > g_tWT.MovieInfo.LastFrame(w)
                continue
            end
            
            % Skip whisker if its position is known in CURRENT frame,
            % unless we are repositioning
            if ~(nRealFrameNumber > size(g_tWT.MovieInfo.SplinePoints, 3))
                if any(g_tWT.MovieInfo.SplinePoints(:,1,nRealFrameNumber,w)) && ~g_tWT.RepositionOnly
                    continue;
                end
            end
            
            % Find next whisker
            if bHeadIsTracked, mCurrFrame = mImg{g_tWT.MovieInfo.WhiskerSide(w)};
            else mCurrFrame = mImg; end
            [vScore(end+1), vScoreStd(end+1), nScoreN] = wt_find_next_whisker(w, nRealFrameNumber, nRealFrameNumber-1, mCurrFrame, sSpeed);

            % Update Signal/Noise graph
            if g_tWT.ShowSR
                wt_plot_signal_noise(vScore./vScoreStd); drawnow
                vScore = [];
                vScoreStd = [];
            end
            
            % Enter manual mode if user stops execution
            if g_tWT.StopProc
                wt_display_frame(nRealFrameNumber, mImgCroppedOnly);
                break
            end
        end % end of whisker loop

        if g_tWT.StopProc, break, end

        % Plot whisker
        if counter == g_tWT.MovieInfo.ScreenRefresh
            wt_display_frame(nRealFrameNumber, mImgCroppedOnly);
            counter = 1;
        else
            counter = counter + 1;
        end

    end % end of current range loop (all loaded frames)
        
    if g_tWT.StopProc, break, end
end

% Enable 'play' buttons
hBut = findobj('label','>'); set(hBut, 'enable','on')
hBut = findobj('label','>>'); set(hBut, 'enable','on')

return
