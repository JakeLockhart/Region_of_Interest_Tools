classdef ROIManager < handle
    properties
        ImageStack
        ROIMask
        Properties
    end

    properties (Hidden)
        DefaultLineWidth = 2;
    end

    properties (Constant)
        ROI_Shape_List = {'Rectangle', ...
                          'Circle', ...
                          'Line', ...
                          'Spline', ...
                          'Polygon', ...
                          'Freehand'...
                         };
    end

    methods
        function obj = ROIManager(ImageStack)
            obj.ImageStack = ImageStack;
            obj.ROIMask = cell(1, numel(ImageStack));
            obj.Properties = cell(1, numel(ImageStack));

            Window = WindowConstructor(obj);
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
end