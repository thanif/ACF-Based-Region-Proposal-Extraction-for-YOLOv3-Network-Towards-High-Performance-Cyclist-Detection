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
opts.posGtDir=[dataDir 'new_train_set/posGt']; opts.nWeak=[32 128 512 2048 4096];
opts.posImgDir=[dataDir 'new_train_set/pos']; opts.pJitter=struct('flip',1);
opts.negImgDir=[dataDir 'new_train_set/neg']; opts.pBoost.pTree.fracFtrs=1/4;
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

%% test detector and plot roc (see acfTest)
%%[miss,~,gt,dt]=acfTest('name',opts.name,'imgDir',[dataDir 'new_test_set/pos'],...
%%  'gtDir',[dataDir 'new_test_set/posGt'],'pLoad',opts.pLoad,...
%%  'pModify',pModify,'reapply',0,'show',2);

%% run detector on training images and save patches
%%imgNms=bbGt('getFiles',{[dataDir 'new_train_set/pos']});
%%txtNms=bbGt('getFiles',{[dataDir 'new_train_set/posGt']});
%%save_patches(detector,imgNms, txtNms);

%% run detector on valid images and save patches
%%imgNms=bbGt('getFiles',{[dataDir 'new_valid_set/pos']});
%%txtNms=bbGt('getFiles',{[dataDir 'new_valid_set/posGt']});
%%save_patches(detector,imgNms, txtNms);

%% run detector on test images and save patches
%%imgNms=bbGt('getFiles',{[dataDir 'new_test_set/pos']});
%%txtNms=bbGt('getFiles',{[dataDir 'new_test_set/posGt']});
%%save_patches(detector,imgNms, txtNms);

%% run detector on non-empty depth images and save patches
imgNms=bbGt('getFiles',{[dataDir 'depth_imgs/actual_imgs']});
txtNms=bbGt('getFiles',{[dataDir 'depth_imgs/posGt']});
save_patches_from_depth(detector,imgNms, txtNms);


