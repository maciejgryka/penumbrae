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
        
%         d.points(slice, 1, :) = checkImBounds(pixel + pixel_offset, size(mask));
%         d.points(slice, 2, :) = checkImBounds(pixel - pixel_offset, size(mask));

        [d.points(slice, 1, :), ...
         d.points(slice, 2, :)] = getValidSlice(mask, ...
                                                    pixel + pixel_offset, ...
                                                    pixel - pixel_offset);
                                                                           
        [d.slices_mask{slice} d.points(slice, 1, :) d.points(slice, 2, :)] = ensureProfileRising(mask, d.points(slice, 1, :), d.points(slice, 2, :));
        [d.slices_im{slice} d.points(slice, 1, :) d.points(slice, 2, :)] = ensureProfileRising(im, d.points(slice, 1, :), d.points(slice, 2, :));
    end
end

function [p1, p2] = getValidSlice(im, p1, p2)
% returns endpoints of the profile, which lie within the image.
% p1 and p2 is a pair of end points  of the slice
    % TODO:using improfile here is slow, might want to improve later
    [cx, cy, c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
    
    % get valid coords
    cx_valid = cx > 0 & cx < size(im,2)+1;
    cy_valid = cy > 0 & cy < size(im,1)+1;
    
    % list of valid points
    vp = [cx(cx_valid & cy_valid) cy(cx_valid & cy_valid)];
    p1 = vp(1,:);
    p2 = vp(size(vp,1),:);
end