function d = getPenumbraDescriptor(im, mask, pixel, n_angles, length)
%PENUMBRADESCRIPTOR returns descriptor at PIXEL

    hl = length/2; % half length

    bounds = [pixel(1)-hl; pixel(2)-hl; pixel(1)+hl; pixel(2)+hl];
    bounds(1:2) = checkImBounds(bounds(1:2), size(mask));
    bounds(3:4) = checkImBounds(bounds(3:4), size(mask));

    patch = mask(bounds(2):bounds(4), bounds(1):bounds(3));
    d = PenumbraDescriptor;
    d.orientation = dominantGradientDir(patch);
    
    ang_step = pi/n_angles;
    
    % storage for slices and points
    d.centre = pixel;
    d.slices_mask = cell(n_angles);
    d.slices_im = cell(n_angles);
    d.points = zeros(n_angles, 2, 2);

    slice = 0;
    
    for ang = 0:ang_step:pi-ang_step
        slice = slice+1;
        [pixel_offset(1) pixel_offset(2)] = polar2cartesian(hl, d.orientation+ang);
        
        % check if the slice is within image
        [d.points(slice, 1, :), ...
         d.points(slice, 2, :)] = getSliceWinthinImage(mask, ...
                                                       pixel + pixel_offset, ...
                                                       pixel - pixel_offset);
        
        % ensure that the profile is rising (reverse points if it's not)
        [d.points(slice, 1, :) d.points(slice, 2, :)] = ensureProfileRising(mask, d.points(slice, 1, :), d.points(slice, 2, :));
        
        % extend the slice all the way to the edges of penumbra
        [d.points(slice, 1, :) d.points(slice, 2, :)] = extendSlice(mask, d.points(slice, 1, :), d.points(slice, 2, :));
        
%         % remove parts outside of penumbra (where gradient = 0)
%         [d.points(slice, 1, :), ...
%          d.points(slice, 2, :)] = removeZeroGradient(mask, ...
%                                                      d.points(slice, 1, :), ...
%                                                      d.points(slice, 2, :));

        d.slices_mask{slice} = improfile(mask, d.points(slice, :, 1), d.points(slice, :, 2));
        d.slices_im{slice} = improfile(im, d.points(slice, :, 1), d.points(slice, :, 2));
    end
end

function [p1, p2] = extendSlice(im, p1, p2)
% extends the slice to ensure that 0-gradient is reached on both ends
    op1 = p1;
    op2 = p2;
    offset = (p2(:) - p1(:))*10;
    p1 = p1(:) - offset;
    p2 = p2(:) + offset;
    
    [p1 p2] = getSliceWinthinImage(im, p1, p2);

%     p1(:)
%     p2(:)
    
    [cx cy c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
    g = gradient(c);
    g = conv(g, normpdf(1:size(g,1), round(size(g,1)/2), 5), 'same');
    thresh = 10^-5;
    
    % TODO: change to be rebust to other peaks, max sux
    profileMid = find(g == max(g),1); % index of the profile midpoint
    
    fnz = findFirstNonZero(g(1:profileMid), thresh); % index of the first interesting element (inside penumbra)
    lnz = size(g,1) - findFirstNonZero(flipud(g(profileMid:size(g,1))), thresh); % index of the last interesting element (inside penumbra)
    tg = g(fnz:lnz);
    
    cx = cx(fnz:lnz);
    cy = cy(fnz:lnz);
    
    p1 = [cx(1) cy(1)];
    p2 = [cx(size(cx,1)) cy(size(cy,1))];
%     global pixel;
%     imshow(im);hold on
%     plot(pixel(1), pixel(2), 'or', 'MarkerSize', 5)
%     plot(op1(1), op1(2), '*r', 'MarkerSize', 5);
%     plot(p1(1), p1(2), '*m', 'MarkerSize', 5);
%     plot(op2(1), op2(2), '*g', 'MarkerSize', 5);
%     plot(p2(1), p2(2), '*c', 'MarkerSize', 5);
%     hold off;

% ============================== V1 =======================================
%     c = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
%     g = gradient(c);
%     % convolve with a Gaussian kernel with sigma 5
%     g = conv(g, normpdf(1:size(g,1), round(size(g,1)/2), 5), 'same');
%     thresh = 10^-5; % a small number defining penumbra cut-off
%     offset = (p2(:) - p1(:))*0.01;
%     while g(1) > thresh && ~isOut(p1, im)
%         np1 = p1(:) - offset;
%         if isOut(np1, im)
%             break
%         end
%         p1(1) = np1(1); p1(2) = np1(2);
%         c = improfile(im, [round(p1(1)) p2(1)], [round(p1(2)) p2(2)]);
%         g = gradient(c);
%         g = conv(g, normpdf(1:size(g,1), round(size(g,1)/2), 5), 'same');
%     end
%     p1 = round(p1);
end

% function [p1,p2] = removeZeroGradient(im, p1, p2)
% % returns endpoints of the profile, which doesn't include 0-gradient
%     [cx, cy, c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
%     g = gradient(c);
%     % convolve with a Gaussian kernel with sigma 5
%     g = conv(g, normpdf(1:size(g,1), round(size(g,1)/2), 5), 'same');
%     thresh = 10^-5; % a small number defining penumbra cut-off
%     fnz = find(g > thresh, 1);   % first non-zero gradient
%     lnz = size(g,1) - find(flipud(g) > thresh, 1); % last non-zero gradient
%     cx = cx(fnz:lnz);
%     cy = cy(fnz:lnz);
%     p1 = [cx(1) cy(2)];
%     p2 = [cx(size(cx,1)) cy(size(cy,1))];
% end

function [p1, p2] = getSliceWinthinImage(im, p1, p2)
% returns endpoints of the profile, which lie within the image.
% p1 and p2 is a pair of end points  of the slice
    % TODO:using improfile here is slow, might want to improve later
    [cx, cy, c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
    
    % get valid coords
    cx_valid = cx >= 1 & cx < size(im,2);
    cy_valid = cy >= 1 & cy < size(im,1);
    
    % list of valid points
    vp = [cx(cx_valid & cy_valid) cy(cx_valid & cy_valid)];
    p1 = vp(1,:);
    p2 = vp(size(vp,1),:);
end

function [p1 p2] = ensureProfileRising(im, p1, p2)
   prof = improfile(im, [p1(1) p2(1)] , [p1(2) p2(2)]);
    if prof(1) > prof(size(prof,1))
        prof = flipud(prof);
        temp = p1;
        p1 = p2;
        p2 = temp;
    end
end

% function out = isOut(p, im)
%     if p(1) < 1 || p(1) > size(im,2) || ...
%        p(2) < 1 || p(2) > size(im,1)
%         out = true;
%     else
%         out = false;
%     end
% end

function fnz = findFirstNonZero(vec, thresh)
% finds first non-zero element (or larger than THRESH if defined)
    if nargin == 1
        thresh = 0;
    end
    fnz = find(vec > thresh, 1);
end