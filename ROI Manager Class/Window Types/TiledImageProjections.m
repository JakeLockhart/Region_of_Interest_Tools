classdef TiledImageProjections < WindowManager
    properties(Access = private)
        parentClass

        mainLayout
        imagePanel
        tiles
        displayImage
        controlPanel
        controlPanel_Grid
        dropDown
        drawButton
        doneButton
    end

    methods
        function obj = TiledImageProjections(parentClass)
            obj.parentClass = parentClass;
            obj.ROIObjects = cell(1, numel(parentClass.ImageStack));
            obj.DefineWindowLayout();
            obj.DefineImagePanel();
            obj.DefineControlPanel();
        end
    end

    methods (Access = public)
        function SetSelectedAxes(obj, src)
            obj.selectedAxes = src;
        end

        function DrawButton(obj)
            if isempty(obj.selectedAxes) || ~isvalid(obj.selectedAxes)
                uialert(obj.window, "Click on an image tile first to select it.", "No Tile Selected")
                return
            end

            shape = obj.dropDown.Value;
            obj.drawer.draw(obj.selectedAxes, shape)
        end
    end

    methods
        %% Define User Interface Layout
        function DefineWindowLayout(obj)
            obj.window = uifigure('Name', 'Tiled Mean Projections to Create ROIs');
            obj.mainLayout = uigridlayout(obj.window, [2,1]);
            obj.mainLayout.RowHeight = {'1x', 50};
            obj.mainLayout.ColumnWidth = {'1x'};

            obj.window.WindowKeyPressFcn = @(src, event) obj.KeyPressHandler(event);
        end

        %% Image Display Panel
        function DefineImagePanel(obj)
            obj.imagePanel = uipanel(obj.mainLayout);
            obj.imagePanel.Layout.Row = 1;
            
            obj.tiles = tiledlayout(obj.imagePanel, 'flow');
            obj.tiles.Padding = 'compact';
            obj.tiles.TileSpacing = 'compact';
            obj.tiles.Units = 'normalized';
            obj.tiles.Position = [0, 0, 1, 1];

            TotalStacks = numel(obj.parentClass.ImageStack);
            obj.axesHandles = gobjects(TotalStacks, 1);

            for Stack = 1:TotalStacks
                obj.axesHandles(Stack) = nexttile(obj.tiles);
                h = imshow(obj.parentClass.ImageStack{Stack}, [], 'Parent', obj.axesHandles(Stack));

                h.ButtonDownFcn = @(~,~) obj.SetSelectedAxes(obj.axesHandles(Stack));
            end

            if TotalStacks == 1
                obj.selectedAxes = obj.axesHandles(1);
            end
        end

        %% Control Panel: ROI shape dropdown, Draw, Done
        function DefineControlPanel(obj)
            obj.controlPanel = uipanel(obj.mainLayout);
            obj.controlPanel.Layout.Row = 2;
            obj.controlPanel_Grid = uigridlayout(obj.controlPanel, [1,3]);
            obj.controlPanel_Grid.ColumnWidth = {'1x', 100, 100};

            obj.dropDown = uidropdown(obj.controlPanel_Grid, ...
                                "Items", obj.parentClass.ROI_Shape_List, ...
                                "Value", obj.parentClass.ROI_Shape_List{1}, ...
                                "Tooltip", "Select ROI shape" ...
                                );
            obj.dropDown.Layout.Row = 1;
            obj.dropDown.Layout.Column = 1;

            obj.drawButton = uibutton(obj.controlPanel_Grid, ...
                            "Text", "Draw ROI", ...
                            "ButtonPushedFcn", @(~,~) obj.DrawButton() ...
                        );
            obj.drawButton.Layout.Row = 1;
            obj.drawButton.Layout.Column = 2;

            obj.doneButton = uibutton(obj.controlPanel_Grid, ...
                            "Text", "Done", ...
                            "ButtonPushedFcn", @(~,~) uiresume(obj.window) ...
                        );
            obj.doneButton.Layout.Row = 1;
            obj.doneButton.Layout.Column = 3;    
        end

        %% Keybinds
        function KeyPressHandler(obj, event)
            switch event.Key
                case 'space'
                    obj.DrawButton();
            end
        end

    end


end