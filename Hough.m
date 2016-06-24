function y = Hough(img)

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

%============================================ hough peaks
%houghpeaks(houghMatrix, numberOfPeaks,'option',value;
P = houghpeaks(H,1,'threshold',0.85*max(H(:)));

%figure, imshow(H,[]), title('hough space'), hold on;
%p_x = theta(P(:,2)); p_y = rho(P(:,1)); plot(p_x,p_y,'s','color','red');


%============================================ hough lines
%houghlines(edgeImg,theta,rho,peaks,'option', value);
lines = houghlines(BW,theta,rho,P,'FillGap',2.5,'MinLength',4.5);





%============================================================
% line processing 
%===========================================================
figure, imshow(rotI,[]), title('lines in image'), hold on


%>>>>>>>>>>>>>>>>>>OPTIONS<<<<<<<<<<<<<<<<<<<<<<<<<<<
option1 = 0;    % plot all line segments            <
option2 = 0;    % plot min and max point of line    <
option3 = 0;    % plot brightest point + needle     <
option4 = 1;    % bresenham + brightest point       <
option5 = 0;    % bresenham + max gradient          <
%>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<


% obtain highest and lowest point from one hough line(peak)
min_x = lines(1).point1(1);
min_y = lines(1).point1(2);
max_x = lines(length(lines)).point2(1);
max_y = lines(length(lines)).point2(2);

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
if(option2 == 1)
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
if(option3 == 1)
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
if(option4 == 1)
    
    % all line points
    [all_x, all_y] = bresenham(min_x, min_y, max_x, max_y);
 
    % setup storage information
    %sum_hu = uint32(0);         % used later for best candidates
    %maxSum_hu = uint32(0);      % used later for best candidates
    off = 5;                    % offset
    maxBright = uint32(0);
    
    tmpMatrix = zeros(11);
    
    tip_index = 1;
    localId = 0;        % index (offset) of local maximum
    
    % find brightest point in tube(offset) around the line
    % iterate over each point
    for i = 1 : size(all_x)
        
        % hold one row, initialize with smallest value 
        lineTmp = ones(1,off*2+1)*-Inf
        
        % local maximum on offset line
        localMax = uint32(0);
        
        % iterate over each offset point
        for j = -off : off
            
            % matrix with all values on offset line
            tmpMatrix(j+off+1) = rotI(all_x(i)+j, all_y(i));
           
            % update local maximum
            if(rotI(all_x(i)+j, all_y(i)) > localMax)
                localMax = rotI(all_x(i)+j, all_y(i));
                localId = j;
            end
            
            plot(all_x(i)+j, all_y(i),'x','LineWidth',2,'Color', 'm')
            lineTmp(j+off+1) =  rotI(all_y(i),all_x(i)+j)
        end
        
        % DEBUG: plot all sampled pixels
        maxIdx = find(lineTmp == max(lineTmp)) 
        all_y(i)
        plot(all_x(i)-off-1+maxIdx, all_y(i),'x','LineWidth',2,'Color', 'blue')
        % TODO: here we ended up yesterday <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        % [row, col]?
        %[idx, value] = find(tmpMatrix == max(tmpMatrix(:)));
        
        % DEBUG: plot all max values on offset lines
        %plot(all_x(i), all_y(i)+localId,'x','LineWidth',2,'Color', 'm')
        
        % find 'global' maximum (needle tip)
       % if(localMax > maxBright)
       %    maxBright = localMax;
       %    tip_index = i;
        %end
    end
    
    % plot brightest point
    %plot(all_x(tip_index)+localId, all_y(tip_index),'o','LineWidth',2,'Color', 'm')
end
%===================================

%=================================== OPTION 5
% find largest gradient on line
% TODO: find multiple candidates -> use deepest
% TODO: refactor
if(option5 ==1)
    %p_x = [all_x(tip_index), min_x];
    %p_y = [all_y(tip_index), min_y];
    %plot(p_x, p_y, 'Color', 'm','LineWidth',2)
    
    % obtain needle tip
%     for i = 1 : size(all_x)
%         val = cast(rotI(all_x(i), all_y(i)),'int32');   % get current value
%         sum_hu = sum_hu + val;                          % update sum
%         
%         if(sum_hu > maxSum_hu)
%             maxSum_hu = sum_hu;
%             maxPos = i;
%         end
%         if(sum_hu < maxSum_hu)
%             %delay = delay + 1;
%         end
%         if(delay > 15)
%             %break;
%         end
%         plot(all_x(maxPos), all_y(maxPos),'x','LineWidth',2,'Color', 'm')
%     end
    
    %[pos grad] = maxGrad(all_x, all_y, rotI);   
    %plot(all_x(pos), all_y(pos),'x','LineWidth',2,'Color', 'm')
    
    %plot(all_x(maxPos), all_y(maxPos),'x','LineWidth',2,'Color', 'm')
end
    
     
end