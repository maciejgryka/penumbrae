function tryToMatch()
    % clear all
    img_date = '2011-05-03';
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_shad.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_noshad.tif']);

    shad = shad(:,:,1);
    noshad = noshad(:,:,1);

    % hsize = [50, 50];
    % shad = imfilter(shad, fspecial('gaussian', hsize, 20), 'replicate');
    % noshad = imfilter(noshad, fspecial('gaussian', hsize, 20), 'replicate');

    matte = shad ./ noshad;

    n_angles = 5;
    len = 100;
    n_descrs = 10;

    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;

    incomplete_matte = zeros(480, 640);
    heatmap = zeros(480, 640);
    load('descrs.mat');
    good_descrs = cell(n_descrs, 1);
    for n = 1:n_descrs
        p = getRandomImagePoint(shad);

        while penumbra_mask(p(2), p(1)) == 0
            p = getRandomImagePoint(matte);
        end

        c_descr = PenumbraDescriptor(shad, p, n_angles, len, penumbra_mask);

        [best_descr dist] = matchDescrs(c_descr, descrs);
        good_descrs{n} = best_descr;
%         dist = evaluateDescriptorMatch(c_descr, descrs{best_descr});
%         dist = dist / 400;
%         if dist > 1
%             dist = 1;
%         end
        
        % update error image
%         close all;
%         h = figure('visible', 'off');
%         a = axes('parent', h);
%         imshow(heatmap); hold on;
%         descrs{best_descr}.draw([dist dist dist]); hold off;
%         heatmap = frame2im(getframe);
% %         heatmap = f.cdata(:,:,1);

        incomplete_matte = reconstructMatte(incomplete_matte, descrs{best_descr});
    end

    matte = ones(480, 640);
    matte(penumbra_mask) = NaN; % fill the penumbra region with NaNs
    % replace NaNs where values are known
    matte(incomplete_matte > 0) = incomplete_matte(incomplete_matte > 0);
    % inpaint remaining NaNs
    matte = inpaint_nans(matte);
    % ensure only the penumbra region is affected
    matte = 1 - penumbra_mask + matte .* penumbra_mask;
    subplot(2,2,1);
    imshow(shad);
    subplot(2,2,2);
    imshow(matte);
    subplot(2,2,3);
    imshow(shad ./ matte);
    subplot(2,2,4);
    imshow(heatmap);
end