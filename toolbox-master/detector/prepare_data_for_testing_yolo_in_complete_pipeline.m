% Demo for aggregate channel features object detector on Inria dataset.
%
% See also acfReadme.m
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% extract training and testing images and ground truth
cd(fileparts(which('acfDemoTsinghua.m'))); dataDir='../../data/Tsinghua-Daimler/';

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

%% run detector on training images and save patches
imgNm=bbGt('getFiles',{['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/test/imgs/']});
for i = 1:length(imgNm)
    [filepath,name,ext] = fileparts(imgNm{1,i});
    mkdir(['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/test/results/' name]);

    I=imread(imgNm{1,i});
    obbs=acfDetect(I,detector);
    if obbs
        nbb = merge_extend(obbs);
        [patches, bbs] = bbApply('crop',I,nbb);

        s = size(nbb);

        fid = fopen(['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/test/results/' name '/pr.txt'],'w');
        for j=1:s(1)
            fprintf(fid, '%f %f \n', [string(nbb(j,1)) string(nbb(j,2))]);
        end
        fclose(fid);

        sp = size(patches);
        %% saving images to obj directory
        for k=1:sp(2)
            filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/test/results/' name];
            if k==1
                new_path = [filepath '/' name '_1' '.png'];
            end
            if k==2
                new_path = [filepath '/' name '_2' '.png'];
            end
            if k==3
                new_path = [filepath '/' name '_3' '.png'];
            end
            if k==4
                new_path = [filepath '/' name '_4' '.png'];
            end
            imwrite(patches{1,k},new_path,'png');
        end
    else
        imwrite(I,['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/test/results/' name '/' 'result.png'],'png');
    end
end
