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

%% run detector on check images
imgNms=bbGt('getFiles',{[dataDir 'test/check_img']});
txtNms=bbGt('getFiles',{[dataDir 'test/check_txt']});
for i = 1:length(imgNms)
    [filepath,name,ext] = fileparts(txtNms{1,i});
    I=imread(imgNms{1,i});
    acf_bbs=acfDetect(I,detector);
    if ~isempty(acf_bbs)
        %% merge and extend bounding boxes
        nbb = merge_extend(acf_bbs);
        %% crop patches covered by the bounding boxes
        [patches, bbs] = bbApply('crop',I,nbb);
        sp = size(patches);
        %% saving images to obj directory
        for j=1:sp(2)
            if j==1
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '1' '.jpg'];
            end
            if j==2
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '2' '.jpg'];
            end
            if j==3
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '3' '.jpg'];
            end
            if j==4
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '4' '.jpg'];
            end
            if j==5
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '5' '.jpg'];
            end
            imwrite(patches{1,j},filepath,'jpg');
        end
    else
        fid = fopen(txtNms{1,i},'rt');
        tmp = textscan(fid,'%s','Delimiter','\n');
        fclose(fid);
        
        obb = tmp{1,1};
        
        s_obb = size(obb);
        t1 = 1;
        for l=2:s_obb(1)
            coord = split(obb(l,1));
            acf_bbs(t1,1) = str2double(coord(2));
            acf_bbs(t1,2) = str2double(coord(3));
            acf_bbs(t1,3) = str2double(coord(4));
            acf_bbs(t1,4) = str2double(coord(5));
            
            t1=t1+1;
            
        end
        
        %% merge and extend bounding boxes
        nbb = merge_extend(acf_bbs);
        %% crop patches covered by the bounding boxes
        [patches, bbs] = bbApply('crop',I,nbb);
        sp = size(patches);
        %% saving images to obj directory
        for j=1:sp(2)
            if j==1
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '1' '.jpg'];
            end
            if j==2
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '2' '.jpg'];
            end
            if j==3
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '3' '.jpg'];
            end
            if j==4
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '4' '.jpg'];
            end
            if j==5
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_img/' name '_' '5' '.jpg'];
            end
            imwrite(patches{1,j},filepath,'jpg');
        end 
    end
    fid = fopen(txtNms{1,i},'rt');
    tmp = textscan(fid,'%s','Delimiter','\n');
    fclose(fid);

    obb = tmp{1,1};

    s_nbb = size(nbb);
    s_obb = size(obb);

    s_acf_bbs = size(acf_bbs);
    for k=1:s_nbb(1)
        for l=2:s_obb(1)
            coord = split(obb(l,1));
            if str2double(coord(2)) >= nbb(k,1) && str2double(coord(2)) <= nbb(k,1)+nbb(k,3)
                [filepath,name,ext] = fileparts(txtNms{1,i});
                if k==1
                    new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_txt/' name '_1' ext];
                end
                if k==2
                    new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_txt/' name '_2' ext];
                end
                if k==3
                    new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_txt/' name '_3' ext];
                end
                if k==4
                    new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_txt/' name '_4' ext];
                end
                if k==5
                    new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/data/Tsinghua-Daimler/test/check_txt/' name '_5' ext];
                end
                for z = 1:s_acf_bbs
                    if str2double(coord(2)) >= acf_bbs(z,1) && str2double(coord(2)) <= acf_bbs(z,1)+acf_bbs(z,3)
                        x1 = str2double(coord(2));
                        x1 = x1 - acf_bbs(z,1);
                        y1 = str2double(coord(3));
                        y1 = y1 - acf_bbs(z,2);
                        nc_1 = ((x1 + x1 + acf_bbs(z,3))/2)/832;
                        nc_2 = ((y1 + y1 + acf_bbs(z,4))/2)/832;
                        nc_3 = acf_bbs(z,3)/832;
                        nc_4 = acf_bbs(z,4)/832;
                        if nc_1 <= 1 && nc_2 <=1 && nc_3 <= 1 && nc_4 <= 1
                            fid = fopen(new_path,'a+');
                            fprintf(fid, '%s %f %f %f %f \n', ['0' string(nc_1) string(nc_2) string(nc_3) string(nc_4)]);
                            fclose(fid);
                        end
                    end
                end
            end
        end   
    end
end