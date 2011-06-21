function pixel = getPenumbraPixels(penumbra_mask)
    p_pix = find(penumbra_mask' == 1);
    if (isempty(p_pix))
        pixel = NaN;
        return;
    end
    pixel = zeros(length(p_pix), 2);
    [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask'), p_pix);
end