classdef PenumbraDescriptor
    properties
        center
        orientation
        slices_matte
        slices_shad
        points
    end
    
    methods
        function d = PenumbraDescriptor(shad, pixel, n_angles, length, penumbra_mask, matte)
        %PENUMBRADESCRIPTOR returns descriptor at PIXEL

            % storage for slices and points
            d.center = pixel;
            d.points = zeros(n_angles, 2, 2);
            d.slices_shad = cell(n_angles);
            
            % dsim is the image according to which the descriptor is
            % constructed (orientation and penumbra boundaries are taken
            % from it); we want to use ground-truth matte at training
            dsim = [];
            
            if exist('matte', 'var') && ~isempty(matte)
                d.slices_matte = cell(n_angles);
                dsim = matte;
            else
                dsim = shad;
            end
            
            hl = length/2; % half length

            bounds = [pixel(1)-hl; pixel(2)-hl; pixel(1)+hl; pixel(2)+hl];
            bounds(1:2) = checkImBounds(bounds(1:2), size(dsim));
            bounds(3:4) = checkImBounds(bounds(3:4), size(dsim));

            patch = dsim(bounds(2):bounds(4), bounds(1):bounds(3));
            d.orientation = dominantGradientDir(patch);

            ang_step = pi/n_angles;
            slice = 0;

            for ang = 0:ang_step:pi-ang_step
                slice = slice+1;
                [pixel_offset(1) pixel_offset(2)] = polar2cartesian(hl, d.orientation+ang);

                [d.points(slice, 1, :) d.points(slice, 2, :)] = ...
                    processSlice(dsim, pixel + pixel_offset,  pixel - pixel_offset, penumbra_mask);

                d.slices_shad{slice} = improfile(shad, d.points(slice, :, 1), d.points(slice, :, 2));
                if exist('matte', 'var')
                    d.slices_matte{slice} = improfile(matte, d.points(slice, :, 1), d.points(slice, :, 2));
                end
            end
        end
    end
end

function [p1, p2] = processSlice(im, p1, p2, penumbra_mask)
    % check if the slice is within image and penumbra boundaries
    [p1, p2] = getSliceWithinImage(im, p1, p2, penumbra_mask);

    % ensure that the profile is rising (reverse points if it's not)
    [p1, p2] = ensureProfileRising(im, p1, p2);

    if isempty(p1) || isempty(p2)
        error('p1 or p2 empty');
    end
end

function [p1, p2] = getSliceWithinImage(im, p1, p2, penumbra_mask)
% returns endpoints of the profile, which lie within the image.
% p1 and p2 is a pair of end points  of the slice
    % TODO: using improfile here is slow (only need cx and cy), might want 
    % to improve later
    offset = (p2(:) - p1(:))*100;
    p1 = p1(:) - offset;
    p2 = p2(:) + offset;
    
    [cx, cy, c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
    
    % get valid coords
    cx_valid = cx >= 1 & cx < size(im,2);
    cy_valid = cy >= 1 & cy < size(im,1);

    % list valid points (within image boundary)
    vp = [cx(cx_valid & cy_valid) cy(cx_valid & cy_valid)];
    
    % list of points within penumbra
    % TODO: bug - if there are two penumbra regions, the pixels in between
    % are included too
    vp = vp(penumbra_mask(uint32(sub2ind(size(penumbra_mask), vp(:,2), vp(:,1)))),:);
    
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