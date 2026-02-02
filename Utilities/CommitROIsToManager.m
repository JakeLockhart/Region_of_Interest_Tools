function ROIObject = CommitROIsToManager(ROIObject, Window)
    % <Documentation>
        % CommitROIsToManager()
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

    for Stack = 1:numel(ROIObject.ImageStack)
        if ~isempty(ROIObject.ROIMask{Stack})
            ROIObject.ROIMask{Stack} = fliplr(ROIObject.ROIMask{Stack});
            ROIObject.Properties{Stack} = ROIProperties(Window.ROIObjects{Stack});

            if isprop(ROIObject.Properties{Stack}, 'Line')
                ROIObject.Properties{Stack}.LineCenterGaps();
            end
        end
    end

    if isvalid(Window.window)
        close(Window.window);
    end
end