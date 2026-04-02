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

            ROIIndex = obj.getGlobalROIIndex(ImageIndex);
            ROIObject.UserData.ID = ROIIdentifier.MakeID(ImageIndex, shape(1), ROIIndex);

            obj.windowClass.ROIObjects{ImageIndex}{ROIIndex} = ROIObject;
            obj.parentClass.ROIMask{ImageIndex}{ROIIndex} = createMask(ROIObject);
        end
    end

    methods(Access = private)
        function index = getGlobalROIIndex(obj, imageIndex)
            if isempty(obj.windowClass.ROIObjects{imageIndex})
                obj.windowClass.ROIObjects{imageIndex} = {};
            end

            index = numel(obj.windowClass.ROIObjects{imageIndex}) + 1;
        end
    end

end