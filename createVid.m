
function createVid(correl, fold,file,vid_typ,save_file)
%% Function to create video object based input.  Requires the input
% variable, the folder to save the video to, and the name of the video.
% Also takes an integer to define video type (vid_typ), 1 for whole video, 2 for
% first 100ms.  Finally, uses save_file to determine whether to save files.
%  2 to save, one to not.
%
% Examples:
%createVid(acco.OO.correlns,'D:\Research\Matlab\Workspace\vidTest\','test2',2,2)
% uses correl matrix, saves in folder, video called test2.avi, 2 means only
% first 50ms looped, 2 means each frame is saved to file (slower)
%
%createVid(acco.OO.correlns,'D:\Research\Matlab\Workspace\vidTest\','test2',2,1)
% uses correl matrix, saves in folder, video called test2.avi, 2 means only
% first 50ms looped, 1 means only the video is saved to file (quicker)
%
%createVid(acco.OO.correlns,'D:\Research\Matlab\Workspace\vidTest\','test2',1,1)
% uses correl matrix, saves in folder, video called test2.avi, 1 means
% entire video used, 1 means only the video is saved to file (quicker)


if ~exist(fold, 'dir')
    % create directory
    mkdir(fold) ;
end

vidObj = VideoWriter([fold, '/', file]);

% Get max and min of all matrix to normalise
maxV = max(correl);
maxV = squeeze(maxV);
maxV = max(maxV);
maxV = max(maxV);

minV = min(correl);
minV = squeeze(minV);
minV = min(minV);
minV = min(minV);

% set 100ms or whole video
if(vid_typ == 2)
    looplen = 50; %50 frames, around 100ms, assuming rate of 44100
else
    looplen = length(correl(1,1,:)); % length of matrix
end

open(vidObj);
% Loop for each
for x = 1:looplen
    % If whole video
    if(vid_typ == 1)
        imagesc(correl(:,:,x),[minV,maxV]) % now with scaling for max and min consistent across image
        % FOR SAVING INDIVIDUAL IMAGES
        if(save_file ==2)
            fileN = [fold, 'frame' num2str(x)];
            saveas(gcf, fileN, 'jpg')
        end
        currFrame = getframe;
        writeVideo(vidObj,currFrame);
        pause(0.01)
    else % Loop each frame 6 times to slow down
        for x2 = 1:6
            imagesc(correl(:,:,x),[minV,maxV]) % now with scaling for max and min consistent across image
            % FOR SAVING INDIVIDUAL IMAGES
            if(save_file ==2)
                fileN = [fold, 'frame' num2str(x)];
                saveas(gcf, fileN, 'jpg')
            end
            currFrame = getframe;
            writeVideo(vidObj,currFrame);
            pause(0.01)
        end
    end
    
end

% Close the file.
close(vidObj);
close all;