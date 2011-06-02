classdef PenumbraDescriptor
    properties
        center
        center_pixel
        slices_matte
        slices_shad
%         patch_matte
        center_inds
        points
    end
    
    methods
        function d = PenumbraDescriptor(shad, pixel, n_angles, len, penumbra_mask, matte)
        %PENUMBRADESCRIPTOR returns descriptor at PIXEL
            if nargin==0
                d.center = 0;
                d.center_pixel = 0;
                d.slices_matte = 0;
                d.slices_shad = 0;
                d.center_inds = 0;
                d.points = 0;
                return
            end

            % storage for slices and points
            d.center = pixel;
            d.points = zeros(n_angles, 2, 2);
            d.slices_shad = zeros(n_angles, len+1);
            d.center_inds = zeros(n_angles,1);
%             patch_size = 10;
            
            % dsim is the image according to which the descriptor is
            % constructed (orientation and penumbra boundaries are taken
            % from it); we want to use ground-truth matte at training
%             dsim = [];
            
            if exist('matte', 'var') && ~isempty(matte)
                d.slices_matte = zeros(n_angles, len+1);
                dsim = matte;
                d.center_pixel = matte(pixel(2), pixel(1));
%                 d.patch_matte = matte(pixel(2)-patch_size:pixel(2)+patch_size, pixel(1)-patch_size:pixel(1)+patch_size);
            else
                dsim = shad;
            end
            
            hl = len/2; % half length

%             bounds = [pixel(1)-hl; pixel(2)-hl; pixel(1)+hl; pixel(2)+hl];
%             bounds(1:2) = checkImBounds(bounds(1:2), size(dsim));
%             bounds(3:4) = checkImBounds(bounds(3:4), size(dsim));

%             patch = dsim(bounds(2):bounds(4), bounds(1):bounds(3));

            ang_step = pi/n_angles;
            slice_index = 0;

            for ang = 0:ang_step:pi-ang_step
                slice_index = slice_index+1;
                [pixel_offset(1) pixel_offset(2)] = pol2cart(ang, hl);
                
                [d.points(slice_index, 1, :) d.points(slice_index, 2, :)] = ...
                    processSlice(dsim, pixel + pixel_offset,  pixel - pixel_offset, penumbra_mask);
                if isnan(d.points(slice_index, 1, :))
                    d.points = NaN;
                    return;
                end

                [slice_pts_x slice_pts_y sl] = improfile(shad, d.points(slice_index, :, 1), d.points(slice_index, :, 2));
                d = d.setSliceShad(slice_index, sl);
                d.center_inds(slice_index) = findClosestPoint(slice_pts_x, slice_pts_y, d.center);
                
                if exist('matte', 'var')
                    d = d.setSliceMatte(slice_index, improfile(matte, d.points(slice_index, :, 1), d.points(slice_index, :, 2)));
                end
            end
        end
        
        function d = setSliceShad(d, i, slice)
            d.slices_shad(i,:) = 0;
            if length(slice) > length(d.slices_shad(i, :))+1
                error('Slice too long, cannot set.');
            end
            d.slices_shad(i, 1:length(slice)) = gradient(slice);
        end
        
        function d = setSliceMatte(d, i, slice)
            d.slices_matte(i,:) = 0;
            if length(slice) > length(d.slices_matte(i, :))+1
                error('Slice too long, cannot set.');
            end
            d.slices_matte(i, 1:length(slice)) = gradient(slice);
        end
        
        function slice = getSliceShad(d, i)
            slice = d.slices_shad(i, :);
            slice = slice(~isnan(slice));
        end
        
        function slice = getSliceMatte(d, i)
            slice = d.slices_matte(i, :);
            slice = slice(~isnan(slice));
        end
        
        function draw(d, plot_color)
            if ~exist('plot_color', 'var')
                plot_color = [1, 1, 1];
            end
            for s = 1:size(d.slices_shad,1)
                plot(d.points(s, :, 1), d.points(s, :, 2), 'color', plot_color);
            end
            plot(d.center(1), d.center(2), 'xr');
        end
    end
end

function ind = findClosestPoint(pts_x, pts_y, point)
    if length(pts_x) ~= length(pts_y)
        error('pts_x and pts_y need to have the same length');
    end
    minerr = Inf;
    ind = 0;
    for p = 1:length(pts_x)
        err = norm([pts_x(p) pts_y(p)] - point);
        if err < minerr
            ind = p;
            minerr = err;
        end
    end
end

function [p1, p2] = processSlice(im, p1, p2, penumbra_mask)
    % check if the slice is within image and penumbra boundaries
    [p1, p2] = getSliceWithinImage(im, p1, p2, penumbra_mask);
    if isnan(p1)
        return;
    end
    
    % ensure that the profile is rising (reverse points if it's not)
%     [p1, p2] = ensureProfileRising(im, p1, p2);

    if isempty(p1) || isempty(p2)
        error('p1 or p2 empty');
    end
end

function [p1, p2] = getSliceWithinImage(im, p1, p2, penumbra_mask)
% returns endpoints of the profile, which lie within the image.
% p1 and p2 is a pair of end points  of the slice
    % TODO: using improfile here is slow (only need cx and cy), might want 
    % to improve later
    op1 = p1; op2 = p2;
    
%     offset = (p2(:) - p1(:))*100;
%     p1 = p1(:) - offset;
%     p2 = p2(:) + offset;
    
    [cx, cy, c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
    
    % get valid coords (within image boundary)
    cx_valid = cx >= 1 & cx <= size(im,2);
    cy_valid = cy >= 1 & cy <= size(im,1);

    % list valid points
    vp = round([cx(cx_valid & cy_valid) cy(cx_valid & cy_valid)]);
    
%     % list of points within penumbra
%     % TODO: bug - if there are two penumbra regions, the pixels in between
%     % are included too
%     for row = 1:size(vp,1)
%         if penumbra_mask(vp(row,2), vp(row,1)) == 0
%             vp(row, :) = [0, 0];
%         end
%     end
    
    vpx = vp(:,1);
    vpy = vp(:,2);
    
    vp = [vpx(vpx > 0) vpy(vpy > 0)];
    
    if size(vp,1) == 0 || size(vp,2) == 0
        p1 = NaN;
        return;
    end
    
    p1 = double(vp(1,:));
    p2 = double(vp(size(vp,1),:));
end

function [p1 p2] = ensureProfileRising(im, p1, p2)
    prof = improfile(im, [p1(1) p2(1)] , [p1(2) p2(2)]);
    % TODO: primitive method of figuring out direction
%     if prof(1) > prof(size(prof,1))
    if sum(gradient(prof)) < 0
        temp = p1;
        p1 = p2;
        p2 = temp;
    end
end