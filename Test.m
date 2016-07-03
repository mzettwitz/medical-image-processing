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
for k=1:m 
    d = filenames{k}; 
    file = fullfile(dcm_path, d); 
    dyn_var =  regexprep(d(1:14),'-','_');     
    images.(dyn_var)=dicomread(file);    
end 

% storage for comparison
diff_dist = zeros(1,m);
diff_angle = zeros(1,m);

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
        plot(x, y, 'Color', 'r','LineWidth',2)  
        
        % storage for comparison
        gt_tip = [x(1), y(1)];
        gt_vec = [x(1) - x(2), y(1) - y(2)];
        n_tip = [p_x(1), p_y(1)];
        n_vec = [p_x(1) - p_x(2), p_y(1) - p_y(2)];
        
        % compute differences
        diff_dist(k) = norm(n_tip - gt_tip);
        diff_angle(k) = acosd(  dot(n_vec,gt_vec) / (norm(n_vec) * norm(gt_vec))  );
        
    end
    %================================ 
    
    plot(p_x, p_y, 'Color', 'g','LineWidth',2)
    hold off
end

filename_angle = strcat(patient, '_angle_differences.csv');
filename_dist = strcat(patient, '_distance_differences.csv');
csvwrite(filename_dist,diff_dist);
csvwrite(filename_angle, diff_angle);
diff_dist
diff_angle