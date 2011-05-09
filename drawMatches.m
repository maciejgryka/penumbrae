function drawMatches()
    img_date = '2011-05-03';
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_shad.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_noshad.tif']);
    
    plain = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad.tif']);

    shad = shad(:,:,1);
    noshad = noshad(:,:,1);
    
    matte = shad ./ noshad;

    w = size(matte, 2);
    h = size(matte, 1);
    n_angles = 1;
    len = 100;
    n_descrs = 10;
    load('descrs.mat');
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    
    for n = 1:n_descrs
        p = getRandomImagePoint(shad);

        while penumbra_mask(p(2), p(1)) == 0
            p = getRandomImagePoint(matte);
        end

        c_descr = PenumbraDescriptor(shad, p, n_angles, len, penumbra_mask);

        [best_descr dist slice_err] = matchDescrs(c_descr, descrs);
            
        subplot(2,2,1); imshow(shad); hold on; c_descr.draw(); hold off;
        subplot(2,2,2); imshow(plain); hold on; descrs{best_descr}.draw(); hold off;

        subplot(2,2,3); plot(c_descr.slices_shad{1});
        subplot(2,2,4); plot(descrs{best_descr}.slices_shad{1});
    end
end