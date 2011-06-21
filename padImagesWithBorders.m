function varargout = padImagesWithBorders(varargin)
    if nargin ~= nargout || nargin == 0
        error('Number of inputs must equal number of outputs and be at least 1.');
    end
    varargout = varargin;
    for arg = 1:nargin
        varargout{arg} = addBorders(varargin{arg}, 1);
    end
end