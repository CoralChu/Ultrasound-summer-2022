%Author:         Coraline Chu
%Last edited:    7/18/2022
%{
Purpose:         extract affine flow metrics from ultrasound videos using
                 the LK method. Prepare to estimate the TA & TP & PL & PB
                 velocity and stretch.
Input:           ultrasound video in mp4/avi
Output:          4 parameters for each frame in the video, including:
                 Vx
                 Vy
                 Orientation(calculated from Vx & Vy)
                 Magnitude(calcualted from Vx & Vy)

Protocol for tracking fascicle velocity & orientation"
                1. run the script for the first time. Select the whole view
                as the region of interest. Observe an identifiable fascicle
                (avoid the tendon). 
                2. run the script for the second time. Select the
                identified fascicle as the region of interest.
                Q: extract ONE fasicle in the view
                2.1 Veocity
                2.2 Pennation angle
                      Cronin affine estimation
                2.3 Fascicle length
                    Find through apunerosis distance & pennation angle?
%}
%%
%create video reader and the optical flow object

clear 

%Copied this line for multiple uses
vidReader = VideoReader('20220708_Sebastian_Inverter_7.mp4', 'CurrentTime', 0);


opticFlow = opticalFlowLK;
%Note: HS seems better than LK?
%opticFlow = opticalFlowLK('NoiseThreshold',0.009);

%%
%Set up 1st time: mask for cropping

h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);



%%

%find number of frames
frameNum = 0;

while hasFrame(vidReader)
    notUseful = readFrame(vidReader);
    frameNum = frameNum + 1;
end


%%
%Find dimension of the video 
%Re-read: may not be necessary
vidReader = VideoReader('20220708_Sebastian_Inverter_7.mp4', 'CurrentTime', 0);

[~,rect] = imcrop(notUseful);
%[~,rect] = imcrop(imtool(notUseful, 'InitialMagnification',300)); 
%{
For the above line, manually pick ROI; select the ROI in the pop up image 
and right click "crop image". The cropped image and the four-element
position vector of the cropped image will be saved 
as "mask" and "rect". rect is of form: [xmin ymin width height].
%}

mask = round([rect(1) rect(1)+rect(3) rect(2) rect(2)+rect(4)]);
%{
For the above line, round each element to nearest integer since human may 
pick in between pixels. mask is now the location of the 4 vertices of the 
rect.
%}

croppedFrame = notUseful(mask(3):mask(4),mask(1):mask(2));
%{recropping with rounded values. mask(3) and mask(4) are pixel location
%the pop up image and right click "create mask". maskROI is the 
%}

[x_height, Y_Width, Z_what] = size(croppedFrame);
%[x_height, Y_Width, Z_what] = size(readFrame(vidReader));




%%
%Read in video frames and edtimate optical flow
vidReader = VideoReader('20220708_Sebastian_Inverter_7.mp4', 'CurrentTime', 0);
flows_all_Vx = zeros(x_height, Y_Width, frameNum);
flows_all_Vy = zeros(x_height, Y_Width, frameNum);
flows_all_Orien = zeros(x_height, Y_Width, frameNum);
flows_all_Mag = zeros(x_height, Y_Width, frameNum);
flow_num = 0;


%%
%Potentially useful for colored vector field
X = 1:x_height;
Y = 1:Y_Width;
[X,Y] = meshgrid(Y,X);
U = zeros(x_height, Y_Width);
V = zeros(x_height, Y_Width);


%%
%Set up 2nd time: for displaying optic flow
%opticFlow = opticalFlowLK;
h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

framePrev = rgb2gray(readFrame(vidReader));
framePrev = im2double(framePrev(mask(3):mask(4),mask(1):mask(2)));

while hasFrame(vidReader)
    %read next avaiable frame; it's a 3d matrix because it's RGB
    frameRGB = readFrame(vidReader);
    %convert to grayscle
    frameCurr = rgb2gray(frameRGB);
    %used to be:  frameGray = im2gray(frameRGB);
    
    %newly added: cropping & convert to double
    frameCurr = im2double(frameCurr(mask(3):mask(4),mask(1):mask(2)));
    
    af = affine_flow('image1', framePrev, 'image2', frameCurr, ...
    'sigmaXY', 25, 'sampleStep', 25);
    af = af.findFlow;
    flow = af.flowStruct;
    
    
    
    framePrev = frameCurr;
    
    %{
    
    %estimates optical flow between two consecutive video frames
    flow = estimateFlow(opticFlow,frameGray);
    flow_num = flow_num + 1;
    
    %store flow outputs
    flows_all_Vx(:,:,flow_num) = flow.Vx;
    flows_all_Vy(:,:,flow_num) = flow.Vy;
    flows_all_Orien(:,:,flow_num) = flow.Orientation;
    flows_all_Mag(:,:,flow_num) = flow.Magnitude;
    
    
    
    %Get data for grid
    U = flow.Vx.*10^9;
    V = flow.Vy.*10^9;
    
    imshow(frameGray, 'InitialMagnification', 300000)
    %Used to be: imshow(frameRGB)
    
    hold on
    %plot optic flow vectors
    
    %option 1: visualize velocity
    %colormap('jet');
    %cquiver(X, Y, U, V);
    
    %option 2: visualize orientation
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',20,'Parent',hPlot);

    %vfield_color(frameGray, X, Y, flow.Vx, flow.Vy, 1);
    % vfield_color(image,x,y,u,v,scale,cmap)
    %used to be: plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10,'Parent',hPlot);
    hold off
    %}
end


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