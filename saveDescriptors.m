function saveDescriptors(shad, noshad)
    if nargin ~= 2
        shad = imread('C:\Work\research\shadow_removal\penumbrae\images\2011-04-18\2011-04-14_rough1_shadow.tif');
        noshad = imread('C:\Work\research\shadow_removal\penumbrae\images\2011-04-18\2011-04-14_rough1_noshad.tif');
        
        shad = shad(:,:,1);
        noshad = noshad(:,:,1);
    end
    
    matte = shad ./ noshad;
    
    n_angles = 10;
    length = 100;
    
    n_descrs = 500;
    descrs = cell(n_descrs);
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    
    for n = 1:n_descrs
        pixel = getRandomImagePoint(matte);
        while penumbra_mask(pixel(2), pixel(1)) == 0
            pixel = getRandomImagePoint(matte);
        end

        descrs{n} = PenumbraDescriptor(shad, pixel, n_angles, length, penumbra_mask, matte);
        drawDescr(matte, descrs{n});
    end
    
    save('descrs.mat', 'descrs');
end