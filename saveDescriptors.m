function saveDescriptors(shad, noshad)
    img_date = '2011-05-03';
    if nargin ~= 2
        shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad.tif']);
        noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_plain_noshad.tif']);
        
        shad = shad(:,:,1);
        noshad = noshad(:,:,1);
        
%         shad = shad(150:249, 370:469);
%         noshad = noshad(150:249, 370:469);
    end
    
%     hsize = [50, 50];
%     shad = imfilter(shad, fspecial('gaussian', hsize, 20), 'replicate');
%     noshad = imfilter(noshad, fspecial('gaussian', hsize, 20), 'replicate');
    
    matte = shad ./ noshad;
    
    n_angles = 1;
    length = 100;
    
    n_descrs = 500;
    descrs = cell(n_descrs, 1);
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    
    for n = 1:n_descrs
        pixel = getRandomImagePoint(matte);
        while penumbra_mask(pixel(2), pixel(1)) == 0
            pixel = getRandomImagePoint(matte);
        end

        descrs{n} = PenumbraDescriptor(shad, pixel, n_angles, length, penumbra_mask, matte);
%         drawDescr(matte, descrs{n});
    end
    
%     drawDescr(shad, descrs);
    save('descrs.mat', 'descrs');
end