function ROIProfile = AdjustedImprofile(image, roiGeometry, varargin)
    % <Documentation>
        % AdjustedImprofile()
        %   Samples the pixel intensity values along a user-defined line with adjustable thickness.
        %   Created by: jsl5865
        %   
        % Syntax:
        %   ROIProfile = AdjustedImprofile(Image, LineEndPoints, LineWidth)
        %   
        % Description:
        %   This function calculates an intensity profile along a line segment in an image. This is 
        %       an extention of MatLab's improfile() by allowing the profile to have a 'thickness' 
        %       which allows for averaging across the line's width to produce a smoothed intensity 
        %       profile. This allows for more robust intensity measurements when the profile is meant 
        %       to represent a 'band' rather than a single-pixel width line.
        %   The number of samples across the profile is fixed to 1000 samples.
        %   Larger line width values produce smoother profiles by averaging over a wider range.
        %
        % Input:
        %   Image         - 2D image (2D numerical array) to extract the pixel intensity 
        %   LineEndPoints - 2x2 matrix specifying the [x,y] coordinates of the line endpoints:
        %                   [x1 y1; x2 y2]
        %   LineWidth     - Scalar specifying the half-width (in pixels) of the band perpendicular to
        %                   the line profile. 
        %   
        % Output:
        %   ROIProfile - Column vector containing the averaged intensity values along the line profile.
        %   
    % <End Documentation>

    parameters = parseInputs(image, roiGeometry, varargin{:});
    offsetX = roiGeometry.OffsetX;
    offsetY = roiGeometry.OffsetY;

    samples = interp2(double(image), offsetX, offsetY, "linear", NaN);
    switch parameters.ProfileAxis
        case "AlongPath"
            ROIProfile = mean(samples, 1, 'omitnan');
        case "AcrossPath"
            ROIProfile = mean(samples, 2, 'omitnan');
        case "None"
            ROIProfile = samples;
    end

    % ROIProfile = mean(Values, 2, 'omitnan');


    function parameters = parseInputs(image, roiGeometry, varargin)
        % Validate required inputs (image, roiGeometry)
            if ~isnumeric(image) || isvector(image) || ndims(image) > 3
                me = MException('InvalidEntry:image', 'Image is not numeric or the proper dimensions');
                throwAsCaller(me)
            end

            if ~isstruct(roiGeometry) || ~isfield(roiGeometry, "OffsetX") || ~isfield(roiGeometry, "OffsetY")
                me = MException('InvalidEntry:roiGeometry', 'roiGeometry is invalid. Ensure roiGeometry comes from ProfileGeometry.m');
                throwAsCaller(me)
            end

        % Name-value pairs
            p = inputParser;

            addParameter(p, 'ProfileAxis', "AlongPath", @(value) isscalar(value) && ismember(value, ["AlongPath", "AcrossPath", "None"]));
            addParameter(p, 'BinSamples', 1, @(value) isscalar(value) && isnumeric(value))
            addParameter(p, 'PixelResolution', 1, @(value) isscalar(value) && isnumeric(value))

        % Parse through parameters
            parse(p, varargin{:});
            parameters = p.Results;

        % Validate optional inputs

    end

end