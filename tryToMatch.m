function tryToMatch()
    % clear all
    img_date = '2011-05-03';
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough1_shad.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough1_noshad.tif']);

    plain = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_plain_shad.tif']);
    plain_noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_plain_noshad.tif']);
    
    shad = shad(:,:,1);
    noshad = noshad(:,:,1);

    shad = shad(150:199, 370:419);
    noshad = noshad(150:199, 370:419);
    plain = plain(150:199, 370:419);
    plain_noshad = plain_noshad(150:199, 370:419);
    
    shad = plain;
    noshad = plain_noshad;

    % hsize = [50, 50];
    % shad = imfilter(shad, fspecial('gaussian', hsize, 20), 'replicate');
    % noshad = imfilter(noshad, fspecial('gaussian', hsize, 20), 'replicate');

    matte = shad ./ noshad;

    w = size(matte, 2);
    h = size(matte, 1);
    
    n_angles = 1;
    len = 20;
    n_descrs = 500;

    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    p_pix = find(penumbra_mask == 1);   % penumbra pixels

    incomplete_matte = zeros(h, w);
    load('descrs.mat');
    good_descrs = zeros(n_descrs, 1);
    slice_errs = zeros(n_descrs, length(descrs(1).slices_shad));
%     imshow(penumbra_mask); hold on;
    for n = 1:n_descrs
        [p(2) p(1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand()+0.5)));

        c_descr = PenumbraDescriptor(shad, p, n_angles, len, penumbra_mask);

        [best_descr dist slice_err] = matchDescrs(c_descr, descrs);
        good_descrs(n) = best_descr;
        slice_errs(n, :) = slice_err;
        
        dist
%         if dist > 0.001
%             continue;
%         end
        
        incomplete_matte = reconstructMatte(incomplete_matte, c_descr, descrs(best_descr), matte);

        subplot(2,2,1); imshow(shad); hold on; c_descr.draw(); hold off;
        subplot(2,2,2); imshow(plain); hold on; descrs(best_descr).draw(); hold off;

        subplot(2,2,3); plot(c_descr.slices_shad{1});
        subplot(2,2,4); plot(descrs(best_descr).slices_shad{1});
    end
    hold off;
    slice_errs = slice_errs ./ max(max(slice_errs));
    
    matte = ones(h, w);
    matte(penumbra_mask) = NaN; % fill the penumbra region with NaNs
    % replace NaNs where values are known
    matte(incomplete_matte > 0) = incomplete_matte(incomplete_matte > 0);
    % inpaint remaining NaNs
    matte = inpaint_nans(matte);
    % ensure only the penumbra region is affected
    matte = 1 - penumbra_mask + matte .* penumbra_mask;
%     matte(matte < 0.1) = 1;
    subplot(2,2,1);
    imshow(shad);
    subplot(2,2,2);
    imshow(matte);
    subplot(2,2,3);
    imshow(shad ./ matte);
    subplot(2,2,4);
    imshow(shad./noshad);
    
    heatmap = zeros(h, w);
    figure; 
    imshow(heatmap);hold on;
    for d = 1:n_descrs
        for s = 1:length(descrs(1).slices_shad)
            plot(descrs(good_descrs(d)).points(s, 1:2, 1), ... 
                 descrs(good_descrs(d)).points(s, 1:2, 2), ...
                 'color', [slice_errs(d, s), slice_errs(d, s), slice_errs(d, s)]);
        end
    end
    hold off;
end