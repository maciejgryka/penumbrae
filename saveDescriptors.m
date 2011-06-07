function saveDescriptors(shad, noshad)
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', 'plain');
    rough = readSCDIm('C:\Work\research\shadow_removal\penumbrae\images\2011-05-16\2011-05-16_rough4_shad.tif');
    rough = rough(150:199, 370:459);
    rough = addZeroBorders(rough, len);
    
    n_ims = 2;
    
    scales = [3, 5, 10, 20, 50, 100];
    scales = [10];
    
    % cell containing in each row an image from which to caluclate 
    % descriptors as well as list of pixel coords at which the descriptors
    % should be centered
    shadmatte = cell(n_ims, 2);
    shadmatte{1,1} = shad;
    shadmatte{2,1} = rough;
    
    for sc = 1:length(scales)
        fprintf('Computing descriptors at scale %i...\n', sc);
        len = scales(sc);
        % get pixels where descriptors at given sale can be calculated
        penumbra_mask = getPenumbraMaskAtScale(penumbra_mask, sc);
        p_pix = find(penumbra_mask' == 1);
        [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask'), p_pix);
        n_descrs = length(p_pix);
        
        shadmatte{1,2} = pixel;
        shadmatte{2,2} = pixel;
        
        % overall number of descriptors to find equals the sum of pixels
        descrs = repmat(PenumbraDescriptor(), size(cat(1, shadmatte{:,2}), 1), 1);

        curr_descr = 1;
        for i = 1:n_ims
            fprintf('\timage %i...\n', i);
            for p = 1:length(p_pix)
                descrs(curr_descr) = PenumbraDescriptor(shadmatte{i,1}, shadmatte{i,2}(p,:), n_angles, len, matte);

                if isnan(descrs(curr_descr).points)
                    error('d.points = NaN');
                end
                curr_descr = curr_descr+1;
            end
        end
    
        fprintf('\tconcatenating slices...\n');
        % concatenate slices_shad and slices_matte arrays and put the in one 
        % big matrix
        slices_shad = (cat(1,descrs(:).slices_shad_cat));
        slices_matte = (cat(1,descrs(:).slices_matte_cat));
        center_pixels = cat(1,descrs(:).center_pixel);

    %     drawDescr(shad, descrs);
        fprintf('\tsaving results...\n');
        save(['descrs_small_sc' int2str(sc), '.mat'], 'descrs', 'slices_shad', 'slices_matte', 'center_pixels');
    end
end