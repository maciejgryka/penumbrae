classdef PenumbraDescriptor
    properties
        center
        center_pixel
        center_pixel_dx
        center_pixel_dy
        spokes
        points
    end
    
    methods
        function d = PenumbraDescriptor(shad, pixel, n_angles, len, matte)
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
                center_pixel_dx = dx(pixel(2), pixel(1));
                center_pixel_dy = dy(pixel(2), pixel(1));
            else
                d.center_pixel = NaN;
            end
            
            hl = floor(len/2); % half length
            
            % each spoke has two endpoints: d.center and one of d.points
            % there are two spokes at each angle
            d.points = zeros(2*n_angles, 2);
            d.spokes = zeros(n_angles*2, hl+1);
            

            ang_step = pi/n_angles;
            spoke_index = 1;
            for ang = 0:ang_step:pi-ang_step
                [pixel_offset(1) pixel_offset(2)] = pol2cart(ang, hl);
                
                d.points(spoke_index, :) = d.center - pixel_offset;
                d.points(spoke_index+1, :) = d.center + pixel_offset;

                d = d.fillSpoke(shad, spoke_index);
                d = d.fillSpoke(shad, spoke_index+1);

                spoke_index = spoke_index + 2;
            end
        end
        
        function d = fillSpoke(d, im, sp)
            d.spokes(sp,:) = gradient(improfile(im, [d.center(1) d.points(sp, 1)], [d.center(2) d.points(sp, 2)], length(d.spokes(sp,:))));
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
                plot([d.center(1) d.points(s, 1)], [d.center(2) d.points(s, 2)], 'color', plot_color);
            end
            plot(d.center(1), d.center(2), 'xr');
        end
    end
end