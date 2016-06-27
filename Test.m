close all;
clear;
%============================================== data input 
% add path to example data
file = mfilename('fullpath');
[pathstr,name,ext] = fileparts(file);
cd(pathstr);
parent = pwd;
addpath(genpath(parent));

%=========================
% choose patient
patient = 'p01'; %p01,p02,p03
%=========================

% data path
dcm_path = (strcat('../data/',patient)); 
filenames  = dir(fullfile(dcm_path, '*.dcm')); 
filenames = {filenames.name}; 

% m = number of files/images
m = numel(filenames);               

% store images in array
for k=12:m 
    d = filenames{k}; 
    file = fullfile(dcm_path, d); 
    dyn_var =  regexprep(d(1:14),'-','_');     
    images.(dyn_var)=dicomread(file);    
end 

for k=12:m
    %===========================================
    % preprocessing
    d = filenames{k};
    d = regexprep(d,'.dcm','');
    d = regexprep(d,'-','_');  
    
    img = images.(d);
    
    % window/leveling
    img_adj = imadjust(img,[0.49, 0.545]);
    img_adj = im2uint16(img_adj);
    
    % print to compare
    %figure
    %subplot(2,2,1), imshow(img,[]), title('original')
    %subplot(2,2,2), imshow(img_adj,[]), title('window/level')
    
    
    % ===============================
    % ground truth
    if(true)
        % read gt files
        pat_number = patient(3);
        gt_path = strcat('../data/ground_truth/p', pat_number, '_needle_positions.csv');
        gt_data = csvread(gt_path, 1, 1);
        
        %plot gt 
        x = [gt_data(k,1) gt_data(k,3)];
        y = [gt_data(k,2) gt_data(k,4)];
        figure, imshow(im2int16(img_adj),[]), title('window/level'), hold on
        plot(x, y, 'Color', 'r','LineWidth',2)
        hold off
    end
    %================================
    
    % hough transformation + plotting
    Hough((img_adj)); 
end
