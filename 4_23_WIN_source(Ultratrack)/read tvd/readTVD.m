function [TVDdata] = readTVD(TVDfname, rect)

% Function to read in a .tvd file created by EchoWave II software and
% output a stack of grayscale images and the associated time stamps
%
% Inputs - TVDfname - string containing full path to .tvd file
%          
% Outputs -TVDdata.Im - 3D array representing a stack of 2D grayscale images
%         -TVDdata.Time - Array of time stamps corresponding to each image
%         frame
%         -TVDdata.Height - height of image in pixels
%         -TVDdata.Width - width of image in pixels
%         -TVDdata.Fnum - number of image frames
%
% Created by Dominic Farris, School of Human Movement Studies, The University of Queensland
% 13/03/2014. Edited by Glen Lichtwark 06/08/14

% set path to Echo Wave II automation interface client .Net assembly (dll)
% - I think the function 'computer' returns the version of matlab (32 or 64
% bit)  and so the commented code doesn't do what you want if you're running 32-bit
% matlab on a 64-bit platform - as I'm testing on a 64-bit platform (with 32-bit matlab), I'll just
% specify the path explicitly.
if strcmp(computer('arch'), 'win64')
    asm_path = 'C:\Program Files\Telemed\Echo Wave II\Config\Plugins\AutoInt1Client.dll';
    %original line capitalized Telemed: 'C:\Program Files (x86)\TELEMED\Echo Wave II\Config\Plugins\AutoInt1Client.dll'
else
    asm_path = 'C:\Program Files\TELEMED\Echo Wave II\Config\Plugins\autoint1client.dll';
end

% load assembly
asm = NET.addAssembly(asm_path);

% create commands interface object
cmd = AutoInt1Client.CmdInt1();

% connect to started Echo Wave II software -UNABLE TO CONNECT!!
ret = cmd.ConnectToRunningProgram(); 

display(ret)
if (ret ~= 0)
    msgbox('Error. Cannot connect to Echo Wave II software. Please make sure that its options were correctly adjusted and that software is running.', 'Error')
    return;
end


%open TVD file (previously saved using Echo Wave II software)
cmd.OpenFile(TVDfname);

%Get the number of frames in the TVD file
TVDdata.Fnum = cmd.GetFramesCount();
%Get the image width
TVDdata.Width = cmd.GetLoadedFrameWidth();
%Get the image height
TVDdata.Height = cmd.GetLoadedFrameHeight();

% this just stops the computer running out of memory - would be good to be
% able to specifically determine the max value as a function (TO DO)
if (TVDdata.Fnum > 3000)
    TVDdata.Fnum = 3000;
end

% work out how to autocrop the image if no cropping is specified in input
if nargin < 2
    cmd.GoToFrame1n(1, true);
    
    Im = uint8(cmd.GetLoadedFrameGray());
    
    % work out how to trim the edges of the ultrasound (edges are intensity value of
    % 56]
    m = find(Im(:,1) == 56); % find where the image starts vertically - at top of image the gray changes from 66 to 56.
    n = find(mean((Im(end-50:end,:) == 56))<0.4); % use the averaage value of the bottom 50 rows to determine whether this is a high value (i.e. gray) or low (i.e. real image)
    
    rect = [n(find(diff(n)>1)+1) m(1) n(end)-n(find(diff(n)>1)+1) length(m)-1]; % define the new rectangle for autocroping
    
    TVDdata.rect = rect; 
    TVDdata.Width = rect(3)+1; % save the new width and height
    TVDdata.Height = rect(4)+1;
    
else  % if the cropping box is specified, use it here.
    TVDdata.rect = rect;
    TVDdata.Width = rect(3)+1;
    TVDdata.Height = rect(4)+1;
end

% go through all frames and save as a UINT8 format
h = waitbar(0,'Loading ultrasound data ...');

TVDdata.Im = zeros(TVDdata.Height, TVDdata.Width, TVDdata.Fnum,'uint8');

%Loop through the file, storing each frame as a grayscale image
for i = 1:TVDdata.Fnum;
    
    % go to frame and load it
    cmd.GoToFrame1n(i, true);
    
    % Get the time stamp of this frame
    TVDdata.Time(i) = cmd.GetCurrentFrameTime();
    
    % get two-dimensional grayscale array of loaded frame 
    TVDdata.Im(:,:,i) = imcrop(uint8(cmd.GetLoadedFrameGray()),rect);
    
    waitbar(double(i)/double(TVDdata.Fnum),h)
    
end

close(h);
