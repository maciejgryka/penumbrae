classdef PenumbraDescriptor
    properties
        center
        center_pixel
%         slices_matte
%         slices_matte_cat
        slices_shad
        slices_shad_cat
        points
    end
    
    methods
        function d = PenumbraDescriptor(shad, pixel, n_angles, len, matte)
        %PENUMBRADESCRIPTOR returns descriptor at PIXEL
            if nargin==0
                d.center = 0;
                d.center_pixel = 0;
%                 d.slices_matte = 0;
                d.slices_shad = 0;
                d.points = 0;
                return
            end

            % storage for slices and points
            d.center = pixel;
            d.points = zeros(n_angles, 2, 2);
            d.slices_shad = zeros(n_angles, len+1);

            if exist('matte', 'var') && ~isempty(matte)
%                 d.slices_matte = zeros(n_angles, len+1);
                dsim = matte;
                d.center_pixel = matte(pixel(2), pixel(1));
            else
                dsim = shad;
            end
            
            hl = len/2; % half length

            ang_step = pi/n_angles;
            slice_index = 0;

            for ang = 0:ang_step:pi-ang_step
                slice_index = slice_index+1;
                [pixel_offset(1) pixel_offset(2)] = pol2cart(ang, hl);
                
                [d.points(slice_index, 1, :) d.points(slice_index, 2, :)] = ...
                    processSlice(dsim, pixel - pixel_offset,  pixel + pixel_offset);
                if isnan(d.points(slice_index, 1, :))
                    d.points = NaN;
                    return;
                end

                sl = improfile(shad, d.points(slice_index, :, 1), d.points(slice_index, :, 2));
                d = d.setSliceShad(slice_index, sl);
                
%                 if exist('matte', 'var')
%                     d = d.setSliceMatte(slice_index, improfile(matte, d.points(slice_index, :, 1), d.points(slice_index, :, 2)));
%                 end
            end
            % concatenate the slices into one vector for easy knn lookup
            d.slices_shad_cat = reshape(d.slices_shad', n_angles*(len+1), 1)';
%             if exist('matte', 'var')
%                 d.slices_matte_cat = reshape(d.slices_matte', n_angles*(len+1), 1)';
%             end
        end
        
        function d = setSliceShad(d, i, slice)
            d.slices_shad(i,:) = 0;
            if length(slice) > length(d.slices_shad(i, :))+1
                error('Slice too long, cannot set.');
            end
            d.slices_shad(i, 1:length(slice)) = gradient(slice);
        end
        
%         function d = setSliceMatte(d, i, slice)
%             d.slices_matte(i,:) = 0;
%             if length(slice) > length(d.slices_matte(i, :))+1
%                 error('Slice too long, cannot set.');
%             end
%             d.slices_matte(i, 1:length(slice)) = gradient(slice);
%         end
        
        function slice = getSliceShad(d, i)
            slice = d.slices_shad(i, :);
            slice = slice(~isnan(slice));
        end
        
%         function slice = getSliceMatte(d, i)
%             slice = d.slices_matte(i, :);
%             slice = slice(~isnan(slice));
%         end
        
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

function [p1, p2] = processSlice(im, p1, p2)
    % check if the slice is within image and penumbra boundaries
    [p1, p2] = getSliceWithinImage(im, p1, p2);
    if isnan(p1)
        return;
    end

    if isempty(p1) || isempty(p2)
        error('p1 or p2 empty');
    end
end

function [p1, p2] = getSliceWithinImage(im, p1, p2)
% returns endpoints of the profile, which lie within the image.
% p1 and p2 is a pair of end points  of the slice
    % TODO: using improfile here is slow (only need cx and cy), might want 
    % to improve later
    
    [cx, cy, c] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
    
    % get coords within image boundary
    cx_valid = cx >= 1 & cx <= size(im,2);
    cy_valid = cy >= 1 & cy <= size(im,1);

    % list of valid points
    vp = round([cx(cx_valid & cy_valid) cy(cx_valid & cy_valid)]);
    
    if size(vp,1) == 0 || size(vp,2) == 0
        p1 = NaN;
        return;
    end
    
    p1 = double(vp(1,:));
    p2 = double(vp(size(vp,1),:));
end