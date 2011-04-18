function varargout = getMeanProfile(mask, slicePoints)
%     len = 100;
    nLines = size(slicePoints, 1)/2;
    len = length(improfile(mask, slicePoints(1:2, 1), slicePoints(1:2, 2)));
    profs = zeros(nLines, len);
    for l = 1:nLines-2
        profs(l,:) = improfile(mask, slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), len);
    end
    meanProf = mean(profs);
    varargout(1) = {meanProf};
    if nargout == 2
        varargout(2) = {std(profs)};
    elseif nargout == 3
        varargout(2) = {std(profs)};
        varargout(3) = {profs};
    end
end