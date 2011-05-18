function saveDescriptors(shad, noshad)
    img_date = '2011-05-16';
    if nargin ~= 2
        shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad_small.tif']);
        noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_plain_noshad_small.tif']);
        
        shad = shad(:,:,1);
        noshad = noshad(:,:,1);
        
%         shad = shad(150:249, 370:469);
    end
    
    matte = shad ./ noshad;
    
    n_angles = 1;
    len = 30;
    n_descrs = 3000;
    
    descrs = repmat(PenumbraDescriptor(), n_descrs, 1);
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    p_pix = find(penumbra_mask == 1);   % penumbra pixels
    
    for n = 1:n_descrs
        [pixel(2) pixel(1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand()+0.5)));

        descrs(n) = PenumbraDescriptor(shad, pixel, n_angles, len, penumbra_mask, matte);
        if isnan(descrs(n).points)
            n = n-1;
        end
    end
    
    % concatenate slices_shad and slices_matte arrays and put the in one 
    % big matrix with dimensions     [(n_descrs*n_angles) X len]
    slices_shad = cat(1,descrs(:).slices_shad);
    slices_matte = cat(1,descrs(:).slices_matte);
    
    drawDescr(shad, descrs);
    save('descrs.mat', 'descrs', 'slices_shad', 'slices_matte');
end