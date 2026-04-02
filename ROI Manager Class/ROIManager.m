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
            pushROIManager = CommitAndClose(obj, Window);
            pushROIManager.commitROIs;
            pushROIManager.closeManager;

        end
    end

    methods (Access = public)
        function recall(obj)
            RecallUserROIs(obj);
        end

        function delete(obj, ID)
            DeleteROI(obj).delete(ID);
        end
    end
end