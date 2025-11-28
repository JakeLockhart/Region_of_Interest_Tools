function RecallROI(Stack, ROIInfo, MicronsPerPixel)
    % <Documentation>
        % RecallROI()
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
        Stack
        ROIInfo
        MicronsPerPixel (1,1) double {mustBeNonnegative} = 0.570; 
    end

    MeanProjection(Stack);
    TotalROIs = numel(ROIInfo.ROIs);
    hold on

    FaceAlpha = 0.75;
    ColorMap = [0 0.4470 0.7410 FaceAlpha];

    CenterPoints = vertcat(ROIInfo.LineCenterPoints{:});
    CenterX = CenterPoints(:,1);
    CenterY = CenterPoints(:,2);
    
    Gap = zeros(1, TotalROIs - 1);
    for i = 1:TotalROIs-1
        dx = CenterX(i+1) - CenterX(i);
        dy = CenterY(i+1) - CenterY(i);
        Gap(i) = sqrt(dx^2 + dy^2) * MicronsPerPixel;
    end

    for i = 1:TotalROIs
        plot(ROIInfo.LineEndPoints{i}(:,1), ROIInfo.LineEndPoints{i}(:,2), ...
             "Color", ColorMap, ...
             "LineWidth", ROIInfo.LineWidth{i});
        plot(CenterX(i), CenterY(i), 'o--r', "LineWidth", 1.5, "MarkerSize", 3);
    end

     plot(CenterX, CenterY, '--or', "Color", 'r', "LineWidth", 1.5, "MarkerFaceColor", 'r', "MarkerSize", 6);

    for i = 1:numel(Gap)
        midX = (CenterX(i) + CenterX(i+1)) / 2;
        midY = (CenterY(i) + CenterY(i+1)) / 2;
        text(midX, midY, sprintf('%.2f µm', Gap(i)), ...
             'Color', 'k', ...
             'FontSize', 7.5, ...
             'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'bottom');
    end

end