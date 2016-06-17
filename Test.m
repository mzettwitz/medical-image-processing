close all;
clear;

% add path to example data
file = mfilename('fullpath');
[pathstr,name,ext] = fileparts(file);
cd(pathstr);
parent = pwd;
addpath(genpath(parent));


%Pfad des Ordners, in dem die Dicom-Datein liegen
dcm_path = ('../data/p01/'); 
filenames  = dir(fullfile(dcm_path, '*.dcm')); 
filenames = {filenames.name}; 
% m = Anzahl aller Dateien
m = numel(filenames);               

% store images in array
for k=1:m 
    d = filenames{k}; 
    f = fullfile(dcm_path, d); 
    dynamische_variable =  regexprep(d(1:14),'-','_');     
    bild.(dynamische_variable)=dicomread( f) ;
    
end 

% Variablen fuer die anisotrope Diffusion
num_iter = 20;
delta_t = 1/50;
kappa = 8;
option = 1;

for k=1:m
    d = filenames{k};
    d = regexprep(d,'.dcm','');
    d = regexprep(d,'-','_');  
    
    img = bild.(d);
    
    % convert into double for window/leveling
    img_d = im2double(img);
    img_adj = imadjust(img_d, [0.49 0.525]); %[0.5045 0.5155]
    
    % anisotropic diffusion filtering
    %img_filt = anisodiff2D(img_adj ,num_iter,delta_t,kappa,option);
    %img_filt = ordfilt2(img_adj,15,ones(5,5));
    
    % morphological closing
    se = strel('rectangle', [2 4]);
    %img_morph = imclose(img_filt, se);
    
    if mod(k,10) == 0
       %imtool(img_d); %find nice threshold for window/level every 10th img
    end
    
    % print to compare
    %figure
    %subplot(2,2,1), imshow(img,[]), title('original')
    %subplot(2,2,2), imshow(img_adj), title('window/level')
    %subplot(2,2,3), imshow(img_filt), title('filtered')
    %subplot(2,2,4), imshow(img_morph), title('morph')
    
%     if(k < m)
%         d_pre = filenames{k-1};
%         d_pre = regexprep(d_pre,'.dcm','');
%         d_pre = regexprep(d_pre,'-','_');
%         
%         subtract = bild.(d) - bild.(d_pre);
%         subtract = im2double(subtract);
%         sub_filt = ordfilt2(subtract,15,ones(5,5));
%         
%         % sub_filt = im2int16(sub_filt);
%         
%         %figure
%         %imtool(sub_filt)
%         
%         %if(subtract - )
%         
%     end
    
   % hough transformation
   Hough(im2int16(img_adj)); 
end
