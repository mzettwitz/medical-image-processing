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
patient = 'p03'; %p01,p02,p03
%=========================

% data path
dcm_path = (strcat('../data/',patient)); 
filenames  = dir(fullfile(dcm_path, '*.dcm')); 
filenames = {filenames.name}; 

% m = number of files/images
m = numel(filenames);               

% store images in array
for k=1:m 
    d = filenames{k}; 
    file = fullfile(dcm_path, d); 
    dyn_var =  regexprep(d(1:14),'-','_');     
    images.(dyn_var)=dicomread(file);    
end 

for k=1:m
    %===========================================
    % preprocessing
    d = filenames{k};
    d = regexprep(d,'.dcm','');
    d = regexprep(d,'-','_');  
    
    img = images.(d);
    
    % window/leveling
    img_adj = imadjust(img,[0.49, 0.545]);
    img_adj = im2uint16(img_adj);
    
    % hough transformation + processing 
    [p_x, p_y] = Hough(img_adj,3);
    
    
    
    %=====================
    % print to compare
    if(false)
        figure
        subplot(2,2,1), imshow(img,[]), title('original')
        subplot(2,2,2), imshow(img_adj,[]), title('window/level')
        subplot(2,2,3), imshow(img_adj,[]), title('needle'), hold on
        plot(p_x, p_y, 'Color', 'g','LineWidth',2), hold off
    end
    %====================
        

    figure, imshow(im2int16(img_adj),[]), title('window/level'), hold on
    
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
        x_spitze = gt_data(k,1);
        y_spitze = gt_data(k,2);
        plot(x, y, 'Color', 'r','LineWidth',2)  
    end
    %================================ 
    
    plot(p_x, p_y, 'Color', 'g','LineWidth',2)
    hold off
      
    if (p_x(1,1) > 0 && x_spitze > 0)
        abstand(1,k) = sqrt(((p_x(1,1)-x_spitze)^2) + ((p_y(1,1)-y_spitze)^2));
        winkel(1,k) = atan((p_y(1,1) - p_y(1,2))/ (p_x(1,1) - p_x(1,2)));
        winkel_gt(1,k) = atan((gt_data(k,4)-y_spitze)/(gt_data(k,3)-x_spitze));
    end
end