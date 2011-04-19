function drawDescriptors()
    close
    im = imread('C:\Work\research\shadow_removal\penumbrae\images\2011-04-18\2011-04-14_rough1_shadow.tif');
    noshad = imread('C:\Work\research\shadow_removal\penumbrae\images\2011-04-18\2011-04-14_rough1_noshad.tif');
    
    % work on one channel (arbitrarily chose red)
    % TODO: make sure that all the channels work
    im = im(:,:,1);
    noshad = noshad(:,:,1);
    
    hsize = [50, 50];
    im = imfilter(im, fspecial('gaussian', hsize, 20), 'replicate');
    noshad = imfilter(noshad, fspecial('gaussian', hsize, 20), 'replicate');
    
    mask = im ./ noshad;
    
    n_angles = 10;
    length = 100;
    
    n_descrs = 1;
    descrs = cell(n_descrs);
    
    [dx dy] = gradient(mask);
    mask_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = mask_abs_grad > 0;
    
    global pixel;
    
    for n = 1:n_descrs
        pixel = getRandomImagePoint(mask);
        while penumbra_mask(pixel(2), pixel(1)) == 0
            pixel = getRandomImagePoint(mask);
        end

        descrs{n} = getPenumbraDescriptor(im, mask, pixel, n_angles, length);

        cols = rand(n_angles, 3);
        cols(1,:) = [1 0 0];
        slice = size(descrs{n}.slices_mask, 1);
    end
    
%     close
%     subplot(2,2,1);
%     imshow(mask); hold on;
%     for n = 1:n_descrs
%         for s = 1:slice
%             plot(descrs{n}.points(s, :, 1), descrs{n}.points(s, :, 2), 'color', cols(s, :));
%         end
%     end
%     hold off;
%     
%     subplot(2,2,3);
%     imshow(im); hold on;
%     for n = 1:n_descrs
%         for s = 1:slice
%             plot(descrs{n}.points(s, :, 1), descrs{n}.points(s, :, 2), 'color', cols(s, :));
%         end
%     end
%     hold off;
%     
%     subplot(2,2,[2,4]);
%     hold on;
%     for n = 1:n_descrs
%         plot(gradient(descrs{n}.slices_mask{1}), 'color', cols(n, :));
%         plot(gradient(descrs{n}.slices_im{1}), 'g');%'color', cols(n, :));
%     end
%     hold off; 

    close all
    fullscreen = get(0,'ScreenSize');
    figure('Position',[10 40 fullscreen(3)-20 fullscreen(4)-125])
    subplot(1,2,1);
    imshow(mask);
    hold on;
    plot(pixel(1), pixel(2), 'or', 'MarkerSize', 5);
    for s = 1:slice
        plot(descrs{n}.points(s, :, 1), descrs{n}.points(s, :, 2), 'color', cols(s, :));
    end
    hold off;

    subplot(1,2,2);
    hold on;
    for s = 1:slice
%         plot(descrs{n}.slices_mask{s}, 'color', cols(s, :));
        g = gradient(descrs{n}.slices_mask{s});
        plot(conv(g, normpdf(1:size(g,1), round(size(g,1)/2), 5), 'same'), 'color', cols(s, :));
    end
    hold off; 
end