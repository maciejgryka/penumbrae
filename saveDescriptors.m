function saveDescriptors(shad, noshad)
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', 'plain');
    rough = readSCDIm('C:\Work\research\shadow_removal\penumbrae\images\2011-05-16\2011-05-16_rough4_shad.tif');
    rough = rough(150:199, 370:459);
    rough = addZeroBorders(rough, len);
    
    descrs = repmat(PenumbraDescriptor(), n_descrs*2, 1);
    
    for n = 1:n_descrs*2
%         [pixel(2) pixel(1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand()+0.5)));

        if n <= n_descrs
            descrs(n) = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, matte);
        else
            descrs(n) = PenumbraDescriptor(rough, pixel(n-n_descrs,:), n_angles, len, matte);
        end
        
        if isnan(descrs(n).points)
            error('d.points = NaN');
        end
    end
    
    % concatenate slices_shad and slices_matte arrays and put the in one 
    % big matrix
    slices_shad = (cat(1,descrs(:).slices_shad_cat));
    slices_matte = (cat(1,descrs(:).slices_matte_cat));
    center_pixels = cat(1,descrs(:).center_pixel);
    
    drawDescr(shad, descrs);
    save('descrs_small_all.mat', 'descrs', 'slices_shad', 'slices_matte', 'center_pixels');
end