function tryToMatch()
    [shads noshads mattes masks masks_s pixels_s n_angles scales] = prepareEnv('images/2011-07-04/test/', 'png');
    
    k = 5;
    
    shad = shads{1};
    
    for sc = 1:length(scales)
        fprintf('Computing matte at scale %i...\n', scales(sc));
        if sc == 1
            prev_scales_sum = 0;
            len = scales(sc);
        else
            prev_scales_sum = sum(scales(1:sc-1));
            len = scales(sc) - prev_scales_sum;
        end
        
        mask_s = masks_s{1,sc};
        pixel_s = pixels_s{1,sc};
        
        % load training data
        data_file_path = ['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'];
        if exist(data_file_path, 'file')
            load(data_file_path);
        else
            fprintf('\tno data at this scale\n');
            continue;
        end

        recovered_matte = ones(size(shad));
        
        if isnan(pixel_s)
            fprintf('\tno descriptors and this scale\n');
            continue;
        end

        fprintf('\tloading/calculating descriptors...\n');

        compute_c_descrs = 0;
        if compute_c_descrs
            % current (test) descriptors
            c_descrs = repmat(PenumbraDescriptor, size(pixel_s,1), 1);
            for n = 1:size(pixel_s,1)
                c_descrs(n) = PenumbraDescriptor(shad, pixel_s(n,:), n_angles, len, prev_scales_sum);
            end
            % current (test) spokes
            c_spokes_all = cat(1,c_descrs(:).spokes);
            save(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat'], 'c_descrs', 'c_spokes_all');
        else
            load(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat']);
        end
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(c_spokes_all,1);
        c_spokes_all = (c_spokes_all - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
        c_spokes = cell(2*n_angles, 1);
        for sa = 1:2*n_angles
            c_spokes{sa} = c_spokes_all(sa:2*n_angles:length(c_spokes_all), :);
        end
        
%         fprintf('\tapplying transformation...\n');
%         c_spokes_all_t = (L*c_spokes_all')';
        
%         % choosing dimensionality
%         % cull the spokes and c_spokes_all matrices to include only gradient or
%         % only intensity
%             % only gradient
%             spokes = spokes(:,1:size(spokes,2)/2);
%             c_spokes_all = c_spokes_all(:,1:size(c_spokes_all,2)/2);
%             % only intensity
%             spokes = spokes(:,size(spokes,2)/2:size(spokes,2));
%             c_spokes_all = c_spokes_all(:,size(c_spokes_all,2)/2:size(c_spokes_all,2));
            
        fprintf('\tfinding nearest neighbors...\n');
        best_descrs = cell(2*n_angles, 1);
        for sp = 1:2*n_angles
            best_descrs{sp} = knnsearch(spokes{sp},c_spokes{sp},'K', k, 'NSMethod', 'kdtree');
            best_descrs{sp} = getBestDescrs(best_descrs{sp}, descrs, c_spokes_all, k);
        end

        best_mattes = zeros(100, 100, 2*n_angles);
        best_mattes(:,:,1) = cat(1, descrs(best_descrs{1}).center_pixel);
        best_mattes(:,:,2) = cat(1, descrs(best_descrs{2}).center_pixel);
        best_mattes(:,:,3) = cat(1, descrs(best_descrs{3}).center_pixel);
        best_mattes(:,:,4) = cat(1, descrs(best_descrs{4}).center_pixel);

        best_mattes = mean(best_mattes, 3);
        recovered_matte(sub2ind(size(shad), pixel_s(:,2), pixel_s(:,1))) = cat(1, descrs(best_descrs{2}).center_pixel);
        
%         err = mean(abs(matte(mattes{sc} < 1) - recovered_matte(mattes{sc} < 1)))
        
%         bl = 3;
%         subplot(2,3,[1 4]);
%             imshow(shad);
%         subplot(2,3,2);
%             ms = mattes{1} .* (mask_s == 1);
%             ms(ms == 0) = 1;
%             imshow(ms);
%         subplot(2,3,5);
%         imshow(imfilter(r ecovered_matte, fspecial('gaussian', bl, bl),'replicate'));
%         subplot(2,3,6);
%         imshow(shad ./ imfilter(recovered_matte, fspecial('gaussian', bl, bl),'replicate'));
%         subplot(2,3,3);
%         imshow(shad ./ ms);

        subplot(2,3,[1 4]);
            imshow(shad);
        subplot(2,3,2);
            ms = mattes{1} .* (mask_s == 1);
            ms(ms == 0) = 1;
            imshow(ms);
        subplot(2,3,5);
        imshow(recovered_matte);
        subplot(2,3,6);
        imshow(shad ./ recovered_matte);
        subplot(2,3,3);
        imshow(shad ./ ms);
    end
end

function best_descrs = getBestDescrs(best_descrs, descrs, c_spokes_all, k)
%     % turn spoke indices into descriptor indices
%     best_descrs = ceil(best_descrs./(n_angles*2));
    % each row in below matrix contains a (len*2)*(2*n_angles) vector
    % representing all spokes of one descriptor
    descr_vectors = reshape(cat(1,descrs(best_descrs).spokes)', 40, [])';
    % same for current (test) descriptors
    c_descr_vectors = reshape(c_spokes_all', 40, [])';

    cdvi = repmat(1:size(c_descr_vectors,1), k, 1); % c_descr_vector indices
    c_descr_vectors = c_descr_vectors(cdvi(:), :);
    d = sum((c_descr_vectors - descr_vectors).^2, 2); % distance from each test descriptor to its k nn
    d = reshape(d', k, [])';
    [val inds] = min(d, [], 2);  % inds are column indices for best descriptor in each row of best_descrs{sp}
    subs = [(1:size(best_descrs,1))' inds]; % turn column indices into subscripts
    inds = sub2ind(size(d), subs(:,1), subs(:,2)); % proper indices
    best_descrs = best_descrs(inds); % list if best descriptors for each spoke
end