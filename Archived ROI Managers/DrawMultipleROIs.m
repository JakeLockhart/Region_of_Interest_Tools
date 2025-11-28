function ROI = DrawMultipleROIs(ax, ROI_Shape, SaveFigure)
    % <Documentation>
        % DrawMultipleROIs()
        %   Interactive drawing & labeling of multiple ROIs on a specified axes object.
        %   Created by: jsl5865
        %   
        % Syntax:
        %   ROI = DrawMultipleROIs(ax, ROI_Shape, SaveFigure)
        %   
        % Description:
        %   This function creates a loop for drawing multiple ROIs on a given axes. After each
        %       ROI is drawn, the user can confirm by double-clicking the region or by pressing
        %       'Enter' to proceed and draw the next ROI. 
        %   Pressing 'Escape' ends the interactive ROI drawing. 
        %   Each ROI is labeled and displayed in a unique color. If a file path is provided, the 
        %       figure with the ROIs will be saved in the specified file format (.fig or image file).
        %
        % Input:
        %   ax         - Axes object; The target axes that an ROI will be drawn on. (The image)
        %   ROI_Shape  - The shape of the ROI to be drawn. Defined in DrawROI()
        %   SaveFigure - Optional file path for saving the figure after the ROIs have been drawn.
        %   
        % Output:
        %   ROI - A cell array containing binary masks of the drawn ROIs. Each cell corresponds
        %         to one ROI mask.
        %   
    % <End Documentation>

    arguments
        ax
        ROI_Shape char {mustBeMember(ROI_Shape, {'Rectangle', 'Circle', 'Line', 'Spline', 'Polygon', 'Freehand'})} = 'Rectangle'
        SaveFigure char = ''
    end
    fprintf('Draw %s ROIs one by one. Double-click region or press enter to confrim and draw another ROI.\nPress Esc to finish...  \n', ROI_Shape)

    ROI = {};
    Index = 0;

    Image = ancestor(ax, 'figure');
    set(Image, 'KeyPressFcn', @EscListener)
    FinishedDrawingROIs = false;

    while isvalid(Image) && ~FinishedDrawingROIs
        try
            Index = Index + 1;
            TempROI = DrawROI(ax, ROI_Shape);
            if isvalid(TempROI) && ~isempty(TempROI.Position)
                TempROI.Label = sprintf('ROI %d', Index);
                ROI{end+1} = createMask(TempROI);
            else
                delete(TempROI)
                break;
            end
        catch
            break;
        end
    end

    if isvalid(Image) && ~isempty(ROI)
        TotalROIs = length(ROI);
        ColorMap = jet(TotalROIs);

        for i = 1:TotalROIs
            try
                ROI{i}.Color = ColorMap(i,:);
                ROI{i}.LineWidth = 1;

                if isprop(ROI{i}, 'InteractionsAllowed')
                    ROI{i}.InteractionsAllowed = 'none';
                end
                if isprop(ROI{i}, 'FaceAlpha')
                    ROI{i}.FaceAlpha = 0;
                end
            catch
                % Some draw_() ROIs may not support these properties
            end
        end


        drawnow;

        if ~isempty(SaveFigure)
            SaveFigureWithROIs(SaveFigure);
        end
    end

    fprintf('Finished drawing ROIs ✓\n')

    function EscListener
        if strcmp(event.Key, 'escape')
            FinishedDrawingROIs = true;
        end
    end

    function SaveFigureWithROIs(SaveFigure)
        [~, ~, ext] = fileparts(SaveFigure);
        switch ext
            case '.fig'
                savefig(Image, SaveFigure);
            otherwise
                saveas(Image, SaveFigure);
        end
        fprintf('Figure saved as a %s\n', ext)
    end
end