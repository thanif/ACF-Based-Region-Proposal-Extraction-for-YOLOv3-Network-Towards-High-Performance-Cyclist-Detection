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
imgNm=bbGt('getFiles',{[dataDir 'test/check_img']});
txtNm=bbGt('getFiles',{[dataDir 'test/check_txt']});

I=imread(imgNm{1,1});
obbs=acfDetect(I,detector);
nbb = merge_extend(obbs);
[patches, bbs] = bbApply('crop',I,nbb);

sp = size(patches);
%% saving images to obj directory
for j=1:sp(2)
    [filepath,name,ext] = fileparts(imgNm{1,1});
    if j==1
        new_path = [filepath '/' name '_1' '.jpg'];
    end
    if j==2
        new_path = [filepath '/' name '_2' '.jpg'];
    end
    imwrite(patches{1,j},new_path,'jpg');
end

% read the whole file to a temporary cell array
fid = fopen(txtNm{1,1},'rt');
tmp = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

obb = tmp{1,1};

s_nbb = size(nbb);
s_obb = size(obb);

for i=1:s_nbb(1)
    for j=2:s_obb(1)
        coord = split(obb(j,1));
        if str2double(coord(2)) >= nbb(i,1) && str2double(coord(2)) <= nbb(i,1)+nbb(i,3)
            [filepath,name,ext] = fileparts(txtNm{1,1});
            if i==1
                new_path = [filepath '/' name '_1' ext];
            end
            if i==2
                new_path = [filepath '/' name '_2' ext];
            end
            if i==3
                new_path = [filepath '/' name '_3' ext];
            end
            if i==4
                new_path = [filepath '/' name '_4' ext];
            end
            nc_1 = str2double(coord(2)) - nbb(i,1);
            nc_2 = str2double(coord(3)) - nbb(i,2);
            nc_3 = str2double(coord(4));
            nc_4 = str2double(coord(5));
            fid = fopen(new_path,'a+');
            fprintf(fid, '%s %f %f %f %f \n', ['0' string(nc_1) string(nc_2) string(nc_3) string(nc_4)]);
            fclose(fid);
        end
    end
end
