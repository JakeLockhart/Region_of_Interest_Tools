classdef ROIProperties < dynamicprops & handle
    methods 
        function obj = ROIProperties(ROIobjs)
            for i = 1:numel(ROIobjs)
                ROIobj = ROIobjs{i};
                obj.SaveProperties(ROIobj);
            end
        end
    end

    methods (Access = private)
        function SaveProperties(obj, ROIobj)
            ObjectType = class(ROIobj);
            TypeParts = split(ObjectType, '.');
            ROIType = TypeParts{end};

            if ~isprop(obj, ROIType)
                addprop(obj, ROIType);
                obj.(ROIType) = {};
            end

            switch ROIType
                case 'Rectangle'
                    Info.Position = ROIobj.Position;
                    Info.Verticies = ROIobj.Vertices;

                case 'Circle'
                    Info.Center = ROIobj.Center;
                    Info.Radius = ROIobj.Radius;

                case 'Line'
                    Info.Position = ROIobj.Position;
                    Info.LineWidth = ROIobj.LineWidth;
                    Info.CenterPoints = mean(ROIobj.Position);
                    Info.ROIGeometry = LineGeometry(Info.Position, Info.LineWidth);

                case 'Spline'
                case 'Polygon'
                    Info.Position = ROIobj.Position;
                case 'Freehand'
                    Info.Position = ROIobj.Position;
                    Info.Waypoints = ROIobj.Waypoints;
                otherwise
                    Info = "Properties not defined in class";
            end

            obj.(ROIType){end + 1} = Info;
        end
    end

    methods (Access = public)
        function LineCenterGaps(obj)
            if ~isprop(obj, 'Line') || numel(obj.Line) < 2
                return
            end
            Gap = FindROIGap(obj);
            addprop(obj, "CumulativeGap");
            obj.CumulativeGap = Gap;
        end
    end


end