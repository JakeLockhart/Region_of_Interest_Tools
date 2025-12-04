classdef RecallUserROIs < handle
    properties (Access = private)
        ParentClass
        RecallWindow
    end

    methods
        function obj = RecallUserROIs(ParentClass)
            obj.ParentClass = ParentClass;
            obj.RecallWindow = obj.CreateRecallWindow();
            obj.DisplayROIs(obj.RecallWindow)
        end
    end

    methods (Access = private)
        function Window = CreateRecallWindow(obj)
            Window.Figure = figure("Name", "Recalled Image Stack(s) and User Defined ROIs");
            Window.Tiles = tiledlayout(Window.Figure, "flow", ...
                                       "TileSpacing", "compact", ...
                                       "Padding", "compact" ...
                                      );
            Window.Axes = gobjects(1, numel(obj.ParentClass.ImageStack));

            for WindowPanel = 1:numel(obj.ParentClass.ImageStack)
                ax = nexttile(Window.Tiles);
                imshow(obj.ParentClass.ImageStack{WindowPanel}, [], "Parent", ax);
                Window.Axes(WindowPanel) = ax;
            end
        end

        function DisplayROIs(obj, Window) 
            for i = 1:numel(obj.ParentClass.Properties)
                PropertyInfo = obj.ParentClass.Properties{i};
                if isempty(PropertyInfo)
                    continue
                end

                ROITypes = properties(PropertyInfo);
                for j = 1:numel(ROITypes)
                    ROI_Shape = ROITypes{j};
                    if ~ismember(ROI_Shape, obj.ParentClass.ROI_Shape_List)
                        continue
                    end

                    ROI_List = PropertyInfo.(ROI_Shape);
                    if isempty(ROI_List)
                        continue
                    elseif ~iscell(ROI_List)
                        ROI_List = {ROI_List};
                    end

                    for k = 1:numel(ROI_List)
                        Info = ROI_List{k};
                        obj.ReconstructROI(ROI_Shape, Info, Window, i);
                    end
                end
            end
        end

        function GhostROI = ReconstructROI(~, ROI_Shape, Property, Window, ImageIndex)
            ax = Window.Axes(ImageIndex);

            switch ROI_Shape
                case 'Rectangle'
                    GhostROI = drawrectangle(ax, ...
                                             "Position", Property.Position, ...
                                             "FaceAlpha", 0.1 ...
                                            );
                case 'Circle'
                    GhostROI = drawcircle(ax, ...
                                          "Center", Property.Center, ...
                                          "Radius", Property.Radius, ...
                                          "FaceAlpha", 0.1 ...
                                         );
                case 'Line'
                    GhostROI = drawline(ax, ...
                                        "Position", Property.Position, ...
                                        "LineWidth", Property.LineWidth ...
                                       );
                case 'Polygon'
                    GhostROI = drawpolygon(ax, ...
                                           "Position", Property.Position, ...
                                           "FaceAlpha", 0.1 ...
                                          );
                case 'Freehand'
                    GhostROI = drawfreehand(ax, ...
                                             "Position", Property.Position, ...
                                             "FaceAlpha", 0.1 ...
                                            );
                otherwise
                    error("ROI shape '%s' not supported.", ROI_Shape);
            end
            GhostROI.InteractionsAllowed = "None";
        end
    end

end