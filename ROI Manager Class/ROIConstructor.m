classdef ROIConstructor < handle
    properties(Access = private)
        parentClass
        windowClass
    end

    methods
        function obj = ROIConstructor(parentClass, windowClass)
            obj.parentClass = parentClass;
            obj.windowClass = windowClass;
        end
    end

    methods(Access = public)
        function draw(obj, ax, shape)
            ROIObject = DrawROI(ax, shape, obj.parentClass);
            AdjustROIThickness(ROIObject, ax);

            axesList = obj.windowClass.axesHandles;
            ImageIndex = find(axesList == ax, 1);

            if isempty(ImageIndex)
                warning("Could not find the tile index for selected axes");
                return;
            end

            % ROIIndex = numel(obj.parentClass.ROIMask{ImageIndex}) + 1;
            ROIIndex = obj.getNextROIIndex(ImageIndex, shape);
            ROIObject.UserData.ID = ROIIdentifier.MakeID(ImageIndex, shape(1), ROIIndex);

            obj.windowClass.ROIObjects{ImageIndex}{ROIIndex} = ROIObject;
            obj.parentClass.ROIMask{ImageIndex}{ROIIndex} = createMask(ROIObject);
% obj.windowClass.ROIObjects{ImageIndex}{end+1} = ROIObject;
% obj.parentClass.ROIMask{ImageIndex}{end+1} = createMask(ROIObject);
        end
    end

    methods(Access = private)
        function ROIIndex = getNextROIIndex(obj, ImageIndex, shape)
            ROIList = obj.windowClass.ROIObjects{ImageIndex};
            shapeInitial = shape(1);

            if isempty(ROIList)
                ROIIndex = 1;
                return
            end

            index = 0;
            for k = 1:numel(ROIList)
                ROI = ROIList{k};
                if isempty(ROI) || ~isfield(ROI.UserData, 'ID')
                    continue
                end

                ID = ROI.UserData.ID;
                if contains(ID, "_"+shapeInitial+"_")
                    index = index + 1;
                end
            end
            ROIIndex = index + 1;
        end
    end

end