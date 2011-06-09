function penumbra_mask = getPenumbraMaskAtScale(penumbra_mask, len)
% returns (eroded) penumbra mask suitable for computing descriptors at 
% scale LEN
    if mod(len,2) == 0
        len = len+1;
    end
    penumbra_mask = imerode(penumbra_mask, strel('square', len));
end