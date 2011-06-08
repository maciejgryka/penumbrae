function imp = addBorders(im, width, padding_val)
% add borders around the image with the specified witdth
% optional argument padding_val specifies what to pad with
    if nargin == 2
        padding_val = 0;
    end
    hw = ceil(width/2);
    imp = ones(size(im)+2*hw) * padding_val;
    imp(hw+1:size(imp,1)-hw, hw+1:size(imp,2)-hw) = im;
end