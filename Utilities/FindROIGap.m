function Gap = FindROIGap(ROIObject, MicronsPerPixel)
    % <Documentation>
        % FindROIGap()
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
        ROIObject
        MicronsPerPixel (1,1) double {mustBeNonnegative} = 0.570; 
    end

    if ~isprop(ROIObject, 'Line') || isempty(ROIObject.Line)
        Gap = NoGapDetected();
        return
    end

    CenterPoints = cellfun(@(LineStruct) LineStruct.CenterPoints, ...
                           ROIObject.Line, ...
                           "UniformOutput", false ...
                          );
    CenterPoints = vertcat(CenterPoints{:});

    TotalLines = size(CenterPoints, 1);
    if TotalLines < 2
        Gap = NoGapDetected();
        return
    end

    Gap = zeros(1, TotalLines - 1);
    for i = 1:TotalLines - 1
        dx = CenterPoints(i+1,1) - CenterPoints(i,1);
        dy = CenterPoints(i+1,2) - CenterPoints(i,2);
        Gap(i) = sqrt(dx^2 + dy^2) * MicronsPerPixel;
    end
    Gap = [0, cumsum(Gap)];

    function Gap = NoGapDetected()
        Gap = [];
        return
    end
end