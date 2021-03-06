function saveDescriptors()
    [shads noshads mattes masks masks_s pixels_s n_angles scales] = prepareEnv('images/2011-07-04/subset/', 'png');
    
    n_ims = length(shads);
%     n_spokes = 2*n_angles;

    for sc = 1:length(scales)
        fprintf('Computing descriptors at scale %i...\n', scales(sc));
        if sc == 1
            prev_scales_sum = 0;
            len = scales(sc);
        else
            prev_scales_sum = sum(scales(1:sc-1));
            len = scales(sc) - prev_scales_sum;
        end

        % overall number of descriptors to find equals the number of penumbra pixels
        descrs = repmat(PenumbraDescriptor(), size(cat(1, pixels_s{:,sc}), 1), 1);
        
        % each row in below matrix will contain a (len*2)*(2*n_angles) vector
        % representing all spokes of one descriptor
        descrs_vectors = zeros(length(descrs), 2*n_angles*2*scales(sc));

        curr_descr = 1;
        for i = 1:n_ims
            if isempty(pixels_s{i, sc})
                continue;
            end
            fprintf('\timage %i...\n', i);
            for p = 1:size(pixels_s{i, sc},1)
                descrs(curr_descr) = PenumbraDescriptor(shads{i}, pixels_s{i, sc}(p,:), n_angles, len, prev_scales_sum, mattes{sc});
                descrs_vectors(curr_descr, :) = reshape(descrs(curr_descr).spokes', 2*n_angles*2*scales(sc), [])';
                curr_descr = curr_descr+1;
            end
        end
    
        fprintf('\tconcatenating slices...\n');
        spokes_all = cat(1,descrs(:).spokes);
        center_pixels = cat(1,descrs(:).center_pixel);
        center_pixels_int = cat(1,descrs(:).center_pixel_int);
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(spokes_all,1);
        spokes_mu = mean(spokes_all);
        spokes_std = std(spokes_all);
        
        spokes_all = (spokes_all - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
        % create separate array for each spoke direction in [1, 2, ..., 2*n_angles]
        spokes = cell(2*n_angles, 1);
        for sa = 1:2*n_angles
            spokes{sa} = spokes_all(sa:2*n_angles:length(spokes_all), :);
        end
        
%         % Do distance learning, transform the space
%         addpath('C:/Work/research/dev/LMNN')
%         addpath('C:/Work/research/dev/LMNN/mexfunctions')
%         addpath('C:/Work/research/dev/LMNN/helperfunctions')
%         % assign labels
%         spoke_labels = repmat(center_pixels, 1, n_angles*2)';
%         spoke_labels = floor(spoke_labels(:)*10)/10;
%         L = 1;
% %         [L,Det]=lmnn( spokes',spoke_labels','quiet',1);
%         spokes_t = (L*spokes_all')';
        
%         drawDescr(shads{1}, descrs);
        fprintf('\tsaving results...\n');
        save(['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'], ...
                'descrs', ...
                'descrs_vectors', ...
                'spokes', ...
                'spokes_mu', ...
                'spokes_std', ...
                'center_pixels', ...
                'center_pixels_int');
    end
end