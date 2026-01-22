classdef (Abstract) WindowManager < handle
    properties (Access = public)
        window
        selectedAxes
        axesHandles
        drawer
        ROIObjects
    end

    methods (Abstract)
        DefineWindowLayout(obj)
        DefineImagePanel(obj, parentClass)
        DefineControlPanel(obj, parentClass)
    end
end