function plotKNNError_32()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', '_rough1');
    load('descrs_small_all.mat');

    k = 5;
    
    n_descrs = length(descrs);
    
    fprintf('getting matte values and knn for %i descriptors...', n_descrs);
%     slices = zeros(n_descrs, length(descrs(1).slices_shad));
%     mattes_gt = zeros(n_descrs,1);
%     for n = 1:n_descrs
%         c_descr = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);
%         slices(n,:) = c_descr.slices_shad;
%         mattes_gt(n) = matte(c_descr.center(2), c_descr.center(1));
%     end
    fprintf('done\n');
    load('slices_mattes.mat');

%     [best_descrs dists] = knnsearch(slices_shad', slices, 'K', k);
    tree = kdtree(slices_shad');
    [idx pout] = kdtree_closestpoint(tree, slices);    
    dists1nn = (sqrt(sum((pout - slices).^2, 2)));
    
    diffs = zeros(n_descrs, 1);
    for p = 1:n_descrs
        knn = best_descrs(p,:);
        knn_f = best_descrs_f(p,:);
        curr_slice = slices(p,:);
        closest_slices = slices_shad(:, knn);
        closest_slices_f = slices_shad(:, knn_f);
        
        % euclidean distances from each of the suggested nn
        euclid_err = sqrt(sum((closest_slices - repmat(curr_slice', 1, k)).^2));
        % euclidean distances from each of the suggested nn (flann)
        euclid_err_f = sqrt(sum((closest_slices_f - repmat(curr_slice', 1, k)).^2));
        
        % if diffs(p) = 0 both algorithms propose equivalent solution
        % if negative flann does better
        % if positive matlab does better
        diffs(p) = mean(euclid_err) - mean(euclid_err_f);
    end
    
    plot(diffs);
    title({['difference between mean euclidean errors of k nearest neighbors for k = ' num2str(k)];
            'positive value means matlab does better, negative flann does better'});
    
    plot(mean(distsm)); 
    hold on;
    plot(mean(dists), 'r'); 
    hold off;

    fprintf('done\n');
%     plot(mean(dists));
    matte_vals = cat(1,descrs(:).center_pixel);
    
    errs = zeros(k,1);
    vars = zeros(k,1);
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
        vars(kk) = var(abs(weighted_mattes - mattes_gt));
    end
%     figure;
    plot(errs, '*r');
    hold on;
    plot(errs+vars, 'xb')
    plot(errs-vars, 'xb')
    hold off;
%     axis([0, 50, 0, 0.5]);
    xlabel('k');
    ylabel('average error');
%     errs = abs(mattes_gt - mattes_knn_wa);
%     mean(errs)
%     var(errs)
end