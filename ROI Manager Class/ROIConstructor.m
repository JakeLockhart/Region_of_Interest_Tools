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
            ROIObject = DrawROI(ax, shape);
            AdjustROIThickness(ROIObject, ax);

            axesList = obj.windowClass.axesHandles;
            ImageIndex = find(axesList == ax, 1);

            if isempty(ImageIndex)
                warning("Could not find the tile index for selected axes");
                return;
            end

            if isempty(obj.parentClass.ROIMask{ImageIndex})
                ROIIndex = 1;
            else
                ROIIndex = numel(obj.parentClass.ROIMask{ImageIndex}) + 1;
            end

            obj.windowClass.ROIObjects{ImageIndex}{ROIIndex} = ROIObject;
            obj.parentClass.ROIMask{ImageIndex}{ROIIndex} = createMask(ROIObject);
        end
    end

end