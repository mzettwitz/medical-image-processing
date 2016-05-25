function y = Hough_nadel(img)

%====================================== rotation
%imrotate(img, angle);
rotI = imrotate(img,0);

%figure imshow(rotI), title('rotated image');


%====================================== edge operator
%edge(image,'operator','options') 
%operator = [sobel, prewitt, roberts, log, zerocross, canny] 
BW = edge(rotI,'sobel','vertical');

%figure imshow(BW), title('edges');


%====================================== hough space
%[K,T,R] = hough(BW,'Theta', -85:0.05:85);
%K = imresize(K,[400 800]);
%figure imshow(K,[]), title('scaled hough space');

[H,theta,rho] = hough(BW,'Theta', -45:0.05:15);
%hough(edgeImage,'option', value(s))


%====================================== hough peaks
%houghpeaks(houghMatrix, numberOfPeaks,'option',value;
P = houghpeaks(H,1,'threshold',0.85*max(H(:)));

%figure imshow(H,[]), title('hough space'), hold on;
% p_x = theta(P(:,2)); p_y = rho(P(:,1)); plot(p_x,p_y,'s','color','red');

%====================================== hough lines
%houghlines(edgeImg,theta,rho,peaks,'option', value);
lines = houghlines(BW,theta,rho,P,'FillGap',2.5,'MinLength',4.5);


%====================================== print lines
x = [];
y = [];
min_y = 510;
max_x = 0;
min_x = 0;


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
    
    %Suchen des höchsten Punktes
    if ( y1 < min_y)
       min_y = y1;
       min_x = lines(k).point1(1);
    end

    if ( y2 < min_y)
       min_y = y1;
       min_x = lines(k).point2(1);
    end
    
%Suchen der Nadelspitze
     
    %Variante 1:
    
      %Suchen des tiefsten Punktes (Nadelspitze)
%     if ( y1 > max_y)
%        max_y = y1;
%        max_x = lines(k).point1(1);
%     end
% 
%     if ( y2 > max_y)
%        max_y = y1;
%        max_x = lines(k).point2(1);
%     end

end

%Berechnung der Ausgleichsgerade bis zur Nadelspitze
p = polyfit(x,y,1);

%Suchen der Nadelspitze
     
    %Variante 2:
        %Suche des hellsten Punktes
            %M: Wert des hellsten Punktes; I: Position (im Vektor)
        [M,I] = max(img(:));
        [I_row,I_col] = ind2sub(size(img),I);
        max_x = I_col;

    %Variante 3:
%         %hellsten Punkt auf der Geraden suchen
%         w = 0;
%         %x-Koordinaten der Gerade durchgehen
%      for m = 1:511
%        
%          % zugehörige y-Werte bestimmen und umwandeln
%         py1 = abs(int16(polyval(p,m)));
%         if (py1 <= 0)
%            py1 = int16(1);
%         end
%             %für die im Bildbereich liegenden Pixel:
%             if (py1 < 512)&&(py1 ~= 1)
%                  x1 = int16(m);
%                  %Bestimmen der Werte der auf der Gerade liegenden Pixel
%                  pixel = rotI(py1,x1);
%                 % Suchen des größeten Wertes
%                  if (pixel > w)
%                      w= pixel;
%                      max_x = m;
%                  end
%             end
%        end  

%     %Variante 4:
%      %Bestimmen der größten Differenz zwischen zwei Pixeln entalng der
%         %Geraden
%         diff_max = 0;
%     
%      %x-Koordinaten der Gerade durchgehen
%      for m = 1:511
%        
%          % zugehörige y-Werte bestimmen und umwandeln
%          py1 = abs(int16(polyval(p,m)));
%         if (py1 <= 0)
%               py1 = int16(1);
%         end
%         py2 = abs(int16(polyval(p,m+1)));
%          if (py2 <= 0)
%               py2 = int16(1) ;
%          end
%             %für die Bildbereich liegenden Pixel:
%             if (py1 < 512)&&(py2 < 512)&&(py1 ~= 1)&&(py2 ~= 1)
%                  x1 = int16(m);
%                  x2 = int16(m+1);
%                 %Bestimmen der Werte der auf der Gerade liegenden Pixel
%                  pixel1 = rotI(py1,x1);
%                  pixel2 =  rotI(py2,x2);
%                 diff = pixel1-pixel2;
%                  % Suchen der größten Differenz von zwei aufeinander folgenden Pixel
%                  if (diff > diff_max)
%                      diff_max= diff;
%                      max_x = m;
%                  end
%             end
%      end


        
        %Berechnung der Gerade
        if (min_x > max_x)
          h=max_x;
          max_x = min_x;
          min_x = h;
        end
        t2 = min_x:1:max_x;
        y2 = polyval(p,t2);
        
        %Ausgabe zu Varainte 1,3,4:
%          plot(max_x,polyval(p,max_x),'o',t2,y2, 'LineWidth',2)

        % Ausgabe zu Variante 2:
        plot(I_col,I_row,'o',t2,y2, 'LineWidth',2)
        
    % Ausgabe der Werte (zu Variante 2)
%     formatSpec = 'min_x: %5.0f ; max_x: %5.0f %5.0f ; y zu max_x: %5.0f ;  M: %5.0f \n';
%     fprintf (formatSpec,min_x,max_x,I_row,(polyval(p,max_x)),M);
    
     
end