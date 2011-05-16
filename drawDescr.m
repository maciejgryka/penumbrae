function drawDescr(im, descrs, plotstyle)
    imshow(im);
    hold on;
    if ~exist('plotstyle', 'var')
        plotstyle = '';
    end
%     if iscell(descrs)
        for d = 1:length(descrs)
            plot(descrs(d).center(1), descrs(d).center(2), 'or', 'MarkerSize', 5);
            for s = 1:length(descrs(d).slices_shad)
                plot(descrs(d).points(s, :, 1), descrs(d).points(s, :, 2), plotstyle);
            end
        end
%     elseif strcmp(class(descrs), 'PenumbraDescriptor')
%         plot(descrs.center(1), descrs.center(2), 'or', 'MarkerSize', 5);
%         for s = 1:length(descrs.slices_shad)
%             plot(descrs.points(s, :, 1), descrs.points(s, :, 2), plotstyle);
%         end
%     end
    hold off;
end