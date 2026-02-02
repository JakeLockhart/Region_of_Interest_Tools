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
            obj = CommitAndClose(obj, Window);

        end
    end

    methods (Access = public)
        function Recall(obj)
            RecallUserROIs(obj);
        end
    end

    methods (Access = private)
        function obj = CommitAndClose(obj, Window)
            obj = CommitROIsToManager(obj, Window);
        end
    end
end