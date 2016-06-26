function Hough(img)

%============================================ rotation
%imrotate(img, angle);
rotI = imrotate(img,0);

%figure, imshow(rotI), title('rotated image');


%============================================ edge operator
%edge(image,'operator','options') 
%operator = [sobel, prewitt, roberts, log, zerocross, canny] 
BW = edge(rotI,'sobel','vertical');

%figure, imshow(BW), title('edges');


%============================================ hough space
%hough(edgeImage,'option', value(s))
[H,theta,rho] = hough(BW,'Theta', -40:0.05:40);


%========================================================
% find best line candidate
%========================================================
% set a number of n Houghpeaks, find the best candidate of n Houghlines
% constrain the lines with a max length since the needle is limited
% sum up the intensities of each candidate and choose the brightest one
figure, imshow(rotI,[]), title('lines in image'), hold on

% choose #peaks and max needle length
numberPeaks = 3;
needleLength = 250;

% setup storage information
cellarray = cell(1,numberPeaks);
maxPoint_x = zeros(1,numberPeaks);
maxPoint_y = zeros(1,numberPeaks);
minPoint_x = zeros(1,numberPeaks);
minPoint_y = zeros(1,numberPeaks);
lastIdx = 1;
sumIntens = zeros(1,numberPeaks);
bestCandidate = 0;

