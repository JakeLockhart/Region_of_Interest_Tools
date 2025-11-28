function CroppedStack = CropStackToMask(Stack, Mask)
    % <Documentation>
        % CropStackToMask()
        %   Crop each frame of an image stack to a bounding box that surrounds an ROI.
        %   Created by: jsl5865
        %   
        % Syntax:
        %   CroppedStack = CropStackToMask(Stack, Mask)
        %
        % Description:
        %   This function crops an image stack (single or multiple frames) based on the ROI mask input. A
        %       bounding box is created that contains the ROI (regardless of ROI shape) and sets all pixel
        %       values outside of the mask to zero.
        %   The CroppedStack has the same number of frames as the input Stack but a reduced frame height
        %       and width.
        %   Note that because the Stack is not of class 'single' or 'double' NaN values are converted to 
        %       zero. This should not be a problem when comparing ROIs with the same bounding box. 
        %       If comparing absolute values, this may be problematic. However averaging the ROI
        %       instead of the cropped region, or analyzing the ROI will still be the most effective 
        %       method.
        %   
        % Input:
        %   Stack   - A numerical 3D array representing an image stack, with dimensions 
        %             Rows x Columns x Frames.
        %   Mask    - A binary 2D logical array defining an ROI. Non-zero pixel regions represent the ROI.
        %   
        % Output:
        %   CroppedStack - A numerical 3D array of cropped frames from Stack with pixels outside of the 
        %                  mask set to zero. Dimensions of the cropped region are based on a bounding box.  
        %
    % <End Documentation>
    
    ROI_Properties = regionprops(Mask, "BoundingBox");                      % Use regionprops() to determine the bounding box of the mask created from an ROI
    BoundingBox = round(ROI_Properties(1).BoundingBox);                     % Bounding boxes return numerical array with floating numbers, round for indexing purposes 

    CroppedMask = imcrop(Mask, BoundingBox);                                % Crop the masked region to the bounding box that contains the ROI

    [MaskHeight, MaskWidth] = size(CroppedMask);                            % Determine the 2D dimensions of the mask
    [~, ~, TotalFrames] = size(Stack);                                      % Determine the total frames within the image stack
    StackClass = class(Stack);                                              % Identify the class of the frames within image stack
    CroppedStack = zeros(MaskHeight, MaskWidth, TotalFrames, StackClass);   % Preallocate an array where each frame is the size of the mask and as many frames as the stack

    for i = 1:TotalFrames                                                   % Loop through each frame
        CroppedFrame = imcrop(Stack(:,:,i), BoundingBox);                   % Crop a frame to the bounding box
        CroppedFrame(~CroppedMask) = NaN;                                   % Give all pixels outside of the bounding box a value of NaN. To average these frames, use 'omitNaN'
        CroppedStack(:,:,i) = CroppedFrame;                                 % Create the cropped frame for the cropped stack
    end                                                                     % End
end