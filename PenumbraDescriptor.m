classdef PenumbraDescriptor
    properties
        center
        center_pixel
        center_pixel_int
        center_pixel_dx
        center_pixel_dy
        spokes
        points
    end
    
    methods
        function d = PenumbraDescriptor(shad, pixel, n_angles, len, prev_scales_sum, matte)
        %PENUMBRADESCRIPTOR returns descriptor at PIXEL
            if nargin==0
                d.center = 0;
                d.center_pixel = 0;
                d.spokes = 0;
                d.points = 0;
                return
            end

            d.center = pixel;
            if exist('matte', 'var') && ~isempty(matte)
                d.center_pixel = matte(pixel(2), pixel(1));
                [dx dy] = gradient(matte);
                d.center_pixel_dx = dx(pixel(2), pixel(1));
                d.center_pixel_dy = dy(pixel(2), pixel(1));
            else
                d.center_pixel = NaN;
                d.center_pixel_dx = NaN;
                d.center_pixel_dy = NaN;
            end
            d.center_pixel_int = shad(pixel(2), pixel(1));
            
            [dx dy] = gradient(shad);
            % normalized gradient-direction image
            shad_grad_orient = (atan(dy./dx) + pi)./(2*pi);
            shad_grad_orient(isnan(shad_grad_orient)) = 0;
            
%             shad_grad_mag = sqrt(dx.^2 + dy.^2);
            
            % each spoke has two endpoints and there are two spokes per angle
            % each row in d.points is [x1 y1 x2 y2] and represents endpoints for
            % the corresponding spoke
            d.points = zeros(n_angles*2, 4);
            % each spoke vector consists of intensity + gradient orientation +
            % magnitude
            d.spokes = zeros(n_angles*2, 2*len);

            ang_step = pi/n_angles;
            spoke_index = 1;
            for ang = 0:ang_step:pi-ang_step
                [spoke_offset(1) spoke_offset(2)] = pol2cart(ang, len-1);
                [prev_scales_offset(1) prev_scales_offset(2)] = pol2cart(ang, prev_scales_sum);
                
                d.points(spoke_index, 1:2) = d.center - prev_scales_offset;
                d.points(spoke_index, 3:4) = d.center - prev_scales_offset - spoke_offset;
                
                d.points(spoke_index+1, 1:2) = d.center + prev_scales_offset;
                d.points(spoke_index+1, 3:4) = d.center + prev_scales_offset + spoke_offset;

                d = d.fillSpoke(shad, shad_grad_orient, spoke_index);
                d = d.fillSpoke(shad, shad_grad_orient, spoke_index+1);

                spoke_index = spoke_index + 2;
            end
        end
        
        function d = fillSpoke(d, im, im_grad_o, sp)
            sl = improfile(im, [d.points(sp, 1) d.points(sp, 3)], [d.points(sp, 2) d.points(sp, 4)], length(d.spokes(sp,:))/2);
            sl_grad_o = improfile(im_grad_o, [d.points(sp, 1) d.points(sp, 3)], [d.points(sp, 2) d.points(sp, 4)], length(d.spokes(sp,:))/2);
%             sl_grad_m = improfile(im_grad_m, [d.points(sp, 1) d.points(sp, 3)], [d.points(sp, 2) d.points(sp, 4)], length(d.spokes(sp,:))/3);
            d.spokes(sp,:) = [sl_grad_o' sl'];
        end
        
        function d = setSliceShad(d, i, slice)
            d.slices_shad(i,:) = 0;
            if length(slice) > length(d.slices_shad(i, :))+1
                error('Slice too long, cannot set.');
            end
            d.spokes(i, 1:length(slice)) = gradient(slice);
        end
        
        function slice = getSliceShad(d, i)
            slice = d.slices_shad(i, :);
            slice = slice(~isnan(slice));
        end
        
        function draw(d, plot_color)
            if ~exist('plot_color', 'var')
                plot_color = [1, 1, 1];
            end
            for s = 1:size(d.spokes,1)
                plot([d.points(s, 1) d.points(s, 3)], [d.points(s, 2) d.points(s, 4)], 'color', plot_color);
            end
            plot(d.center(1), d.center(2), 'xr');
        end
        
        function rotated = getRotated(d, step)
            if step >= size(d.spokes, 1)
                error('Step too large - not enough spokes in this descriptor.')
            end
            rotated = d;
%             rotated.spokes = [d
        end
    end
end