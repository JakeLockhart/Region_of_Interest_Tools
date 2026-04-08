function ROIGeometry = ProfileGeometry(Position, Width, SamplesOnROI)
    % <Documentation>
        % ProfileGeometry()
        %   
        %   Created by: jsl5865
        %   
        % Syntax:
        %   ROIGeometry = ProfileGeometry(Position, Width, SamplesOnROI)
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
        %   
        % Input:
        %   Position        - An nx2 array of positions (x,y) representing a 1D path. 
        %   Width           - Scalar representing the full width of the drawn path.
        %   SamplesOnROIs   - The number of sample points along the path. Oversampling produces 
        %                       smoother/finer intensity profiles, while undersampling produces 
        %                       non-representative intensity profiles
        %
        % Output:
        %   ROIGeometry - A structure containing the offsets from the path
        %   
    % <End Documentation>

    arguments
        Position (:,2) double 
        Width (1,1) double {mustBeNumeric, mustBePositive}
        SamplesOnROI (1,1) double {mustBeNumeric, mustBePositive} = 1000
    end

    x = Position(:,1);
    y = Position(:,2);

    [X, Y, ~] = improfile([], x, y, SamplesOnROI);

    dx = gradient(X);
    dy = gradient(Y);
    magnitude = sqrt(dx.^2 + dy.^2);
    dx = dx ./ magnitude;
    dy = dy ./ magnitude;
    UnitX = -dy;
    UnitY = dx;

    Offsets = -Width/2:Width/2;
    TotalWidthOffsets = numel(Offsets);
    
    OffsetX = X * ones(1,TotalWidthOffsets) + UnitX * Offsets;
    OffsetY = Y * ones(1,TotalWidthOffsets) + UnitY * Offsets;

    ROIGeometry.OffsetX = OffsetX;
    ROIGeometry.OffsetY = OffsetY;

end