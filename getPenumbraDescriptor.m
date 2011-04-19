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

        [d.points(slice, 1, :) d.points(slice, 2, :)] = processSlice(mask, pixel + pixel_offset,  pixel - pixel_offset);
        
        d.slices_mask{slice} = improfile(mask, d.points(slice, :, 1), d.points(slice, :, 2));
        d.slices_im{slice} = improfile(im, d.points(slice, :, 1), d.points(slice, :, 2));
    end
end

function [p1, p2] = processSlice(im, p1, p2)
    % check if the slice is within image
    [p1, p2] = getSliceWithinImage(im, p1, p2);
    
    % ensure that the profile is rising (reverse points if it's not)
    [p1, p2] = ensureProfileRising(im, p1, p2);
    
    % extend the slice all the way to the edges of penumbra
    [p1, p2] = extendSlice(im, p1, p2);
end

function [p1, p2] = getSliceWithinImage(im, p1, p2)
% returns endpoints of the profile, which lie within the image.
% p1 and p2 is a pair of end points  of the slice
    % TODO: using improfile here is slow (only need cx and cy), might want 
    % to improve later
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
    % TODO: primitive method of figuring out direction - use sum of 
    % gradients?
    if prof(1) > prof(size(prof,1))
        temp = p1;
        p1 = p2;
        p2 = temp;
    end
end

function [p1, p2] = extendSlice(im, p1, p2)
% extends the slice to ensure that 0-gradient is reached on both ends
    offset = (p2(:) - p1(:))*10;
    p1 = p1(:) - offset;
    p2 = p2(:) + offset;
    
    [p1 p2] = getSliceWithinImage(im, p1, p2);
    
    [cx cy c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
    g = gradient(c);
    g = conv(g, normpdf(1:size(g,1), round(size(g,1)/2), 5), 'same');
    thresh = 10^-5;
    
    % TODO: change to be robust to other peaks, max sux
    profileMid = find(g == max(g),1); % index of the profile midpoint
    
    fnz = findFirstNonZero(g(1:profileMid), thresh); % index of the first interesting element (inside penumbra)
    lnz = size(g,1) - findFirstNonZero(flipud(g(profileMid:size(g,1))), thresh); % index of the last interesting element (inside penumbra)
    
    p1 = [cx(fnz) cy(fnz)];
    p2 = [cx(lnz) cy(lnz)];
end

function fnz = findFirstNonZero(vec, thresh)
% finds first non-zero element (or larger than THRESH if defined)
    if nargin == 1
        thresh = 0;
    end
    fnz = find(vec > thresh, 1);
end