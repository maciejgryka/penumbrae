function penumbra_mask = getPenumbraMaskAtScale(penumbra_mask, len)
% returns penumbra mask and indices of penumbra pixels suitable for
% computing descriptors at scale LEN

    % erode penumbra
    penumbra_mask = imerode(penumbra_mask, strel('disk', len+2));
end