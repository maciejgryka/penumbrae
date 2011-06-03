function plotKNNError()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', '_rough1');
    load('descrs_small_all.mat');
    
    k = 1000;
    
    n_descrs = length(descrs);
    
    fprintf('getting matte values and knn for %i descriptors...', n_descrs);
%     slices = zeros(n_descrs, length(descrs(1).slices_shad));
%     mattes_gt = zeros(n_descrs,1);
%     for n = 1:n_descrs
%         c_descr = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);
%         slices(n,:) = c_descr.slices_shad;
%         mattes_gt(n) = matte(c_descr.center(2), c_descr.center(1));
%     end
    load('slices_mattes.mat');
    [best_descrs dists] = knnsearch(slices_shad', slices, 'K', k);

    fprintf('done\n');
    matte_vals = cat(1,descrs(:).center_pixel);
    
    errs = zeros(k,1);
    stds = zeros(k,1);
    fprintf('calculating errors for different values of k...\n');
    for kk = 1:k
        % get k nearest descriptors
        best = best_descrs(:,1:kk);
        % get k nearest distances
        d = dists(:,1:kk);
        % get suggested matte from each neighbor
        nn_mattes = matte_vals(best);
        % distance-based weights for each neighbor
        if kk == 1
            weights = ones(size(best,1), 1);
        else
            weights = 1-d./repmat(sum(d,2), 1, kk);
        end
        % normalize weights
        wsum = sum(weights,2);
        weights = weights./repmat(wsum, 1, kk);
        if sum(abs(sum(weights,2) - ones(n_descrs,1)) > 10^-5)
            kk
            error('weights do not sum up to 1');
        end
        % weighted average of suggested mattes
        weighted_mattes = sum(nn_mattes .* weights, 2);
        errs(kk) = mean(abs(weighted_mattes - mattes_gt));
        stds(kk) = std(abs(weighted_mattes - mattes_gt));
    end
%     figure;
    plot(errs, '*r');
    hold on;
    plot(errs+stds, 'xb')
    plot(errs-stds, 'xb')
    hold off;
    xlabel('k');
    ylabel('average error');
end