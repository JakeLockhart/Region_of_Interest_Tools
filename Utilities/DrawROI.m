function ROI = DrawROI(ax, ROI_Shape, parentClass)
    % <Documentation>
        % DrawROI()
        %   Draw a user-defined region of interest (ROI) on an axes of a graphical object.
        %   Created by: jsl5865
        %   
        % Syntax:
        %   ROI = DrawROI(ax, ROI_Shape)
        %   
        % Description:
        %   This is the base function used to draw ROIs on an image. The goal is to have the
        %       creation of all ROI shapes contained within this function so that this single 
        %       function can be called for drawing multiple ROIs.
        %   The image axes must be defined prior to drawing the ROI.
        %   The ROI outline's thickness is 2pts by default, but can be controlled with the 
        %       AdjustROIThickness().
        %   Double clicking on the ROI area can 'lock' the ROI.
        %   
        % Input:
        %   ax        - Axes object; The target axes that an ROI will be drawn on. (The image)
        %   ROI_Shape - The shape of the ROI to be drawn. Currently supported shapes:
        %                   Rectangle | Circle |Line
        %                   Spline | Polygon | Freehand
        %   
        % Output:
        %   ROI - A handle to create the ROI object which can be called for further analysis.
        %   
    % <End Documentation>

    arguments
        ax (1,1) matlab.graphics.axis.Axes
        ROI_Shape char
        parentClass
    end

    switch ROI_Shape
        case 'Rectangle'
            ROI = drawrectangle(ax);
        case 'Circle'
            ROI = drawcircle(ax);
        case 'Line'
            ROI = drawline(ax, ...
                           "LineWidth", parentClass.DefaultLineWidth ...
                          );
        case 'Spline'
            ROI = drawfreehand(ax, ...
                               "Closed", false, ...
                               "FaceAlpha", 0 ...
                              );
        case 'Polygon'
            ROI = drawpolygon(ax);
        case 'Freehand'
            ROI = drawfreehand(ax);
        otherwise
            error('ROI shape not available')
    end

    if isprop(ROI, "LineWidth")
        ROI.LineWidth = parentClass.DefaultLineWidth;
    end

    AdjustROIThickness(ROI, ax, parentClass);
    wait(ROI);
end
