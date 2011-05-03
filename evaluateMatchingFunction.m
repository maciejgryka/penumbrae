function evaluateMatchingFunction()
    % clear all
    img_date = '2011-05-03';
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough1_shad.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough1_noshad.tif']);

    shad = shad(:,:,1);
    noshad = noshad(:,:,1);

    % hsize = [50, 50];
    % shad = imfilter(shad, fspecial('gaussian', hsize, 20), 'replicate');
    % noshad = imfilter(noshad, fspecial('gaussian', hsize, 20), 'replicate');

    matte = shad ./ noshad;

    n_angles = 5;
    len = 100;

    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    
    load('descrs.mat');
    
    n_descrs = 500;

    euclid_dist = zeros(n_descrs, 1);
    for d = 1:n_descrs
        p = getRandomImagePoint(shad);

        while penumbra_mask(p(2), p(1)) == 0
            p = getRandomImagePoint(matte);
        end

        c_descr = PenumbraDescriptor(shad, p, n_angles, len, penumbra_mask);
        best_descr = matchDescrs(c_descr, descrs);

        euclid_dist(d) = norm(c_descr.center - descrs{best_descr}.center);
    end
    mean(euclid_dist)
    std(euclid_dist)
    hist(euclid_dist)
end