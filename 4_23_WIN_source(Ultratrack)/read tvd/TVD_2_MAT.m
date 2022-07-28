% TVD_2_Mat.m - Script to convert TVD files saved with Telemed EchoWave II
% software to MAT files
%
% Inputs  - You will be prompted to select the TVD files
% Output  - .mat files with the same name & location as the TVD files
% containing a structure 'TVDdata' with the fields:
%         -TVDdata.Im - 3D array representing a stack of 2D grayscale images
%         -TVDdata.Time - Array of time stamps corresponding to each image
%         frame
%         -TVDdata.Height - height of image in pixels
%         -TVDdata.Width - width of image in pixels
%         -TVDdata.Fnum - number of image frames
%
% Created by Dominic Farris, School of Human Movement Studies, The University of Queensland
% 18/09/2015. 

clear

% Select the TVD files
[TVDfiles,TVDpaths] = uigetfile('*.tvd','Select the TVD files to convert','MultiSelect','on');

h = waitbar(0,['Overall Progress... (Processing File 1 of ' num2str(length(TVDfiles)) ')']);
hp = get(h,'Position');
set(h,'Position',[hp(1),hp(2)+hp(4),hp(3),hp(4)]);


% Read in each files data and write to MAT file
for i = 1:length(TVDfiles)
    
    waitbar(double(i-1)/double(length(TVDfiles)),h,...
        ['Overall Progress... (Processing File' num2str(i) 'of' num2str(length(TVDfiles)) ')'])
    
    TVDdata = readTVD([TVDpaths TVDfiles{i}]);
    
    save(strrep([TVDpaths TVDfiles{i}],'.tvd','.mat'),'TVDdata')

    
    clear TVDdata


end

waitbar(1,h,'Conversions Completed')
