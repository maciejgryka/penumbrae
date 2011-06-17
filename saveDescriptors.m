function saveDescriptors(shad, noshad)
    date = '2011-06-13';
    suffix = 'plain';
    [shad noshad matte penumbra_mask n_angles scales] = prepareEnv(date, suffix);
    rough = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' date '\' date '_rough4_shad.tif']);
    rough = rough(150:299, 370:559);
    
    n_ims = 2;
    
    % cell containing in each row an image from which to caluclate 
    % descriptors as well as list of pixel coords at which the descriptors
    % should be centered
    shadmatte = cell(n_ims, 2);
    
    for sc = 1:length(scales)
        fprintf('Computing descriptors at scale %i...\n', scales(sc));
        len = scales(sc);
        
        % pad the images with zero-borders of width len
        shad_s = addBorders(shad, len);
        rough_s = addBorders(rough, len);
%         noshad_s = addBorders(noshad, len);
        matte_s = addBorders(matte, len);
        penumbra_mask_s = addBorders(penumbra_mask, len);
                
        % get pixels where descriptors at given sale can be calculated
        penumbra_mask_s = getPenumbraMaskAtScale(penumbra_mask_s, scales(sc));
        p_pix = find(penumbra_mask_s' == 1);
        if (isempty(p_pix))
            fprintf('\tno descriptors and this scale\n');
            continue;
        end
        pixel = zeros(length(p_pix), 2);
        [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask_s'), p_pix);
            
        shadmatte{1,1} = shad_s;
        shadmatte{2,1} = rough_s;
        shadmatte{1,2} = pixel;
        shadmatte{2,2} = pixel;
        
        % overall number of descriptors to find equals the sum of pixels
        descrs = repmat(PenumbraDescriptor(), size(cat(1, shadmatte{:,2}), 1), 1);

        curr_descr = 1;
        for i = 1:n_ims
            fprintf('\timage %i...\n', i);
            for p = 1:length(p_pix)
                descrs(curr_descr) = PenumbraDescriptor(shadmatte{i,1}, shadmatte{i,2}(p,:), n_angles, len, matte_s);

                curr_descr = curr_descr+1;
            end
        end
    
        fprintf('\tconcatenating slices...\n');
        % concatenate slices_shad and slices_matte arrays and put the in one 
        % big matrix
        spokes = (cat(1,descrs(:).spokes));
        center_pixels = cat(1,descrs(:).center_pixel);
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(spokes,1);
        spokes_mu = mean(spokes);
        spokes_std = std(spokes);
        
        spokes = (spokes - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);

%         drawDescr(shad, descrs);
        fprintf('\tsaving results...\n');
        save(['descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), '.mat'], 'descrs', 'spokes', 'spokes_mu', 'spokes_std', 'center_pixels');
    end
end