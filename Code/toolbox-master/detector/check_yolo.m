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

%% run detector on train images and save patches
imgNms=bbGt('getFiles',{[dataDir 'train/pos']});
txtNms=bbGt('getFiles',{[dataDir 'train/posGt']});
save_patches(detector,imgNms, txtNms);

%% run detector on test images and save patches
imgNms=bbGt('getFiles',{[dataDir 'test/pos']});
txtNms=bbGt('getFiles',{[dataDir 'test/posGt']});
save_patches(detector,imgNms, txtNms);
