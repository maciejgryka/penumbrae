function tryToMatch()
    % clear all
    img_date = '2011-05-16';
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_shad_small.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_noshad_small.tif']);
  
    shad = shad(:,:,1);
    noshad = noshad(:,:,1);

    if isa(shad, 'uint8')
        shad = double(shad)/255;
        noshad = double(noshad)/255;
    end

    matte = shad ./ noshad;

    w = size(matte, 2);
    h = size(matte, 1);
    
    n_angles = 1;
    len = 20;
    n_descrs = 2000;
    
    k = 1;

    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    p_pix = find(penumbra_mask == 1);   % penumbra pixels

    incomplete_matte = zeros(h, w);
    load('descrs_small_all.mat');
    
    build_params.target_precision = 0.9;
    build_params.build_weight = 0.01;
    build_params.memory_weight = 0;
    [index, parameters] = flann_build_index(slices_shad', build_params);
    
    for n = 1:n_descrs
        [p(2) p(1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand()+0.5)));

        c_descr = PenumbraDescriptor(shad, p, n_angles, len, penumbra_mask);

        best_descr = flann_search(index,c_descr.slices_shad',k,parameters);
        if best_descr < 1 || best_descr > size(slices_shad,1)
            continue;
        end

        incomplete_matte = reconstructMatte(incomplete_matte, c_descr, descrs(best_descr));

%         subplot(2,1,1); imshow(shad); hold on; c_descr.draw('r'); descrs(best_descr).draw('b'); hold off;
%         subplot(2,1,2); plot(c_descr.slices_shad(1,:), 'r'); hold on; plot(descrs(best_descr).slices_shad(1,:), 'b'); hold off;
    end
    hold off;
    
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
    
%     heatmap = zeros(h, w);
%     figure; 
%     imshow(heatmap);hold on;
%     for d = 1:n_descrs
%         for s = 1:length(descrs(1).slices_shad)
%             plot(descrs(good_descrs(d)).points(s, 1:2, 1), ... 
%                  descrs(good_descrs(d)).points(s, 1:2, 2), ...
%                  'color', [slice_errs(d, s), slice_errs(d, s), slice_errs(d, s)]);
%         end
%     end
%     hold off;
end