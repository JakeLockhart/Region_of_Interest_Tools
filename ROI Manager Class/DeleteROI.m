classdef DeleteROI
    properties
        ROIManagerObj
    end

    methods
        function obj = DeleteROI(ROIManagerObj)
            obj.ROIManagerObj = ROIManagerObj;
        end
    end

    methods(Access = public)
        function delete(obj, ID)
            arguments
                obj
                ID string {mustBeVector}
            end
            
            obj.validateIDs(ID)
            obj.deleteMultipleIDs(ID)
        end
    end

    methods(Access = private)
        function validateIDs(obj, IDs)
            totalStacks = numel(obj.ROIManagerObj.Properties);
            invalidIdentifier = "InvalidEntry:InvalidROIID";
            ME = "";

            for idIndex = 1:numel(IDs)
                ID = IDs(idIndex);
                [stack, type, index] = ROIIdentifier.ReadID(ID);
                if isempty(stack) || isempty(type) || isempty(index)
                    ME = sprintf('One or more of the identifier elements is missing.');
                    break
                end

                if stack ~= floor(stack) || stack < 1 || stack > totalStacks
                    ME = sprintf('Stack index (%d) is invalid', stack);
                    break
                end

                roiProperties = obj.ROIManagerObj.Properties{stack};
                if ~isprop(roiProperties, type)
                    ME = sprintf('ROI property (%s) is invalid', type);
                    break
                end

                totalROIs = numel(roiProperties.(type));
                if index ~= floor(index) || index < 1 || index > totalROIs
                    ME = sprintf('ROI index (%d) is invalid', index);
                    break
                end
            end

            if ME ~= ""
                errorMessage = MException(invalidIdentifier, ME);
                throwAsCaller(errorMessage)
            end
        end

        function removeMask(obj, ImageIndex, ROIIndex)
            obj.ROIManagerObj.ROIMask{ImageIndex}(ROIIndex) = [];
            if isempty(obj.ROIManagerObj.ROIMask{ImageIndex})
                obj.ROIManagerObj.ROIMask{ImageIndex} = [];
            end
        end

        function removeProperty(obj, ImageIndex, Shape, ROIIndex)
            obj.ROIManagerObj.Properties{ImageIndex}.(Shape)(ROIIndex) = [];
            if isempty(obj.ROIManagerObj.Properties{ImageIndex})
                obj.ROIManagerObj.Properties(ImageIndex) = [];
            end
        end

        function updateIdentifiers(obj, ImageIndex)
            roiProperty = obj.ROIManagerObj.Properties{ImageIndex};

            for i = 1:numel(obj.ROIManagerObj.ROI_Shape_List)
                ROIType = obj.ROIManagerObj.ROI_Shape_List{i};
                if isprop(roiProperty, ROIType)
                    roiCells = roiProperty.(ROIType);
                    for newIndex = 1:numel(roiCells)
                        oldID = roiCells{newIndex}.ID;
                        roiCells{newIndex}.ID = ROIIdentifier.UpdateID_Index(oldID, newIndex);
                    end
                    roiProperty.(ROIType) = roiCells;
                end
            end
            obj.ROIManagerObj.Properties{ImageIndex} = roiProperty;
        end

        function removeEmptyPropertyFields(obj, ImageStack)
            roiProperties = obj.ROIManagerObj.Properties{ImageStack};
            roiTypes = properties(roiProperties);
            for field = 1:numel(roiTypes)
                roiType = roiTypes{field};
                if isempty(roiProperties.(roiType))
                    emptyField = findprop(roiProperties, roiType);
                    delete(emptyField)
                end
            end
        end

        function deleteMultipleIDs(obj, IDs)
            [StackIndex, ROIType, ROIIndex] = ROIIdentifier.ReadIDs(IDs);
            info = table(StackIndex(:), ROIType(:), ROIIndex(:), ...
                            'VariableNames', {'StackIndex', 'ROIType', 'ROIIndex'});
            [groups, keys] = findgroups(info(:, {'StackIndex', 'ROIType'}));

            for group = 1:max(groups)
                rows = (groups == group);

                stack = keys.StackIndex(group);
                type = keys.ROIType(group);
                indices = info.ROIIndex(rows);

                indices = sort(indices, 'descend');

                for roi = 1:numel(indices)
                    index = indices(roi);

                    obj.removeMask(stack, index);
                    obj.removeProperty(stack, type, index);
                end
            end

            for stack = unique(info.StackIndex).'
                obj.removeEmptyPropertyFields(stack);
                obj.updateIdentifiers(stack);
            end
        end
    end
end

