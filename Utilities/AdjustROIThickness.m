function AdjustROIThickness(ROI, ax)
    % <Documentation>
        % AdjustROIThickness()
        %   Allows for interactive adjustment of ROI outline thickness
        %   Created by: jsl5865
        %   
        % Syntax:
        %   AdjustROIThickness(ROI, ax)
        %
        % Description:
        %   This function allows users to control the width of an ROI interactively after
        %       the ROI is drawn. 
        %   The scroll wheel controls the outline's thickness. 
        %       Scrolling (↑) increase the outline's thickness.
        %       Scrolling (↓) decreases the outline's thickness.
        %   The outline thickness is currently contstrained to be between 0.5 and 100pts.
        %   
        %   Known Bug: Resizing the uiFigure window adjusts the thickness range of the ROI.
        %
        % Input:
        %   ax  - Axes object; The target axes that an ROI will be drawn on. (The image)
        %   ROI - The handle to the ROI object (from drawrectangle(), drawline(), etc. 
        %         within DrawROI())
        %
        % Output:
        %   NA - Live adjustment of ROI outline thickness
        %   
    % <End Documentation>

    Step = 1;

    Window = ancestor(ax, 'figure');
    Window.WindowScrollWheelFcn = @(~, event) AdjustLineWidth(event, ROI);

    function AdjustLineWidth(event, ROI)
        if isvalid(ROI) && isprop(ROI, 'LineWidth')
            AdjustedWidth = ROI.LineWidth + Step * -sign(event.VerticalScrollCount);

            ROI.LineWidth = max(0.5, min(AdjustedWidth, 100));
        end
    end
end