for i = 1 : numberPeaks
    
    %========= hough peaks
    %houghpeaks(houghMatrix, numberOfPeaks,'option',value;
    P  = houghpeaks(H,i,'threshold',0.85*max(H(:)));

    %figure, imshow(H,[]), title('hough space'), hold on;
    %p_x = theta(P(:,2)); p_y = rho(P(:,1)); plot(p_x,p_y,'s','color','red');


    %========= hough lines
    %houghlines(edgeImg,theta,rho,peaks,'option', value);
    lines  = houghlines(BW,theta,rho,P,'FillGap',3.75,'MinLength',12.5);
    
    cellarray{i} = lines;
    
    if(~isempty(cellarray) && length(lines) >= lastIdx)        
         % obtain bottom and top points
         maxPoint_x(i) = cellarray{i}(length(lines)).point2(1);
         maxPoint_y(i) = cellarray{i}(length(lines)).point2(2);
         minPoint_x(i) = cellarray{i}(lastIdx).point1(1);
         minPoint_y(i) = cellarray{i}(lastIdx).point1(2);
        
         % update last element
         lastIdx = length(lines)+1;
        
        
         % obtain line elements from bresenham
         [all_x, all_y]= bresenham(minPoint_x(i), minPoint_y(i), maxPoint_x(i), maxPoint_y(i));
        
         %DEBUG==========
         %for k = 1: length(all_x)
         %    plot(all_x(k), all_y(k),'x','LineWidth',2,'Color', 'm') 
         %end
         %===============
    
         % constrain the needle length
         ending = length(all_y);        
         if length(all_x) > needleLength
            ending = needleLength;
         end
        
         % sum the intensities on the line candidate
         for j = 1 : ending
            sumIntens(i) = sumIntens(i) + cast((img(all_x(j), all_y(j))),'uint32');
         end

    end
end

% choose and store the best candidate
if(~isempty(cellarray))
    [maxIntens, bestCandidate] = max(sumIntens);    
end 

%============================================================
% line processing 
%===========================================================



%>>>>>>>>>>>>>>>>>>OPTIONS<<<<<<<<<<<<<<<<<<<<<<<<<<<
option1 = 1;    % plot all line segments            <
option2 = 0;    % plot min and max point of line    <
option3 = 0;    % plot brightest point + needle     <
option4 = 1;    % bresenham + brightest point       <
%>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<


% obtain highest and lowest point from one hough line(peak)
if(~isempty(cellarray))
   min_x = minPoint_x(bestCandidate);
   min_y = minPoint_y(bestCandidate);
   max_x = maxPoint_x(bestCandidate);
   max_y = maxPoint_y(bestCandidate);
end 


%========================== OPTION 1
% plot all line segments
if(option1 == 1)
    for k = 1 : length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end
%==========================

%========================== OPTION 2
% plot top and bottom of line
if(option2 == 1 && ~isempty(lines))
    plot(min_x, min_y,'x','LineWidth',2,'Color', 'r')
    plot(max_x, max_y,'x','LineWidth',2,'Color', 'g')
end
%===========================

%===============================================
% search on line(s)
%===============================================

%========================== OPTION 3
% find the most intense point (needle tip)
% constrain borders
if(option3 == 1 && ~isempty(lines))
    max_bright = max(img(:));
    [row, col] = find(img == max_bright); 
    cond_col = col > (size(img,1) * 0.1) & col < (size(img,1) * 0.9);
    pos = find(col(cond_col) == max(col(cond_col)), 1, 'last');
    bright_x = col(pos); 
    bright_y = row(pos);
    
    % brightest point in whole image (needle tip) = green ring
    plot(bright_x, bright_y, 'o', 'Color', 'g', 'LineWidth',2)
    
    % DEBUG: plot all brightest points (due to quantization)
    %plot(col, row, 'o', 'Color', 'g')  
    
    p_x = [bright_x min_x];
    p_y = [bright_y min_y];
    
    % plot segmented needle from tip (brightest point) to top
    if(min_y <= bright_y)
        plot(p_x, p_y, 'Color', 'g','LineWidth',2)        
    end
end 
%============================  
    
%============================ OPTION 4
% obtain all points on line using bresenham's algorithm
% find brightest point on line inside a tube (offset) as needle tip
if(option4 == 1 && ~isempty(lines))
    
    % all line points
    [all_x, all_y] = bresenham(min_x, min_y, max_x, max_y);
 
    % setup storage information
    %sum_hu = uint32(0);            % used later for best candidates
    %maxSum_hu = uint32(0);         % used later for best candidates
    off = 5;                        % offset   
    
    localIds = ones(1,length(all_x));         % index (offset) of local maximum
    localVls = zeros(1,length(all_x));        % value of local maximum
    
    % find brightest point in tube(offset) around the line
    % iterate over each point
    for i = 1 : length(all_x)
        
        % hold one row, initialize with smallest value 
        lineTmp = ones(1,off*2+1)*-Inf;
             
        % iterate over each offset point
        for j = -off : off
            
            lineTmp(j+off+1) =  rotI(all_y(i),all_x(i)+j);
            
            % DEBUG: plot all sampled pixels
            %plot(all_x(i)+j, all_y(i),'x','LineWidth',2,'Color', 'm')
        end
        
        % find index + value of max pixel in row and store it
        maxIdx = find(lineTmp == max(lineTmp));
        maxIdx = ceil(median(maxIdx));
        localIds(i) = maxIdx;
        localVls(i) = lineTmp(maxIdx);
        
        % DEBUG: plot all max values on offset lines
        %plot(all_x(i)-off-1+maxIdx, all_y(i), 'x','LineWidth',2,'Color', 'blue')
        
    end
    
    % find brightest points of local max
    maxV = max(localVls);
    cond = localVls >= maxV*0.6;
    tip_id = find(cond, 1, 'last');
    
    p_x = [all_x(tip_id)-off-1+localIds(tip_id) min_x];
    p_y = [all_y(tip_id) min_y];
    
    % plot segmented needle from tip (brightest point) to top
    % condition: tip has a high intensity
    if(min_y <= all_y(tip_id) && maxV >= max(rotI(:))*0.8)
        plot(p_x, p_y, 'Color', 'g','LineWidth',2)
        plot(all_x(tip_id)-off-1+localIds(tip_id), all_y(tip_id), 'o','LineWidth',2,'Color', 'g')
    length(all_y)
    end
    
end
%===================================
    
     
end