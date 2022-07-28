

workingDir = 'C:/Users/Daichi/Documents/Research Ultrasound Muscle/stacks/';
mkdir(workingDir)

%%DO NOT CHANGE THE FOLDER NAME! Leave it as images
mkdir(workingDir,'images')


AviVideo = VideoReader('Jmi_c.avi');


%% Convert avi video to tif images

ii = 1;

while hasFrame(AviVideo)
   img = readFrame(AviVideo);
   filename = [sprintf('%03d',ii) '.tif'];
   fullname = fullfile(workingDir,'images',filename);
   imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
   ii = ii+1;
end

%% Convert tif images to avi video

%Don't use this; use Fiji to save stack into avi
%{

imageNames = dir(fullfile(workingDir,'images','*.tif'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile(workingDir,'Converted.avi'));
outputVideo.FrameRate = AviVideo.FrameRate;
open(outputVideo)

for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,'images',imageNames{ii}));
   writeVideo(outputVideo,img)
end

%}