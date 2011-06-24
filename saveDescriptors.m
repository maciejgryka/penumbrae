function saveDescriptors(shad, noshad)
    date = '2011-06-13';
    suffix = 'plain';
    [shad noshad matte penumbra_mask n_angles scales] = prepareEnv(date, suffix);
    
    rough = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' date '\' date '_rough4_shad.tif']);
    rough = rough(150:249, 370:469);
    
    rough1 = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' date '\' date '_rough1_shad.tif']);
    rough1 = rough1(150:249, 370:469);
    
    wood2 = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' date '\' date '_wood2_shad.tif']);
    wood2 = wood2(150:249, 370:469);
    
    n_ims = 1;
    
    % cell containing in each row an image from which to caluclate 
    % descriptors as well as list of pixel coords at which the descriptors
    % should be centered
    shadmatte = cell(n_ims, 1);
    
    for sc = 1:length(scales)
        fprintf('Computing descriptors at scale %i...\n', scales(sc));
        len = scales(sc);

        % get pixels where descriptors at given sale can be calculated
        penumbra_mask_s = getPenumbraMaskAtScale(penumbra_mask, scales(sc));
        pixel = getPenumbraPixels(penumbra_mask_s);
        if isnan(pixel)
            fprintf('\tno descriptors and this scale\n');
            continue;
        end
            
        shadmatte{1,1} = shad;
%         shadmatte{2,1} = rough;
%         shadmatte{3,1} = rough1;
%         shadmatte{4,1} = wood2;
        shadmatte{1,2} = pixel;
%         shadmatte{2,2} = pixel;
%         shadmatte{3,2} = pixel;
%         shadmatte{4,2} = pixel;
        
        % overall number of descriptors to find equals the sum of pixels
        descrs = repmat(PenumbraDescriptor(), size(cat(1, shadmatte{:,2}), 1), 1);

        curr_descr = 1;
        for i = 1:n_ims
            fprintf('\timage %i...\n', i);
            for p = 1:size(pixel,1)
                descrs(curr_descr) = PenumbraDescriptor(shadmatte{i,1}, shadmatte{i,2}(p,:), n_angles, len, matte);

                curr_descr = curr_descr+1;
            end
        end
    
        fprintf('\tconcatenating slices...\n');
        % concatenate slices_shad and slices_matte arrays and put the in one 
        % big matrix
        spokes = (cat(1,descrs(:).spokes));
        center_pixels = cat(1,descrs(:).center_pixel);
        center_pixels_int = cat(1,descrs(:).center_pixel_int);
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(spokes,1);
        spokes_mu = mean(spokes);
        spokes_std = std(spokes);
        
        spokes = (spokes - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
        % Do distance learning, transform the space
        addpath('C:\Work\research\dev\LMNN')
        addpath('C:\Work\research\dev\LMNN\mexfunctions')
        addpath('C:\Work\research\dev\LMNN\helperfunctions')
        
        % assign labels
        labels = 0:0.1:1;
        
        spoke_labels = repmat(center_pixels, 1, n_angles*2)';
        spoke_labels = floor(spoke_labels(:)*10)/10;
        
        [L,Det]=lmnn(spokes',spoke_labels','quiet',1);
        
        spokes_t = (L*spokes')';
%         drawDescr(shad, descrs);
        fprintf('\tsaving results...\n');
        save(['descrs\descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'], 'descrs', 'spokes', 'spokes_t', 'L', 'spokes_mu', 'spokes_std', 'center_pixels', 'center_pixels_int');
    end
end