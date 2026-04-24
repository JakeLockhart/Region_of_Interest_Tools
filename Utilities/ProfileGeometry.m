function ROIGeometry = ProfileGeometry(Position, Width, PathLength, SamplesPerWidth, SamplesPerLength)
    % <Documentation>
        % ProfileGeometry()
        %   
        %   Created by: jsl5865
        %   
        % Syntax:
        %   ROIGeometry = ProfileGeometry(Position, Width, PathLength, SamplesPerWidth, SamplesPerLength)
        %   
        % Description:
        %   Generates a sampling region of interest profile based on the positions along a 'path' 
        %       (2D ROI; line, spline, etc), and the width of the path. The path is resampled from 
        %       MatLab's default sampling to a user defined value (SamplesOnROI) using MatLab's 
        %       improfile() from the imaging toolbox. Tangent vectors are computed along the path 
        %       and normal vectors are computed at each sample point. The 'band' profile is then 
        %       made by offsetting the path along the normal vectors which create a set of 
        %       coordinates for the 'adjusted' profile.
        %   Notes
        %       - The perpendicular directions are calculated based on the position's gradient 
        %         (2nd derivative), allowing functionality for linear and non-linear paths
        %       - Normal vectors are symmetric about the path's centerline
        %       - Sampling is done based on the 
        %   
        % Input:
        %   Position            - An nx2 array of positions (x,y) representing a 1D path. 
        %   Width               - Scalar representing the full width of the drawn path [pixels].
        %   PathLength          - Scalar representing the full arc length of the drawn path [pixels]
        %   SamplesPerWidth     - Cross-sectional sampling resolution
        %   SamplesPerLength    - Longitudinal sampling resolution
        %
        % Output:
        %   ROIGeometry - A structure containing the offsets from the path. Note that both fields 
        %                   (OffsetX and OffsetY) are nxm matrices where n represents the samples 
        %                   on the longitudinal axis and m represents the samples on the cross-sectional 
        %                   axis. So a single sample point is defined as [OffsetX(a,b), OffsetY(a,b)]. 
        %                   A set of samples points along the cross-sectional axis is defined as 
        %                   [OffsetX(a,:), OffsetY(a,:)] while a set of points along the longitudinal 
        %                   axis is defined as [OffsetX(:,a), OffsetY(:,a)].
        %   
    % <End Documentation>

    arguments
        Position (:,2) double 
        Width (1,1) double {mustBeNumeric, mustBePositive}
        PathLength (1,1) double {mustBeNumeric, mustBePositive}
        SamplesPerWidth (1,1) double {mustBeNumeric, mustBeGreaterThanOrEqual(SamplesPerWidth, 1)} = 1.5
        SamplesPerLength  (1,1) double {mustBeNumeric, mustBeGreaterThanOrEqual(SamplesPerLength, 1)} = 1
    end

    x = Position(:,1);
    y = Position(:,2);

    SamplesOnLongitudinalAxis = max(1, round(PathLength * SamplesPerLength));
    [X, Y, ~] = improfile([], x, y, SamplesOnLongitudinalAxis);

    dx = gradient(X);
    dy = gradient(Y);
    magnitude = sqrt(dx.^2 + dy.^2);
    dx = dx ./ magnitude;
    dy = dy ./ magnitude;
    UnitX = -dy;
    UnitY = dx;

    SamplesOnCrossSectionalAxis = max(1, Width * SamplesPerWidth);
    Offsets = linspace(-Width/2, Width/2, SamplesOnCrossSectionalAxis);
    TotalWidthOffsets = numel(Offsets);
    
    OffsetX = X * ones(1,TotalWidthOffsets) + UnitX * Offsets;
    OffsetY = Y * ones(1,TotalWidthOffsets) + UnitY * Offsets;

    ROIGeometry.OffsetX = OffsetX;
    ROIGeometry.OffsetY = OffsetY;

end