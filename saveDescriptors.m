function saveDescriptors(shad, noshad)
    img_date = '2011-05-16';
    if nargin ~= 2
        shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad.tif']);
        noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_plain_noshad.tif']);
        
        shad = shad(:,:,1);
        noshad = noshad(:,:,1);
        
        shad = shad(150:199, 370:419);
        noshad = noshad(150:199, 370:419);
    end
    
%     hsize = [50, 50];
%     shad = imfilter(shad, fspecial('gaussian', hsize, 20), 'replicate');
%     noshad = imfilter(noshad, fspecial('gaussian', hsize, 20), 'replicate');
    
    matte = shad ./ noshad;
    
    n_angles = 9;
    len = 20;
    n_descrs = 1000;
    
    descrs = repmat(PenumbraDescriptor(), n_descrs, 1);
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    p_pix = find(penumbra_mask == 1);   % penumbra pixels
    
    for n = 1:n_descrs
%         pixel = getRandomImagePoint(matte);
%         while penumbra_mask(pixel(2), pixel(1)) == 0
%             pixel = getRandomImagePoint(matte);
%         end
        [pixel(2) pixel(1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand()+0.5)));

        descrs(n) = PenumbraDescriptor(shad, pixel, n_angles, len, penumbra_mask, matte);
        if isnan(descrs(n).points)
            n = n-1;
        end
%         drawDescr(matte, descrs{n});
    end
    
%     drawDescr(shad, descrs);
    save('descrs.mat', 'descrs');
end