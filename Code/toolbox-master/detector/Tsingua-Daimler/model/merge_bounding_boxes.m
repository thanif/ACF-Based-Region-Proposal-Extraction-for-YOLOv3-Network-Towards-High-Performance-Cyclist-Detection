% Demo for aggregate channel features object detector on Inria dataset.
%
% See also acfReadme.m
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% extract training and testing images and ground truth
cd(fileparts(which('acfDemoTsinghua.m'))); dataDir='../../data/Tsinghua-Daimler/';
%for s=1:2, pth=dbInfo('InriaTest');
%  if(s==1), set='00'; type='train'; else set='01'; type='test'; end
%  if(exist([dataDir type '/posGt'],'dir')), continue; end
%  seqIo([pth '/videos/set' set '/V000'],'toImgs',[dataDir type '/pos']);
%  seqIo([pth '/videos/set' set '/V001'],'toImgs',[dataDir type '/neg']);
%  V=vbb('vbbLoad',[pth '/annotations/set' set '/V000']);
%  vbb('vbbToFiles',V,[dataDir type '/posGt']);
%end

%% set up opts for training detector (see acfTrain)
opts=acfTrain(); opts.modelDs=[50 32]; opts.modelDsPad=[64 48];
opts.posGtDir=[dataDir 'train/posGt']; opts.nWeak=[32 128 512 2048 4096];
opts.posImgDir=[dataDir 'train/pos']; opts.pJitter=struct('flip',1);
opts.negImgDir=[dataDir 'train/neg']; opts.pBoost.pTree.fracFtrs=1/4;
opts.pLoad={'squarify',{3,.41}}; opts.name='models/AcfTsinghua';

%% optionally switch to LDCF version of detector (see acfTrain)
if( 0 )
  opts.filters=[5 4]; opts.pJitter=struct('flip',1,'nTrn',3,'mTrn',1);
  opts.pBoost.pTree.maxDepth=3; opts.pBoost.discrete=0; opts.seed=2;
  opts.pPyramid.pChns.shrink=2; opts.name='models/LdcfTsinghua';
end

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
pModify=struct('cascThr',-1,'cascCal',.01);
detector=acfModify(detector,pModify);

%% run detector on a sample image (see acfDetect)
imgNms=bbGt('getFiles',{[dataDir 'test/check']});
I=imread(imgNms{1}); tic, bbs=acfDetect(I,detector); toc
%%figure(1); im(I); bbApply('draw',bbs); pause(.1);

%% sort bounding boxes from left to right
sortx = sortrows(bbs);

%% merge bounding boxes from left to right
s = size(sortx);
xt = 832;
yt = 832;
k=1;
for i= 1:s(1)
    for j=1:s(1)
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

%% display bounding boxes
figure(1); im(I); bbApply('draw',nbb); pause(.1);
