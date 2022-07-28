function [X2, Y2] = ultrasound_optic_flow(im1, im2, X1, Y1, ROI)
%   [X2, Y2] = ULTRASOUND_OPTIC_FLOW(IM1, IM2, X1, Y1, ROI)
%   Determines the position change of points defined by arrays X1 and Y1 
%   from the an original image (IM1) to the next successive image (IM2).
%   Images need to be grey-scale. Analysis of optic flow can be confined to
%   a specified ROI (binary mask - created with ROIPOLY)
%   
%   This function relies on the AFFINE_FLOW classes - written by Dr David
%   Young (Sussex University - used with permission)
%   http://www.mathworks.com/matlabcentral/fileexchange/27093-affine-optic-
%   flow
%   
%   Copyright Glen Lichtwark 2011

% ensure that input data is of the correct type
if sum(size(im1)~=size(im2))>0
    error('Images must be the same size')
end

if length(X1) ~= length(Y1)
    error('X and Y coordinate arrays of tracking points must be the same length')
end

% ensure that the array is a single column
if size(X1,2) > size(X1,1)
    X1 = X1';
    Y1 = Y1';
end

% if no ROI is defined then make the entire image the ROI
if nargin < 5
    ROI = ones(size(im1));
end

% convert to a BW image in double format - needs to be grey scale but
% catch this here and convert if necessary
if ndims(im1) > 2
    im1 = double(rgb2gray(im1))/256;
    im2 = double(rgb2gray(im2))/256;
else im1 = double(im1)/256;
    im2 = double(im2)/256;
end

% define parameters for affine flow algorithm - THESE CAN BE CHANGED IF
% NECESSARY but suit fascicle tracking with ultrasond
sigmaXY = 3;
sampleStep = 3;

% Define the afine flow object with above parameters
% IMPORTANT - This matlab implementation of an optical flow requires the
% AFFINE_FLOW function and associated functions written by Dr David Young
% (Sussex University) which are freely available from Matlab Central's file exchange 
% http://www.mathworks.com/matlabcentral/fileexchange/27093-affine-optic-flow

af = affine_flow('image1', im1, 'image2', im2, 'sigmaXY',sigmaXY,'sampleStep',sampleStep,'regionOfInterest',ROI);
% find the affine flow parameters
af = af.findFlow;
% define the flow structure
flow = af.flowStruct;
% determine the image deformation matrix 
w = affine_flow.warp(flow);

% determine the deformation of point (X1, Y1) from image1 - 
% the estimate of the corresponding position in image2 is given 
% by [X1 Y1 1] * w, where w is the deformation matrix from above

XY2 = [X1 Y1 ones(size(X1))] * w;

% define the X and Y coordinates as separate arrays to be output
X2 = XY2(:,1);
Y2 = XY2(:,2);

end


