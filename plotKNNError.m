function plotKNNError()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', '_rough1');
    load('descrs_small_all.mat');
    
%     build_params.target_precision = 1;
% 	build_params.build_weight = 0.01;
% 	build_params.memory_weight = 0;
% 	[index, parameters] = flann_build_index(slices_shad, build_params);

    k = 100;
    
    % number of descriptors to be found
    n_descrs = length(p_pix);
    
    fprintf('getting matte values and knn for %i descriptors...', n_descrs);
    slices = zeros(n_descrs, length(descrs(1).slices_shad));
    mattes_gt = zeros(n_descrs,1);
    c_descrs = repmat(PenumbraDescriptor, n_descrs, 1);
    for n = 1:n_descrs
        c_descrs(n) = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);
        mattes_gt(n) = matte(c_descrs(n).center(2), c_descrs(n).center(1));
    end
    slices = cat(1,c_descrs(:).slices_shad);
    save('slices_mattes.mat', 'slices', 'mattes_gt');
    load('slices_mattes.mat');
    [best_descrs dists] = knnsearch(slices_shad', slices, 'K', k);
    
%     [best_descrs dists] = flann_search(index, slices', k, parameters);
%     best_descrs = best_descrs';
%     dists = dists';

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
    ylabel('average error (red) with +/- std bounds');
end