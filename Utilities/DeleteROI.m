function DeleteROI(ROIObject, ROI_Indices, Stack_Index)
    % <Documentation>
        % DeleteROI()
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
        ROI_Indices (1,:) double {mustBeNumeric, mustBeInteger, mustBePositive} = NaN
        Stack_Index (1,1) double {mustBeNumeric, mustBeInteger, mustBePositive} = 1
    end

    if isnan(ROI_Indices)
        return
    end

    TotalROIs = numel(ROI_Indices);
    for ROI = 1:ROI_Indices
        ROIObjects
    end

end