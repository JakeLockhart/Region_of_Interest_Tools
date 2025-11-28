function [ImageInfo, FigureWindow] = TiledChannelROISliderView(ImageStacks, Rows, Masks)
    % TiledSliceViewer with mask overlays using tiledlayout('flow') inside a panel,
    % and sliders + buttons in separate panels below.
    %
    % Syntax:
    %   [ImageInfo, FigureWindow] = masksliceview(ImageStacks, Rows, Masks)
    %
    % Inputs:
    %   ImageStacks - Cell array of 3D numeric arrays [H,W,Slices]
    %   Rows        - Number of rows (not used here, optional)
    %   Masks       - Cell array of 3D logical masks (one per stack)
    %
    % Outputs:
    %   ImageInfo   - Struct with metadata for each stack
    %   FigureWindow - UIFigure handle

    arguments
        ImageStacks
        Rows {mustBeNumeric, mustBePositive} = 1 %#ok<INUSA>
        Masks cell = {}
    end

    TotalStacks = length(ImageStacks);

    % Ensure Masks cell array matches length of ImageStacks
    if isempty(Masks)
        Masks = cell(1, TotalStacks);
    elseif length(Masks) < TotalStacks
        Masks(length(Masks)+1:TotalStacks) = {[]};
    end

    % Collect stack info
    for i = 1:TotalStacks
        ImageInfo.StackName{i} = "Stack " + num2str(i);
        ImageInfo.StackSize{i} = size(ImageStacks{i}, [1,2]);
        ImageInfo.TotalFrames{i} = size(ImageStacks{i}, 3);
        ImageInfo.ReferencePlane{i} = nan;
    end

    ReferencePlanes = nan(1, TotalStacks);

    % Create UIFigure
    FigureWindow = uifigure('Name', 'Mask Slice Viewer', 'Position', [100 100 900 700]);

    % Main grid: 3 rows (images, sliders, buttons), 1 column
    mainLayout = uigridlayout(FigureWindow, [3,1]);
    mainLayout.RowHeight = {'1x', 100, 60}; % 100 px for sliders+labels
    mainLayout.ColumnWidth = {'1x'};

    % --- Images panel (row 1) ---
    topPanel = uipanel(mainLayout);
    topPanel.Layout.Row = 1;
    topPanel.Layout.Column = 1;

    tileLayout = tiledlayout(topPanel, 'flow');
    tileLayout.Padding = 'compact';
    tileLayout.TileSpacing = 'compact';
    tileLayout.Units = 'normalized';
    tileLayout.Position = [0 0 1 1];

    ax = gobjects(TotalStacks, 1);
    Image = gobjects(TotalStacks, 1);
    BoundaryPlots = cell(TotalStacks, 1);

    for i = 1:TotalStacks
        ax(i) = nexttile(tileLayout);
        axis(ax(i), 'image');
        Image(i) = imshow(ImageStacks{i}(:,:,1), 'Parent', ax(i), 'DisplayRange', []);

        % Plot initial mask boundaries if any
        if ~isempty(Masks{i})
            hold(ax(i), 'on');
            B = bwboundaries(Masks{i}(:,:,1));
            BoundaryPlots{i} = gobjects(length(B),1);
            for k = 1:length(B)%#ok<FXUP>
                BoundaryPlots{i}(k) = plot(ax(i), B{k}(:,2), B{k}(:,1), 'r', 'LineWidth', 1.5);
            end
            hold(ax(i), 'off');
        end
    end

    % --- Sliders panel (row 2) ---
    sliderPanel = uipanel(mainLayout);
    sliderPanel.Layout.Row = 2;
    sliderPanel.Layout.Column = 1;

    sliderGrid = uigridlayout(sliderPanel, [2, TotalStacks]);
    sliderGrid.RowHeight = {22, '1x'}; % 22 px for label, rest for slider
    sliderGrid.ColumnWidth = repmat({'1x'},1,TotalStacks);

    % Add labels and sliders
    for i = 1:TotalStacks
        lbl = uilabel(sliderGrid, ...
            'Text', ImageInfo.StackName{i}, ...
            'HorizontalAlignment', 'center', ...
            'FontWeight', 'bold');
        lbl.Layout.Row = 1;
        lbl.Layout.Column = i;

        sld = uislider(sliderGrid, ...
            'Limits', [1, ImageInfo.TotalFrames{i}], ...
            'Value', 1, ...
            'MajorTicks', 1:round(ImageInfo.TotalFrames{i}/5):ImageInfo.TotalFrames{i}, ...
            'ValueChangedFcn', @(sld, ~) updateSlice(i), ...
            'ValueChangingFcn', @(sld, event) updateSlice(i, event.Value), ...
            'Tooltip', sprintf('Slice slider for %s', ImageInfo.StackName{i}));
        sld.Layout.Row = 2;
        sld.Layout.Column = i;
        Slider(i) = sld;
    end

    % --- Buttons panel (row 3) ---
    buttonPanel = uipanel(mainLayout);
    buttonPanel.Layout.Row = 3;
    buttonPanel.Layout.Column = 1;

    buttonGrid = uigridlayout(buttonPanel, [1, 3]);
    buttonGrid.RowHeight = {'1x'};
    buttonGrid.ColumnWidth = {'1x','1x','1x'};

    % Create buttons in button panel
    GetButton = uibutton(buttonGrid, 'Text', 'Get Indices', ...
        'ButtonPushedFcn', @(btn,~) getIndices());
    GetButton.Layout.Row = 1;
    GetButton.Layout.Column = 1;

    ResetButton = uibutton(buttonGrid, 'Text', 'Reset', ...
        'ButtonPushedFcn', @(btn,~) resetSliders());
    ResetButton.Layout.Row = 1;
    ResetButton.Layout.Column = 2;

    CancelButton = uibutton(buttonGrid, 'Text', 'Cancel', ...
        'ButtonPushedFcn', @(btn,~) cancelWindow());
    CancelButton.Layout.Row = 1;
    CancelButton.Layout.Column = 3;

    drawnow;  % Force UI to render properly

    uiwait(FigureWindow);

    if isvalid(FigureWindow) && isprop(FigureWindow, 'UserData')
        temp = FigureWindow.UserData;
        if isnumeric(temp) && numel(temp) == TotalStacks
            ReferencePlanes = temp;
        end
    end

    for i = 1:TotalStacks
        ImageInfo.ReferencePlane{i} = ReferencePlanes(i);
    end

    if isvalid(FigureWindow)
        close(FigureWindow);
    end

    % Nested functions
    function updateSlice(idx, val)
        if nargin < 2
            val = Slider(idx).Value;
        end
        sliceIdx = round(val);
        Image(idx).CData = ImageStacks{idx}(:,:,sliceIdx);

        if ~isempty(Masks{idx})
            % Delete old boundaries safely if they exist
            if ~isempty(BoundaryPlots{idx}) && all(isgraphics(BoundaryPlots{idx}))
                delete(BoundaryPlots{idx}(:));
            end
            hold(ax(idx), 'on');
            B = bwboundaries(Masks{idx}(:,:,sliceIdx));
            BoundaryPlots{idx} = gobjects(length(B),1);
            for k = 1:length(B)%#ok<FXUP>
                BoundaryPlots{idx}(k) = plot(ax(idx), B{k}(:,2), B{k}(:,1), 'r', 'LineWidth', 1.5);
            end
            hold(ax(idx), 'off');
        end
    end


    function getIndices()
        for j = 1:TotalStacks
            ReferencePlanes(j) = round(Slider(j).Value);
        end
        FigureWindow.UserData = ReferencePlanes;
        uiresume(FigureWindow);
    end

    function resetSliders()
        for j = 1:TotalStacks
            Slider(j).Value = 1;
            updateSlice(j, 1);
        end
    end

    function cancelWindow()
        FigureWindow.UserData = [];
        uiresume(FigureWindow);
    end
end