close all;
clear;

% add path to example data
file = mfilename('fullpath');
[pathstr,name,ext] = fileparts(file);
cd(pathstr);
parent = pwd;
addpath(genpath(parent));

patient = 'p01'; %p01,p02,p03
%Pfad des Ordners, in dem die Dicom-Datein liegen
dcm_path = (strcat('../data/',patient)); 
filenames  = dir(fullfile(dcm_path, '*.dcm')); 
filenames = {filenames.name}; 
% m = Anzahl aller Dateien
m = numel(filenames);               

% =================== read ground truth
pat_number = patient(3);
gt_path = strcat('../data/ground_truth/p', pat_number, '_needle_positions.csv');
gt_data = csvread(gt_path, 1, 1);

% store images in array
for k=1:m 
    d = filenames{k}; 
    f = fullfile(dcm_path, d); 
    dynamische_variable =  regexprep(d(1:14),'-','_');     
    bild.(dynamische_variable)=dicomread( f);
    
end 

for k=1:m
    d = filenames{k};
    d = regexprep(d,'.dcm','');
    d = regexprep(d,'-','_');  
    
    img = bild.(d);
    
    % window/leveling
    img_adj = imadjust(img, [0.49 0.525]); %[0.5045 0.5155]
   
    
    if mod(k,10) == 0
       %imtool(img); %find nice threshold for window/level every 10th img
    end
    
    % print to compare
    %figure
    %subplot(2,2,1), imshow(img,[]), title('original')
    %subplot(2,2,2), imshow(img_adj), title('window/level')
    
    
   % ===================== ground truth plot
   x = [gt_data(k,1) gt_data(k,3)];
   y = [gt_data(k,2) gt_data(k,4)];
   %figure, imshow(im2int16(img_adj),[]), title('window/level'), hold on
   %plot(x, y, 'Color', 'r','LineWidth',2)
   %hold off
   
   % ========================== hough transformation
   Hough((img_adj)); 
end
