function saveDescriptors()
    [shads noshads mattes masks masks_s pixels_s n_angles scales] = prepareEnv('python/output', 'png');
    
    n_ims = length(shads);

    for sc = 1:length(scales)
        fprintf('Computing descriptors at scale %i...\n', scales(sc));
        len = scales(sc);

        % overall number of descriptors to find equals the sum of pixels
        descrs = repmat(PenumbraDescriptor(), size(cat(1, pixels_s{:,sc}), 1), 1);

        curr_descr = 1;
        for i = 1:n_ims
            if isnan(pixels_s{i, sc})
                continue;
            end
            fprintf('\timage %i...\n', i);
            for p = 1:size(pixels_s{i, sc},1)
                descrs(curr_descr) = PenumbraDescriptor(shads{sc}, pixels_s{i, sc}(p,:), n_angles, len, mattes{sc});
                curr_descr = curr_descr+1;
            end
        end
    
        fprintf('\tconcatenating slices...\n');
        spokes = (cat(1,descrs(:).spokes));
        center_pixels = cat(1,descrs(:).center_pixel);
        center_pixels_int = cat(1,descrs(:).center_pixel_int);
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(spokes,1);
        spokes_mu = mean(spokes);
        spokes_std = std(spokes);
        
        spokes = (spokes - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
        % Do distance learning, transform the space
        addpath('C:/Work/research/dev/LMNN')
        addpath('C:/Work/research/dev/LMNN\mexfunctions')
        addpath('C:/Work/research/dev/LMNN\helperfunctions')
        
        % assign labels
        spoke_labels = repmat(center_pixels, 1, n_angles*2)';
        spoke_labels = floor(spoke_labels(:)*10)/10;
        
%         [L,Det]=lmnn(spokes',spoke_labels','quiet',1);
        L = 1;
        
        spokes_t = (L*spokes')';
%         drawDescr(shad, descrs);
        fprintf('\tsaving results...\n');
        save(['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'], ...
                'descrs', ...
                'spokes', ...
                'spokes_t', ...
                'L', ...
                'spokes_mu', ...
                'spokes_std', ...
                'center_pixels', ...
                'center_pixels_int');
    end
end