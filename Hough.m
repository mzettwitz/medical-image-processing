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

P1 = houghpeaks(H,1,'threshold',0.85*max(H(:)));
lines1 = houghlines(BW,theta,rho,P1,'FillGap',2.5,'MinLength',4.5);

P2 = houghpeaks(H,2,'threshold',0.85*max(H(:)));
lines2 = houghlines(BW,theta,rho,P2,'FillGap',2.5,'MinLength',4.5);

P3 = houghpeaks(H,3,'threshold',0.85*max(H(:)));
lines3 = houghlines(BW,theta,rho,P3,'FillGap',2.5,'MinLength',4.5);

P4 = houghpeaks(H,4,'threshold',0.85*max(H(:)));
lines4 = houghlines(BW,theta,rho,P4,'FillGap',2.5,'MinLength',4.5);
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

y = length(lines1);
l1_max_x = lines1(4).point2(1);
l1_max_y = lines1(length(lines1)).point2(2);

l1_min_x = lines1(1).point1(1);
l1_min_y = lines1(1).point1(2);

l2_max_x = lines2(length(lines2)).point2(1);
l2_max_y = lines2(length(lines2)).point2(2);

l2_min_x = lines2(length(lines1)+1).point1(1);
l2_min_y = lines2(length(lines1)+1).point1(2);


l3_max_x = lines3(length(lines3)).point2(1);
l3_max_y = lines3(length(lines3)).point2(2);

l3_min_x = lines3(length(lines2)+1).point1(1);
l3_min_y = lines3(length(lines2)+1).point1(2);


l4_max_x = lines4(length(lines4)).point2(1);
l4_max_y = lines4(length(lines4)).point2(2);

l4_min_x = lines4(length(lines3)+1).point1(1);
l4_min_y = lines4(length(lines3)+1).point1(2);


%angezeigt wird das optisch bessere Bild, nicht das fuer die
%Hough-Transformation genutzte
figure, imshow(rotI,[]), title('lines in image'), hold on
for j = 1:length(lines1)
    %bresenham algorithmus
end
for j = length(lines1)+1: length (lines2)
     %bresenham algorithmus
end
for j = length(lines2)+1: length (lines3)
     %bresenham algorithmus
end
for j = length(lines3)+1: length (lines4)
     %bresenham algorithmus
end
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
    
    % Suchen des höchsten Punktes (Nadelschaft)
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

    % Auslassen von Artefakten(p01, Rand)
    %if(min_x < max_x)
     %   rect_around = img(min_y:max_y,min_x:max_x);
    %else
     %   rect_around = img(min_y:max_y,max_x:min_x);
    %end
    max_bright = max(img(:));
    if(img(max_x,max_y)< img *0.8)       
        [r, c] = find(img == max_bright); 
       % [r, c] = find(rect_around == max_bright); 
        cond_c = c < (size(img,1) * 0.9);
        pos = find(c(cond_c) == max(c(cond_c)), 1, 'last' );
        n_x = c(pos);
        n_y = r(pos);        
    else
        n_x = max_x;
        n_y = max_y;
    end
   % plot(n_x, n_y, 'o', 'Color', 'g')
   
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
    
    
     
end
