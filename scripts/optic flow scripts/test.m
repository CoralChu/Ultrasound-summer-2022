%Author:         Coraline Chu
%Last edited:    7/19/2022
%{
Usage note: open the file and GO TO AFFINE OPTIC FLOW as the current folder
Purpose:         extract AFFINE flow metrics (pennation angle) 
                 from ultrasound videos using
                 the affine optic flow, and extension to the 
                 LK method for estimating optic flow. 
Input:           ultrasound video in mp4/avi

Output:          end points series of a tracked fascicle;
                 pennation angle;
                 (velocity?
                 (this method CANNOT reliably get length but can be
                 calculated with apoenrosis distance & penn angle

Protocol for tracking fascicle velocity & orientation: (TBD)
                
%}
%%
%create video reader and the optical flow object.

clear 

%Copied this line for multiple uses
vidReader = VideoReader('20220708_Sebastian_Inverter_7.mp4', 'CurrentTime', 0);

%Set up display the 1st time
h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Fascicle End Points');
hPlot = axes(hViewPanel);

%%
%find number of frames.

frameNum = 0;

while hasFrame(vidReader)
    notUseful = readFrame(vidReader);
    frameNum = frameNum + 1;
end


%%
%Crop the ROI muscle & Find dimension of the cropped frame.


%Re-read: may not be necessary; just to keep readFrame running when needed
vidReader = VideoReader('20220708_Sebastian_Inverter_7.mp4', 'CurrentTime', 0);
notUseful = readFrame(vidReader);

%{
manually pick ROI; select the ROI in the pop up image 
and right click "crop image". The cropped image and the four-element
position vector of the cropped image will be saved 
as "mask" and "rect". rect is of form: [xmin ymin width height].
%}
%OLD code[~,rect] = imcrop(imtool(notUseful, 'InitialMagnification',300)); 
[~,rect] = imcrop(notUseful);


%{
round each element to nearest integer since human may 
pick in between pixels. mask is now the location of the 4 vertices of the 
rect.
%}
mask = round([rect(1) rect(1)+rect(3) rect(2) rect(2)+rect(4)]);



%{recropping with rounded values. mask(3) and mask(4) are pixel location
%the pop up image and right click "create mask". maskROI is the 
%}
croppedFrame = notUseful(mask(3):mask(4),mask(1):mask(2));


[x_height, Y_Width, Z_what] = size(croppedFrame);




%%
%Potentially useful things for plotting colored vector optic field

X = 1:x_height;
Y = 1:Y_Width;
[X,Y] = meshgrid(Y,X);
U = zeros(x_height, Y_Width);
V = zeros(x_height, Y_Width);

%%
%Read the first frame & define the point to track

%Re-read here; don't read again before iteration to avoid re-reading the
%first frame
vidReader = VideoReader('20220708_Sebastian_Inverter_7.mp4', 'CurrentTime', 0);

framePrev = rgb2gray(readFrame(vidReader));
framePrev = framePrev(mask(3):mask(4), mask(1):mask(2));
framePrev = im2double(framePrev);


%choose initial end points
%carefully! (or retry with diff ones) because
%there's no key frame correction!
imshow(framePrev, 'InitialMagnification', 300);
EndPoint1 = drawpoint;
X1 = EndPoint1.Position(1);
Y1 = EndPoint1.Position(2);

imshow(framePrev, 'InitialMagnification', 300);
EndPoint2 = drawpoint;
X2 = EndPoint2.Position(1);
Y2 = EndPoint2.Position(2);

%variable to count how many times the flow is calculated
flow_num = 0;

%logical format of frame size for tracking point use
ROI = true(x_height, Y_Width);

%X matrix for X1 & X2 end point locations
Endpoint_location_X = zeros(2, frameNum - 1);
Endpoint_location_X(1,1) = X1;
Endpoint_location_X(2,1) = X2;

%Y matrix for Y1 & Y2 end point locations
Endpoint_location_Y = zeros(2, frameNum - 1);
Endpoint_location_Y(1,1) = Y1;
Endpoint_location_Y(2,1) = Y2;

%%
%Iterate through video and track the defined endpoints.

% set up the display 2nd time
h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Fascicle End Points');
hPlot = axes(hViewPanel);

while hasFrame(vidReader)
    %read next avaiable frame; it's a 3d matrix because it's RGB
    frameRGB = readFrame(vidReader);
    %convert to grayscle
    frameGray = rgb2gray(frameRGB);
    %cropping
    frameGray = im2double(frameGray(mask(3):mask(4),mask(1):mask(2)));
    
    
    
    %NOTE: THIS IS AN OLD VERSION OF ULTRATRACK TRACKING
    % TRACKING ENDPOINTS
    % Determine the movement of the end points of the fascicle by 
    % calculating the optic flow with affine model. This requires
    % comparison of two consectutive images from image sequence
    % (consecutive images in the loop - i and i+1), as well as the position
    % of the end points in the first (template) image, and the region of
    % interest if defined. The ultrasound_optic_flow function handles the
    % calculations and calls the affine_flow class of functions.
    [Xnew1, Ynew1] = ultrasound_optic_flow(framePrev, frameGray, X1, Y1, ROI);
    [Xnew2, Ynew2] = ultrasound_optic_flow(framePrev, frameGray, X2, Y2, ROI);
    flow_num = flow_num + 1;
    %{
    Hidden operation in the above function:
    af = affine_flow('image1', framePrev, 'image2', frameGray, ...
    'sigmaXY', 1, 'sampleStep', 10);
    af = af.findFlow;
    flow = af.flowStruct;
    %}
    
    
    %store new Xnew1 et al
    Endpoint_location_X(1, flow_num + 1) = Xnew1;
    Endpoint_location_X(2, flow_num + 1) = Xnew2;
    Endpoint_location_Y(1, flow_num + 1) = Ynew1;
    Endpoint_location_Y(2, flow_num + 1) = Ynew2;

    %plot end points: NOTE: currently it's missing the last frame
    imshow(framePrev, 'InitialMagnification', 300)
    %Used to be: imshow(frameRGB)
    
    hold on
    
    plot([X1, X2], [Y1, Y2], '-o', 'LineWidth', 2, 'MarkerSize', 7);
    text(10, 10, strcat('Current slice: ' , string(flow_num + 1)), 'FontSize', 16, 'Color', 'w');
    %Starts to be inaccurate at about 230 slices. In other words, process
    %10s at a time
    
    hold off
    
    %Update 
    X1 = Xnew1;
    Y1 = Ynew1;
    X2 = Xnew2;
    Y2 = Ynew2;
    framePrev = frameGray;
    
    
    
    pause(10^-2)
    
end

run = abs(Endpoint_location_X(2, :) - Endpoint_location_X(1, :));
rise = abs(Endpoint_location_Y(2, :) - Endpoint_location_X(1, :));

Result_penn_angles = rise/run;

%%
%EVERYTHING BELOW is storage of old code
%{
af = affine_flow('image1', framePrev, 'image2', frameGray, ...
    'sigmaXY', 1, 'sampleStep', 10);
af = af.findFlow;
flow = af.flowStruct;


flow_num = flow_num + 1;
framePrev = frameGray;
%}

%%
%{
cquiver(X, Y, U.*10^9, V.*10^9);

%}

%%
%{
X = 1:x_height;
Y = 1:Y_Width;
[X, Y] = meshgrid(Y, X);

%}