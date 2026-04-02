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
            [ImageIndex, ROIType, ROIIndex] = ROIIdentifier.ReadID(ID);
            obj.removeMask(ImageIndex, ROIIndex);
            obj.removeProperty(ImageIndex, ROIType, ROIIndex);
            obj.updateIdentifiers(ImageIndex);
        end
    end

    methods(Access = private)
        function removeMask(obj, ImageIndex, ROIIndex)
            obj.ROIManagerObj.ROIMask{ImageIndex}(ROIIndex) = [];
            if isempty(obj.ROIManagerObj.ROIMask{ImageIndex})
                obj.ROIManagerObj.ROIMask(ImageIndex) = [];
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
    end

end

