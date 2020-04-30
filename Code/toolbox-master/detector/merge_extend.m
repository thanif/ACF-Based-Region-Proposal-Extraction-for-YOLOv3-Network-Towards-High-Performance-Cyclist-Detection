function [ nbb ] = merge_extend( bbs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% sort bounding boxes from left to right
sortx = sortrows(bbs);

%% merge bounding boxes from left to right
s = size(sortx);
xt = 832;
yt = 832;
k=1;
for i= 1:s(1)
    for j=1:s(1)
        if s(1)==1
           mergedx(k,1) = sortx(i,1);
           mergedx(k,2) = sortx(i,2);
           k = k+1;
        end
        if i~=j
            %% find xmin and ymin
            if sortx(i,1) < sortx(j,1)
                xmin = sortx(i,1);
            end
            if sortx(i,1) >= sortx(j,1)
                xmin = sortx(j,1);
            end
            if sortx(i,2) < sortx(j,2)
                ymin = sortx(i,2);
            end
            if sortx(i,2) >= sortx(j,2)
                ymin = sortx(j,2);
            end
            %% check conditions for merging bounding boxes
            if xmin + xt >= sortx(i,1) + sortx(i,3) && xmin + xt >= sortx(j,1) + sortx(j,3) && ymin + yt >= sortx(i,2) + sortx(i,4) && ymin + yt >= sortx(j,2) + sortx(j,4) 
                %% top left point of the merged bounding box
                xb = xmin;
                yb = ymin;
                %% calculate height and width of the merged bounding box
                if sortx(i,1) + sortx(i,3) > sortx(j,1) + sortx(j,3)
                    wb = sortx(i,1) + sortx(i,3) - xmin;
                end
                if sortx(i,1) + sortx(i,3) <= sortx(j,1) + sortx(j,3)
                    wb = sortx(j,1) + sortx(j,3) - xmin;
                end
                if sortx(i,2) + sortx(i,4) > sortx(j,2) + sortx(j,4)
                    hb = sortx(i,2) + sortx(i,4) - ymin;
                end
                if sortx(i,2) + sortx(i,4) <= sortx(j,2) + sortx(j,4)
                    hb = sortx(j,2) + sortx(j,4) - ymin;
                end
                mergedx(k,1) = xb;
                mergedx(k,2) = yb;
                mergedx(k,3) = wb;
                mergedx(k,4) = hb;
                k = k+1;
            else
                mergedx(k,1) = xmin;
                mergedx(k,2) = ymin;
                k = k+1;
            end
        end
    end
end

%% find unique (x1,y1) from merged bounding boxes
topleft = unique(mergedx(:,1:2),'rows');

%% remove redundant bounding boxes and add (x2,y2) to be 832
s = size(topleft);
k = 1;
for i = 1:s(1)
   if i==1
       nbb(k,1) = topleft(i,1);
       nbb(k,2) = topleft(i,2);
       nbb(k,3) = 832;
       nbb(k,4) = 832;
       k=k+1;
   end
   if i~=1
       if topleft(i,1) >= nbb(k-1,1)+832
           nbb(k,1) = topleft(i,1);
           nbb(k,2) = topleft(i,2);
           nbb(k,3) = 832;
           nbb(k,4) = 832;
           k=k+1;
       end
   end
end

end