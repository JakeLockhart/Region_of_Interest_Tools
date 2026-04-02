classdef ROIIdentifier < ROIManager
    % <Documentation>
        % ROIIdentifier
        %   Created by: jsl5865
        %   
        % Description:
        %   A method to give each drawn ROI an identifying code. The code is
        %   deliminated by '_' and there are three segments:
        %       1) The image stack that the ROI was drawn on
        %       2) The ROI shape (abbreviated to the shapes first letter)
        %       3) The index of that ROI shape
        %   
    % <End Documentation>
    methods(Static, Access = public)
        function ID = MakeID(StackIndex, ROIType, ROIIndex)
            arguments
                StackIndex (1,1) double {mustBeNumeric, mustBeInteger, mustBePositive, mustBeNonzero}
                ROIType (1,1) char {}
                ROIIndex (1,1) double {mustBeNumeric, mustBeInteger, mustBePositive, mustBeNonzero}
            end

            ROIIdentifier.validateROIType(ROIType)
            ID = sprintf("%d_%s_%d", StackIndex, ROIType, ROIIndex);
        end

        function [StackIndex, ROIType, ROIIndex] = ReadID(ID)
            arguments
                ID (1,:) string
            end

            [StackIndex, ROIType, ROIIndex] = ROIIdentifier.decodeIdentifier(ID);
        end

        function ID = UpdateID_Index(ID, NewIndex)
            arguments
                ID (1,1) string
                NewIndex (1,1) double {mustBeNumeric, mustBeInteger, mustBePositive, mustBeNonzero}
            end

            [stack, type, ~] = ROIIdentifier.decodeIdentifier(ID);
            ID = ROIIdentifier.MakeID(stack, type(1), NewIndex);
        end
    end

    methods(Static, Access = private)
        function validateROIType(ROIType)
            shapeInitials = cellfun(@(shape) shape(1), ROIManager.ROI_Shape_List);
            if ~ismember(ROIType, shapeInitials) 
                identifier = "InvalidKey:KeyNotSupportedByROIShapes";
                ME = MException(identifier, 'ROI type does not represent a supported shape in ROIManager');
                throwAsCaller(ME)
            end
        end

        function [segment1, segment2, segment3] = decodeIdentifier(ID)
            Segments = split(ID, '_');
            segment1 = double(Segments(1));

            shapeInitial = cellfun(@(shape) shape(1), ROIManager.ROI_Shape_List, 'UniformOutput', false);
            shapeIndex = find(strcmpi(shapeInitial, Segments(2)), 1);
            segment2 = ROIManager.ROI_Shape_List{shapeIndex};

            segment3 = double(Segments(3));
        end
    end

end