function a = improfileWrite(varargin)
%IMPROFILEWRITE Modifies image I by replacing specified line with given
%data.
%
%   Adapted from IMPROFILE, which is a part of MATLABs Image 
%   Processing Toolbox.
%

    [xa,ya,a,newProf,n,prof,getn] = parse_inputs(varargin{:});

    % Parametric distance along segments
    s = [0; cumsum(sqrt( sum((diff(prof,1,1).^2),2) ))];

    % Remove duplicate points if necessary.
    killIdx = find(diff(s) == 0);
    if (~isempty(killIdx))
        s(killIdx+1) = [];
        prof(killIdx+1,:) = [];
    end

    ma = size(a,1);
    na = size(a,2);
    xmin = min(xa(:)); ymin = min(ya(:));
    xmax = max(xa(:)); ymax = max(ya(:));

    % Handle case where user specified a degenerate 1 point profile, e.g. 
    % improfile(im,2.3,5.3,...)
    single_point_profile = size(prof,1) == 1;
    if single_point_profile
        xg = prof(1);
        yg = prof(2);
        if ~getn 
            % Honor the specified number of profile points by duplicating the
            % specified xi,yi. The output will consist of N identical values
            % interpolated within the source image at xi,yi.
            xg = repmat(xg,1,n);
            yg = repmat(xg,1,n);
        end
    elseif isempty(prof)
        xg = []; 
        yg = [];
    else
        % Interpolation points along segments
        profi = interp1(s,prof,0:(max(s)/(n-1)):max(s));
        xg = profi(:,1);
        yg = profi(:,2);
    end

    if ~isempty(a) && ~isempty(xg)
        % Get profile points in pixel coordinates
        xg_pix = round(axes2pix(na, [xmin xmax], xg)); 
        yg_pix = round(axes2pix(ma, [ymin ymax], yg));  
    end

    newProfi = imresize(newProf, [n 1], 'nearest');
    newProfi = newProfi(:, 1);
    for p = 1:size(xg_pix,1)
        a(yg_pix(p), xg_pix(p), :) = newProfi(p);
    end
end

function [Xa,Ya,Img,NewProf,N,Prof,GetN,GetProf]=parse_inputs(varargin)
% Outputs:
%     Xa        2 element vector for non-standard axes limits
%     Ya        2 element vector for non-standard axes limits
%     A         Image Data
%     N         number of image values along the path (Xi,Yi) to return
%     Method    Interpolation method: 'nearest','bilinear', or 'bicubic'
%     Prof      Profile Indices
%     GetN      Determine number of points from profile if true.
%     GetProf   Get profile from user via mouse if true also get data from image.

    % Set defaults
    N = [];
    GetN = 1;    
    GetProf = 0; 
    GetCoords = 1;  %     GetCoords - Determine axis coordinates if true.
    NewProf = [];

    switch nargin
    case 4,   % improfile(a,xi,yi, newProf)
        A = varargin{1};
        Xi = varargin{2}; 
        Yi = varargin{3};
        NewProf = varargin{4};
        N = ceil(norm([Xi(1) Yi(1)] - [Xi(2) Yi(2)])) * 2;

    case 5,   % improfile(a,xi,yi,newProf,n)
        A = varargin{1};
        Xi = varargin{2}; 
        Yi = varargin{3};
        NewProf = varargin{4};
        N = varargin{5};

    otherwise
        msgId = 'Images:improfile:invalidInputArrangementOrNumber';
        msg = 'The arrangement or number of input arguments is invalid.';
        error(msgId, '%s', msg);
    end

    % set Xa and Ya if unspecified
    if (GetCoords && ~GetProf),
        Xa = [1 size(A,2)];
        Ya = [1 size(A,1)];
    end

    % error checking for N
    if (GetN == 0)
        if (N<2 || ~isa(N, 'double'))
            msgId = 'Images:improfile:invalidNumberOfPoints';
            msg = 'N must be a number greater than 1.';
            error(msgId,'%s', msg);
        end
    end

    % Get profile from user if necessary using data from image
    if GetProf, 
        [Xa,Ya,A,state] = getimage;
        if ~state
            msgId = 'Images:improfile:noImageinAxis';
            msg = 'Requires an image in the current axis.';
            error(msgId,'%s',msg);
        end
        Prof = getline(gcf); % Get profile from user
    else  % We already have A, Xi, and Yi
        if numel(Xi) ~= numel(Yi)
            msgId = 'Images:improfile:invalidNumberOfPoints';
            msg = 'Xi and Yi must have the same number of points.';
            error(msgId, '%s',msg);
        end
        Prof = [Xi(:) Yi(:)]; % [xi yi]
    end

    % error checking for A
    if (~isa(A,'double') && ~isa(A,'uint8') && ~isa(A, 'uint16') && ~islogical(A)) ...
          && ~isa(A,'single') && ~isa(A,'int16')
        msgId = 'Images:improfile:invalidImage';
        msg = 'I must be double, uint8, uint16, int16, single, or logical.';
        error(msgId, '%s', msg);
    end

%     % Promote the image to single if it is not logical or if we aren't using nearest.
%     if islogical(A) || (~isa(A,'double') && ~strcmp(Method,'nearest')) 
%         Img = single(A);
%     else
        Img = A;
%     end

    % error checking for Xa and  Ya
    if (~isa(Xa,'double') || ~isa(Ya, 'double'))
        msgId = 'Images:improfile:invalidClassForInput';
        msg = 'All inputs other than I must be of class double.';
        error(msgId,'%s',msg);
    end   

    % error checking for Xi and Yi
    if (~GetProf && (~isa(Xi,'double') || ~isa(Yi, 'double')))
        msgId = 'Images:improfile:invalidClassForInput';
        msg = 'All inputs other than I must be of class double.';
        error(msgId,'%s',msg);
    end
end