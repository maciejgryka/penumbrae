function slicePoints = saveSlices(varargin)
%SLICEPOINTS saves the slice points through penumbra based on user input
%   SLICEPOINTS(N, SLEN, IMPATH) creates N slices of lenth SLEN based on
%   image at IMPATH
%
    switch nargin
        case 3   % saveSlices(n, sLen, path)
            n = varargin{1};
            sLen = varargin{2};
            impath = varargin{3};
        otherwise
            error('Wrong number of arguments.');
    end

    if ~strcmp(impath, '')
        im = imread(impath);
        imshow(im);
        impath = [impath '_'];
    end
    
    if strcmp(class(im), 'uint8')
        im = double(im)./255;
    end

    title(['Draw along shadow boundary for ' impath]);
    xlabel('Press Enter when finished');
    [x, y] = ginput;
    nPoints = size(x,1);

    nn = n-1;   % adjust n (this makes it possible to specify number of 
                % slices above, rather than number of intervals)

    % create an interpolating spline between specified points
    t = 1:nPoints;
    ts = 1:nPoints/nn:nPoints;
    xs = spline(t, x, ts);
    ys = spline(t, y, ts);

    slicePoints = zeros(length(xs)*2, 2);
    
    for l = 1:length(xs)-1
        p1 = [xs(l)   ys(l)];
        p2 = [xs(l+1) ys(l+1)];
        [perpOff(1) perpOff(2)] = getPerpOffset(p1, p2);
        perpOff = perpOff / norm(perpOff);

        % endpoints of a perpendicular segment
        pPlus  = p1 + perpOff*sLen;
        pMinus = p1 - perpOff*sLen;
        
        pPlus = checkImBounds(pPlus, size(im));
        pMinus = checkImBounds(pMinus, size(im));
        
%         prof = improfile(im, [pPlus(1) pMinus(1)], [pPlus(2) pMinus(2)]);
        [prof pPlus pMinus] = ensureProfileRising(im, pPlus, pMinus);
%         [prof pPlus pMinus] = getProfileFromPeak(im, pPlus, pMinus, 200);

        slicePoints((l-1)*2+1, :) = pPlus;
        slicePoints((l-1)*2+2, :) = pMinus;
    end
    
	sp1 = slicePoints(:,1);
    sp2 = slicePoints(:,2);
    
    sp1 = sp1(sp1 ~= 0);
    sp2 = sp2(sp2 ~= 0);
    
    slicePoints = [sp1 sp2];
    
    % save user-drawn segments and slice endpoints
    save([impath 'profile.mat'], 'x', 'y', 'slicePoints');
end