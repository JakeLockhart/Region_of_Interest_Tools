classdef ROIManager < handle
    properties
        ImageStack
        ROIMask
        Properties
    end

    properties (Hidden)
        DefaultLineWidth = 2;
    end

    properties (Constant, Hidden)
        ROI_Shape_List = {'Line', ...
                          'Rectangle', ...
                          'Circle', ...
                          'Spline', ...
                          'Polygon', ...
                          'Freehand'...
                         };
    end

    methods
        function obj = ROIManager(ImageStack, WindowType)
            arguments
                ImageStack (1,:) cell
                WindowType (1,1) string {mustBeMember(WindowType, ["TiledImageProjections"])} = "TiledImageProjections"
            end

            obj.ImageStack = ImageStack;
            obj.ROIMask = cell(1, numel(ImageStack));
            obj.Properties = cell(1, numel(ImageStack));

            switch WindowType
                case "TiledImageProjections"
                    Window = TiledImageProjections(obj);
            end

            Drawer = ROIConstructor(obj, Window);
            Window.drawer = Drawer;

            uiwait(Window.window);

            for Stack = 1:numel(obj.ImageStack)
                if ~isempty(obj.ROIMask{Stack})
                    obj.ROIMask{Stack} = fliplr(obj.ROIMask{Stack});
                    obj.Properties{Stack} = ROIProperties(Window.ROIObjects{Stack});
                    if isprop(obj.Properties{Stack}, 'Line')
                        obj.Properties{Stack}.LineCenterGaps();
                    end
                end
            end

            if isvalid(Window.window)
                close(Window.window);
            end
        end
    end

    methods (Access = public)
        function Recall(obj)
            RecallUserROIs(obj);
        end
    end
end