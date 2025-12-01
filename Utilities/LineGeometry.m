function ROIGeometry = LineGeometry(Position, Width, SamplesOnROI)
    % <Documentation>
        % LineGeometry()
        %   
        %   Created by: jsl5865
        %   
        % Syntax:
        %   
        % Description:
        %   
        % Input:
        %   
        % Output:
        %   
    % <End Documentation>

    arguments
        Position
        Width
        SamplesOnROI (1,1) double {mustBeNumeric, mustBePositive} = 1000
    end

    x = Position(:,1);
    y = Position(:,2);

    [X, Y, ~] = improfile([], x, y, SamplesOnROI);

    Theta = atan2(Y(end) - Y(1), X(end) - X(1));
    UnitX = -sin(Theta);
    UnitY =  cos(Theta);

    Offsets = -Width:Width;
    TotalWidthOffsets = numel(Offsets);
    
    OffsetX = X * ones(1,TotalWidthOffsets) + UnitX * Offsets;
    OffsetY = Y * ones(1,TotalWidthOffsets) + UnitY * Offsets;

    ROIGeometry.OffsetX = OffsetX;
    ROIGeometry.OffsetY = OffsetY;

end