function varargout = labelaxes(ax, str, loc, varargin)
%LABELAXES Add text to axes in prescribed locations
%
% htxt = labelaxes(ax, labels, location) 
% htxt = labelaxes(ax, labels, location, Name, Value, ...)
%
% This function places text in an axis based on location strings similar to
% those used by legend.  It can be useful when labeling subaxes.
%
% This function is based on the textLoc
% (https://www.mathworks.com/matlabcentral/fileexchange/17151-textloc)
% function, but with a few extra features for added flexibility: it allows
% for application of labels to multiple axes at once, and provides more
% flexibility for specifying the buffers.
%
% Input variables:
%
%   ax:         array, handles of axes to be labeled
%
%   str:        text array with same number of elements as ax, specifying
%               label for each respective axis.  This can either be a
%               string array, a cell array of character vectors, or a cell
%               array of strings, character arrays, and/or cell arrays of
%               character vectors (the latter option allows for multiline
%               labels).  
%  
%  location:    string or character array specifying location of labels:
%               'North'                   inside plot box near top
%               'South'                   inside bottom
%               'East'                    inside right
%               'West'                    inside left
%               'Center'                  centered on plot
%               'NorthEast'               inside top right (default)
%               'NorthWest'               inside top left
%               'SouthEast'               inside bottom right
%               'SouthWest'               inside bottom left
%               'NorthOutside'            outside plot box near top
%               'SouthOutside'            outside bottom
%               'EastOutside'             outside right
%               'WestOutside'             outside left
%               'NorthEastOutside'        outside top right
%               'NorthWestOutside'        outside top left
%               'SouthEastOutside'        outside bottom right
%               'SouthWestOutside'        outside bottom left
%               'NorthEastOutsideAbove'   outside top right (above)
%               'NorthWestOutsideAbove'   outside top left (above)
%               'SouthEastOutsideBelow'   outside bottom right (below)
%               'SouthWestOutsideBelow'   outside bottom left (below)
%               'Random'                  Random placement inside axes
%                
%                or numeric scalar:
%    
%                1 = Upper right-hand corner (default)
%                2 = Upper left-hand corner
%                3 = Lower left-hand corner
%                4 = Lower right-hand corner
%               -1 = To the right of the plot
%
% Optional input variables, passed as parameter/value pairs:
%
%   hbuffer:    horizontal buffer, specifying distance from
%               horizontally-aligned side of the label (not applicable to
%               center-aligned labels) 
%               [1/50]
%
%   vbuffer:    vertical buffer, specifying distance from
%               vertically-aligned side of the label (not applicable to
%               middle-aligned labels) 
%               [1/50]
%
%   hbufferunit: unit used to measure hbuffer distance (relative to axis
%               position)
%               ['normalized']
%
%   vbufferunit: unit used to measure vbuffer distance (relative to axis
%               position)
%               ['normalized']
%
%   In addition to these function-specific options, any text property
%   (except 'Parent', 'Position', or 'Unit') can be passed to be applied to
%   all text objects.

% Copyright 2024 Kelly Kearney

% Parse and check input

p = inputParser;
p.addOptional('hbuffer', 1/50, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.addOptional('hbufferunit', 'norm', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
p.addOptional('vbuffer', 1/50, @(x) validateattributes(x, {'numeric'}, {'scalar'}));
p.addOptional('vbufferunit', 'norm', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
p.KeepUnmatched = true;
p.parse(varargin{:});
Opt = p.Results;
tprop = p.Unmatched;

Opt.hbufferunit = validatestring(Opt.hbufferunit, {'normalized', 'inches', 'centimeters', 'characters', 'points', 'pixels'});
Opt.vbufferunit = validatestring(Opt.vbufferunit, {'normalized', 'inches', 'centimeters', 'characters', 'points', 'pixels'});
hisnorm = strcmp(Opt.hbufferunit, 'normalized');
visnorm = strcmp(Opt.vbufferunit, 'normalized');

if ~all(ishandle(ax))
    error('First input must be an array of axes handles');
end

labelistext = isstring(str) || iscellstr(str) || ...
    (iscell(str) && all(cellfun(@(x) isstring(x) || iscellstr(x) || ischar(x), str)));
if ~labelistext || (numel(str) ~= numel(ax))
    error('Second input str must be a text array (string array or cell array of character arrays, strings, or cell arrays of strings/character arrays) with the same number of elements as first input ax');
end

if isnumeric(loc)
    loc = num2str(loc);
end

% Place text on each axis

for ii = 1:numel(ax)

    H = text(0,0, str{ii}, 'parent', ax(ii), tprop);

    % Translate buffer to normalized units if necessary

    hbuffer = Opt.hbuffer;
    vbuffer = Opt.vbuffer;
    if ~hisnorm || ~visnorm
        axunit = get(ax(ii), 'Units');

        if ~hisnorm
            set(ax(ii), 'Units', Opt.hbufferunit);
            hbuffer = Opt.hbuffer./ax(ii).Position(3);
        end
        if ~visnorm
            set(ax(ii), 'Units', Opt.vbufferunit);
            vbuffer = Opt.vbuffer./ax(ii).Position(4);
        end
        
        set(ax(ii), 'Units', axunit);
    end

    % Positioning as in textLoc (Author: Ben Barrowes,
    % barrowes@alum.mit.edu)

    set(H,'units','normalized');
    switch lower(loc)
      case 'north' %              inside plot box near top
        set(H,'Position',[.5,1-vbuffer]);
        set(H,'HorizontalAlignment','Center');
        set(H,'VerticalAlignment','Top');
      case 'south' %              inside bottom
        set(H,'Position',[.5,  vbuffer]);
        set(H,'HorizontalAlignment','Center');
        set(H,'VerticalAlignment','Bottom');
      case 'east' %               inside right
        set(H,'Position',[1-hbuffer,.5]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Middle');
      case 'west' %               inside left
        set(H,'Position',[  hbuffer,.5]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Middle');
      case 'center' %               inside left
        set(H,'Position',[.5,.5]);
        set(H,'HorizontalAlignment','Center');
        set(H,'VerticalAlignment','Middle');
      case {'northeast','1'} %          inside top right (default)
        set(H,'Position',[1-hbuffer,1-vbuffer]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Top');
      case {'northwest','2'} %           inside top left
        set(H,'Position',[  hbuffer,1-vbuffer]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Top');
      case {'southeast','4'} %          inside bottom right
        set(H,'Position',[1-hbuffer,  vbuffer]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Bottom');
      case {'southwest','3'} %          inside bottom left
        set(H,'Position',[  hbuffer,  vbuffer]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Bottom');
      case 'northoutside' %       outside plot box near top
        set(H,'Position',[.5,1+vbuffer]);
        set(H,'HorizontalAlignment','Center');
        set(H,'VerticalAlignment','Bottom');
      case 'southoutside' %       outside bottom
        set(H,'Position',[.5, -vbuffer]);
        set(H,'HorizontalAlignment','Center');
        set(H,'VerticalAlignment','Top');
      case 'eastoutside' %        outside right
        set(H,'Position',[1+hbuffer,.5]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Middle');
      case 'westoutside' %        outside left
        set(H,'Position',[ -hbuffer,.5]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Middle');
      case {'northeastoutside','-1'} %   outside top right
        set(H,'Position',[1+hbuffer,1]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Top');
      case 'northwestoutside' %   outside top left
        set(H,'Position',[ -hbuffer,1]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Top');
      case 'southeastoutside' %   outside bottom right
        set(H,'Position',[1+hbuffer,0]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Bottom');
      case 'southwestoutside' %   outside bottom left
        set(H,'Position',[ -hbuffer,0]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Bottom');
      case 'northeastoutsideabove' %   outside top right (above)
        set(H,'Position',[1,1+vbuffer]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Bottom');
      case 'northwestoutsideabove' %   outside top left (above)
        set(H,'Position',[0,1+vbuffer]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Bottom');
      case 'southeastoutsidebelow' %   outside bottom right (below)
        set(H,'Position',[1, -vbuffer]);
        set(H,'HorizontalAlignment','Right');
        set(H,'VerticalAlignment','Top');
      case 'southwestoutsidebelow' %   outside bottom left (below)
        set(H,'Position',[0, -vbuffer]);
        set(H,'HorizontalAlignment','Left');
        set(H,'VerticalAlignment','Top');
      case 'random' % random placement
        set(H,'Position',[rand(1,2)]);
        set(H,'HorizontalAlignment','Center');
        set(H,'VerticalAlignment','Middle');
      otherwise
        error('location not recognized')
    end

end

if nargout > 0
    varargout{1} = H;
end

