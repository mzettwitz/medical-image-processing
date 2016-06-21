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

%angezeigt wird das optisch bessere Bild, nicht das f?r die
%Hough-Transformation genutzte
figure, imshow(rotI,[]), title('lines in image'), hold on

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
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
    

    % Finden des hellsten Punktes (Nadelspitze)
    % Auslassen von Artefakten(p01, Rand), Gebieten am Rand
    max_bright = max(img(:));
    [r, c] = find(img == max_bright); 
    cond_c = c > (size(img,1) * 0.1) & c < (size(img,1) * 0.9);
    pos = find(c(cond_c) == max(c(cond_c)), 1, 'last' );
    n_x = c(pos); n_y = r(pos);
    plot(n_x, n_y, 'o', 'Color', 'g')
    %plot(c, r, 'o', 'Color', 'g')  % all points
    
    p_x = [n_x min_x ];
    p_y = [n_y min_y];
    if(min_y <= n_y)
        %Berechnung der Ausgleichsgerade bis zur Nadelspitze
        %p = polyfit(x,y,1);
        %t2 = 0:0.1:n_x;
        %y2 = polyval(p,t2);
        % Anzeigen von Gerade und Nadelspitze
        %plot(p_x,polyval(p,p_x),'o',t2,y2, 'LineWidth',2)
        plot(p_x, p_y, 'Color', 'g','LineWidth',2)
        
    end
    
    [all_x, all_y] = bresenham(min_x, min_y, max_x, max_y);
    sum_hu = 0;
    for i = 1 : size(all_x)
     rotI(all_x(i), all_y(i))
    end
    %sum_hu

    
    
     
end
