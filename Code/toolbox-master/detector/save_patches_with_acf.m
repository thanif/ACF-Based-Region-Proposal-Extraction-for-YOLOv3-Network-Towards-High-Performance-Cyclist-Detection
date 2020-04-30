function [  ] = save_patches_with_acf( detector,imgNms, txtNms )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
s = size(imgNms);
for i = 1:s(2)
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
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_' '1' '.jpg'];
            end
            if j==2
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_' '2' '.jpg'];
            end
            if j==3
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_' '3' '.jpg'];
            end
            if j==4
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_' '4' '.jpg'];
            end
            if j==5
                filepath = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_' '5' '.jpg'];
            end
            imwrite(patches{1,j},filepath,'jpg');
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
                        new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_1' ext];
                    end
                    if k==2
                        new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_2' ext];
                    end
                    if k==3
                        new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_3' ext];
                    end
                    if k==4
                        new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_4' ext];
                    end
                    if k==5
                        new_path = ['/media/talha/73fb317f-f61e-4b1f-b59e-5121d06d212b/Code(ACF)/AlexeyABdarknet/data/obj/' name '_5' ext];
                    end
                    for z = 1:s_acf_bbs
                        if str2double(coord(2)) >= acf_bbs(z,1) && str2double(coord(2)) <= acf_bbs(z,1)+acf_bbs(z,3)
                            x1 = str2double(coord(2));
                            if x1 >= acf_bbs(z,1)
                                x1 = x1 - acf_bbs(z,1);
                            else
                                x1 = acf_bbs(z,1) - x1;
                            end
                            y1 = str2double(coord(3));
                            if y1 >= acf_bbs(z,2)
                                y1 = y1 - acf_bbs(z,2);
                            else
                                y1 = acf_bbs(z,2) - y1;
                            end
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
end
end
