function y = Hough(img)

%====================================== rotation
%imrotate(img, angle);
rotI = imrotate(img,0);
%figure, imshow(rotI), title('rotated image');


%====================================== edge operator
%edge(image,'operator','options') 
%operator = [sobel, prewitt, roberts, log, zerocross, canny] 
BW = edge(rotI,'sobel','vertical');

%figure, imshow(BW), title('edges');


%====================================== hough space
%[K,T,R] = hough(BW,'Theta', -85:0.05:85);
%K = imresize(K,[400 800]);
%figure, imshow(K,[]), title('scaled hough space');

%hough(edgeImage,'option', value(s))
[H,theta,rho] = hough(BW,'Theta', -40:0.05:40);


%====================================== hough peaks
%houghpeaks(houghMatrix, numberOfPeaks,'option',value;
P = houghpeaks(H,1,'threshold',0.85*max(H(:)));

%figure, imshow(H,[]), title('hough space'), hold on;
%p_x = theta(P(:,2)); p_y = rho(P(:,1)); plot(p_x,p_y,'s','color','red');


%====================================== hough lines
%houghlines(edgeImg,theta,rho,peaks,'option', value);
lines = houghlines(BW,theta,rho,P,'FillGap',2.5,'MinLength',4.5);


%====================================== print lines
x = [];
y = [];
max_x = 0;
max_y = 0;
min_x = lines(1).point1(1);
min_y = lines(1).point1(2);

figure, imshow(rotI,[]), title('lines in image'), hold on

%==================================== search on lines
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    
    % ===============plot linesegments
    %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    % ===============
    
    %Vektor mit den x bzw. y Koordinaten der Punkte
    x = [x lines(k).point1(1) lines(k).point2(1)];
    y = [y lines(k).point1(2) lines(k).point2(2)];

    % y-Koordinaten der beiden gerade betrachteten Punkte
    y1 =  lines(k).point1(2);
    y2 =  lines(k).point2(2);
    
    %Suchen des tiefsten Punktes (Nadelspitze)
    if ( y1 > max_y)
       max_y = y1;
       max_x = lines(k).point1(1);
    end

    if ( y2 > max_y)
       max_y = y2;
       max_x = lines(k).point2(1);
    end
    
    % Suchen des h?chsten Punktes (Nadelschaft)
    if(y1 < min_y)
       min_y = y1;
       min_x = lines(k).point1(1);
    end
    
    if(y2 < min_y)
       min_y = y2;
       min_x = lines(k).point2(1);
    end
end
    
%==================================== search on lines
    % find the most intense point (needle tip)
    % cut off borders
    max_bright = max(img(:));
    [r, c] = find(img == max_bright); 
    cond_c = c > (size(img,1) * 0.1) & c < (size(img,1) * 0.9);
    pos = find(c(cond_c) == max(c(cond_c)), 1, 'last' );
    n_x = c(pos); n_y = r(pos);
    plot(n_x, n_y, 'o', 'Color', 'g')
    %plot(c, r, 'o', 'Color', 'g')  % all points
    
    %p_x = [n_x min_x];
    %p_y = [n_y min_y];
    
    
    if(min_y <= n_y)
        %Berechnung der Ausgleichsgerade bis zur Nadelspitze
        %p = polyfit(x,y,1);
        %t2 = 0:0.1:n_x;
        %y2 = polyval(p,t2);
        % Anzeigen von Gerade und Nadelspitze
        %plot(p_x,polyval(p,p_x),'o',t2,y2, 'LineWidth',2)
        %plot(p_x, p_y, 'Color', 'g','LineWidth',2)
        
        %===================== plot top and bottom of line
         plot(min_x, min_y,'x','LineWidth',2,'Color', 'r')
         plot(max_x, max_y,'x','LineWidth',2,'Color', 'y')
        
    end
    
    % obtain all points on line using bresenham's algorithm
    [all_x, all_y] = bresenham(min_x, min_y, max_x, max_y);
    
    %=================================================
    % find needle tip by finding the most intense point on line 
    %=================================================
    % setup storage information
    sum_hu = int32(0);
    maxSum_hu = cast(rotI(all_x(1), all_y(1)),'int32');
    maxPos = 1;
    delay = 0;
    offset = 5;
    
    % find brightest point in tube(offset) around the line
    tip_index = 0;
    maxBright = int32(-999999);
    
    tmpMatrix = zeros(11)
    
    for i = 1 : size(all_x)
        localMax = int32(-999999);
        locaId = 0;
        localVs = zeros(2*offset+1,1);
        for j = -offset : offset
            localVs(j+offset+1) =  rotI(all_x(i)+j,all_y(i));
            tmpMatrix(j+offset+1) = rotI(all_x(i)+j,all_y(i));
            
            plot(all_x(i)+j, all_y(i),'x','LineWidth',2,'Color', 'm')
            
            
            
            if(rotI(all_x(i)+j,all_y(i)) > localMax)
                localMax = rotI(all_x(i)+j,all_y(i));
                
                localId = j;
            end
        end
        
        [idx, value] = max(tmpMatrix)
        
        localVs
        localMax
        
       % plot(all_x(i), all_y(i)+localId,'x','LineWidth',2,'Color', 'm')
        if(localMax > maxBright)
           maxBright = localMax;
           tip_index = i;
        end
    end
    
%    p_x = [all_x(tip_index), min_x];
%    p_y = [all_y(tip_index), min_y];
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
    
    [pos grad] = maxGrad(all_x, all_y, rotI);   
    %plot(all_x(pos), all_y(pos),'x','LineWidth',2,'Color', 'm')
    
   % plot(all_x(maxPos), all_y(maxPos),'x','LineWidth',2,'Color', 'm')
    
    
     
end
