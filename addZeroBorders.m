function imp = addZeroBorders(im, width)
% add zero-borders around the image with the specified witdth
    hw = ceil(width/2);
        imp = zeros(size(im)+2*hw);
    imp(hw+1:size(imp,1)-hw, hw+1:size(imp,2)-hw) = im;
end