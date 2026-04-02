classdef CommitAndClose
    % <Documentation>
        % CommitAndClose
        %   Created by: jsl5865
        %   
        % Description:
        %   A class to finalize the ROIManager(). This creates and updates the properties
        %       for each user defined ROI and handles closing the uifigure window.
        %
        %   Warning
        %   MatLab sequentially adds ROIs (drawline, drawcircle, etc) to the front of arrays, 
        %       not to the end of the array. This means that when a user finishes drawing a 
        %       series of ROIs, the ROI masks and properties will be in the reverse order 
        %       (newest->oldest rather than oldest->newest). fliplr() linearly flips a vector 
        %       and can handle this issue. The ROI IDs need to be updated based on the correct 
        %       drawing order.
        %   In reality, this didn't *need* to be fixed, but OCD dictated it.
        %
    % <End Documentation>
    properties
        ROIManagerObj
        Window
    end

    methods
        function obj = CommitAndClose(ROIManagerObj, Window)
            obj.ROIManagerObj = ROIManagerObj;
            obj.Window = Window;
        end
    end

    methods(Access = public)
        function commitROIs(obj)
            for stack = 1:numel(obj.ROIManagerObj.ImageStack)
                if ~isempty(obj.ROIManagerObj.ROIMask{stack})
                    obj.ROIManagerObj.ROIMask{stack} = obj.restoreMaskOrder(obj.ROIManagerObj.ROIMask{stack});

                    obj.ROIManagerObj.Properties{stack} = ROIProperties(obj.Window.ROIObjects{stack});
                    obj.ROIManagerObj.Properties{stack} = obj.restorePropertyOrder(obj.ROIManagerObj.Properties{stack});
                    obj.ROIManagerObj.Properties{stack} = obj.addLineGap(obj.ROIManagerObj.Properties{stack});
                end
            end
        end

        function closeManager(obj)
            if isvalid(obj.Window)
                close(obj.Window.window)
            end
        end
    end

    methods(Access = private)
        function originalMask = restoreMaskOrder(~, mask)
            originalMask = fliplr(mask);
        end

        function roiProperty = restorePropertyOrder(~, roiProperty)
            for i = 1:numel(ROIManager.ROI_Shape_List)
                ROIType = ROIManager.ROI_Shape_List{i};
                if isprop(roiProperty, ROIType)
                    roiProperty.(ROIType) = fliplr(roiProperty.(ROIType));
                    
                    roiCells = roiProperty.(ROIType);
                    for trueIndex = 1:numel(roiCells)
                        oldID = roiCells{trueIndex}.ID;
                        roiCells{trueIndex}.ID = ROIIdentifier.UpdateID_Index(oldID, trueIndex);
                    end
                    roiProperty.(ROIType) = roiCells;
                end
            end
        end

        function roiProperty = addLineGap(~, roiProperty)
            if isprop(roiProperty, 'Line')
                roiProperty.LineCenterGaps();
            end
        end

    end

end