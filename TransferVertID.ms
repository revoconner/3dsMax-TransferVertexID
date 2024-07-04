/* Alpha version - tested only on limited numbers of meshes
Tested in Max 2019, 2021, however the script should in theory work in any version.

Thanks to DaveWortley for creating a rollout tool that helped make this UI pretty.
*/


try (destroyDialog VertID) catch()
global selectedPath = ""
global sourceMeshName = ""
global targetMeshName = ""
global sourceProcessed = false
global targetProcessed = false

fn bfs_vertex_mapping mesh =
(
    local numVerts = polyOp.getNumVerts mesh
    local adjacencyList = for i = 1 to numVerts collect #()
    
    for vert = 1 to numVerts do
    (
        local connectedEdges = polyOp.getEdgesUsingVert mesh vert
        for edge in connectedEdges do
        (
            local adjacentVerts = polyOp.getVertsUsingEdge mesh edge
            for adjVert in adjacentVerts do
            (
                if adjVert != vert do
                (
                    append adjacencyList[vert] adjVert
                )
            )
        )
    )
    adjacencyList
)

fn write_mapping_to_file mapping filepath =
(
    local file = createFile filepath
    if file == undefined then
    (
        format "Failed to create file: %\n" filepath
        return false
    )
    for vert = 1 to mapping.count do
    (
        local adjVerts = mapping[vert]
        local adjVertStrings = ""
        for v in adjVerts do
        (
            adjVertStrings += v as string + ", "
        )
        -- Remove trailing comma and space
        if adjVertStrings != "" do adjVertStrings = substring adjVertStrings 1 (adjVertStrings.count - 2)
        local line = vert as string + ": " + adjVertStrings + "\n"
        format  line to:file
    )
    close file
    return true
)

fn save_vertex_mapping filepath sourceVerts targetVerts =
(
    local file = createFile filepath
    if file == undefined then
    (
        format "Failed to create file: %\n" filepath
        return false
    )
    for i = 1 to sourceVerts.count do
    (
        format "%:%\n" sourceVerts[i] targetVerts[i] to:file
    )
    close file
    return true
)
/* 
Entire reason to do this with fbx which is way more complex than OBJ is because max decided that
#noPrompt should still prompt while exporting OBJ,
even with manually setting the objexporter ini files. 
I miss coding in maya :'(
*/
--fbx EXPORT settings
fn export_fbx meshName filepath =
(
    FBXExporterSetParam "ASCII" true
    FBXExporterSetParam "Animation" false
    FBXExporterSetParam "ColladaTriangulate" false
    FBXExporterSetParam "ColladaSingleMatrix" false
    FBXExporterSetParam "EmbedTextures" false
    FBXExporterSetParam "GenerateLog" false
    FBXExporterSetParam "NormalsPerPoly" false
    FBXExporterSetParam "Preserveinstances" true
    FBXExporterSetParam "Shape" false
    FBXExporterSetParam "Skin" false
    FBXExporterSetParam "ShowWarnings" false
    FBXExporterSetParam "SmoothingGroups" false
    FBXExporterSetParam "SmoothMeshExport" false
    FBXExporterSetParam "Triangulate" false
    FBXExporterSetParam "UpAxis" "Y"    
    exportFile filepath #noPrompt selectedOnly:true using:FBXEXP
)

--fbx IMPORT settings
fn import_fbx filepath =
(
    FBXImporterSetParam "Animation" false
    FBXImporterSetParam "GenerateLog" false
    FBXImporterSetParam "Shape" false
    FBXImporterSetParam "Skin" false
    FBXImporterSetParam "SmoothingGroups" false
    importFile filepath #noPrompt using:FBXIMP
)


rollout VertID "Transfer Vertex ID" width:500 height:700
(
    group "Path" (
        label lbl_1 "Select a temporary folder" align:#left visible:true style_sunkenedge:false
        edittext edt_1 "" width:410 height:25 enabled:true visible:true labelOnTop:false text:"" readOnly:true
        button pathButton "..." offset:[0,-32] width:50 height:28 align:#right visible:true border:true
        label lbl_3 "" height:25 align:#center visible:false
        on pathButton pressed do (
            local folderPath = getSavePath()
            if folderPath != undefined do (
                edt_1.text = folderPath
                selectedPath = folderPath -- Assign the selected path to the global variable
            )
        )
    )

    group "SOURCE MESH" (
        label lbl_2 "Select mesh, select 1 vertex, press 1, select adjoining vertex press 2... then press process button." align:#left visible:true
        edittext sourceVert1 "" width:50 height:25 align:#left text:"" readOnly:true
        edittext sourceVert2 "" offset:[50,-30] width:50 height:25 align:#left text:"" readOnly:true
        edittext sourceVert3 "" offset:[100,-30] width:50 height:25 align:#left text:"" readOnly:true
        button btn_sourceVert1 "1" offset:[180,-30] width:25 align:#left
        button btn_sourceVert2 "2" offset:[220,-26] width:25 align:#left
        button btn_sourceVert3 "3" offset:[260,-26] width:25 align:#left
        button sourceButton "Process Source Mesh" offset:[0,7] width:152 align:#left border:true
        label lbl_4 "" height:30 visible:false
		-- Repeat with me bitarrays suck ass!!
        on btn_sourceVert1 pressed do (
            local verts = getVertSelection $ as array
            if verts.count > 0 then sourceVert1.text = verts[verts.count] as string
            else messageBox "Please select a vertex"
        )

        on btn_sourceVert2 pressed do (
            local verts = getVertSelection $ as array
            if verts.count > 0 then sourceVert2.text = verts[verts.count] as string
            else messageBox "Please select a vertex"
        )

        on btn_sourceVert3 pressed do (
            local verts = getVertSelection $ as array
            if verts.count > 0 then sourceVert3.text = verts[verts.count] as string
            else messageBox "Please select a vertex"
        )

        on sourceButton pressed do (
            if selectedPath == "" then (
                messageBox "Please select a temporary folder first."
                return()
            )

            local selectedObj = selection[1]
            if isKindOf selectedObj Editable_Poly or isKindOf selectedObj Editable_Mesh then (
                if sourceVert1.text != "" and sourceVert2.text != "" and sourceVert3.text != "" then (
                    sourceMeshName = selectedObj.name -- Assign the source mesh name to the global variable
                    local vertexMapping = bfs_vertex_mapping selectedObj
                    local result = write_mapping_to_file vertexMapping (selectedPath + "\\sourceN.txt")
                    if result then
                    (
                        print "Vertex mapping written to " + selectedPath + "\\sourceN.txt"
                    )
                    else
                    (
                        print "Failed to write vertex mapping to file."
                    )
                    sourceProcessed = true
                )
                else (
                    messageBox "Please select three vertices in order"
                )
            )
            else (
                messageBox "Please select an Editable Poly or Editable Mesh"
            )
        )
    )

    group "TARGET MESH" (
        label lbl_5 "Select mesh, select 1 vertex, press 1, select adjoining vertex press 2... then press process button." align:#left
        edittext targetVert1 "" width:50 height:25 align:#left text:"" readOnly:true
        edittext targetVert2 "" offset:[50,-30] width:50 height:25 align:#left text:"" readOnly:true
        edittext targetVert3 "" offset:[100,-30] width:50 height:25 align:#left text:"" readOnly:true
        button btn_targetVert1 "1" offset:[180,-30] width:25 align:#left
        button btn_targetVert2 "2" offset:[220,-26] width:25 align:#left
        button btn_targetVert3 "3" offset:[260,-26] width:25 align:#left
        button targetButton "Process Target Mesh" offset:[0,8] width:152 align:#left
        label lbl_6 "" height:30 visible:false

        on btn_targetVert1 pressed do (
            local verts = getVertSelection $ as array
            if verts.count > 0 then targetVert1.text = verts[verts.count] as string
            else messageBox "Please select a vertex"
        )

        on btn_targetVert2 pressed do (
            local verts = getVertSelection $ as array
            if verts.count > 0 then targetVert2.text = verts[verts.count] as string
            else messageBox "Please select a vertex"
        )

        on btn_targetVert3 pressed do (
            local verts = getVertSelection $ as array
            if verts.count > 0 then targetVert3.text = verts[verts.count] as string
            else messageBox "Please select a vertex"
        )

        on targetButton pressed do (
            if selectedPath == "" then (
                messageBox "Please select a temporary folder first."
                return()
            )

            local selectedObj = selection[1]
            if isKindOf selectedObj Editable_Poly or isKindOf selectedObj Editable_Mesh then (
                if targetVert1.text != "" and targetVert2.text != "" and targetVert3.text != "" then (
                    targetMeshName = selectedObj.name -- Assign the target mesh name to the global variable
                    local vertexMapping = bfs_vertex_mapping selectedObj
                    local result = write_mapping_to_file vertexMapping (selectedPath + "\\targetN.txt")
                    if result then
                    (
                        print "Vertex mapping written to " + selectedPath + "\\targetN.txt"
                    )
                    else
                    (
                        print "Failed to write vertex mapping to file."
                    )
                    targetProcessed = true
                )
                else (
                    messageBox "Please select three vertices in order"
                )
            )
            else (
                messageBox "Please select an Editable Poly or Editable Mesh"
            )
        )
    )

    group "Process" (
        button processButton "Transfer Vertex ID" width:375.0 usePercentageWidth:true percentageWidth:75.0 height:30 align:#center
        label lbl_7 "" height:30 visible:false
        on processButton pressed do (
            if not sourceProcessed or not targetProcessed then (
                messageBox "Please process your meshes first."
                return()
            )
            if selectedPath == "" then (
                messageBox "Please select a temporary folder first."
                return()
            )

            local sourceVerts = #(sourceVert1.text, sourceVert2.text, sourceVert3.text)
            local targetVerts = #(targetVert1.text, targetVert2.text, targetVert3.text)
            local result = save_vertex_mapping (selectedPath + "\\mapping.txt") sourceVerts targetVerts
            if result then
            (
                print "Vertex ID mapping written to " + selectedPath + "\\mapping.txt"
            )
            else
            (
                print "Failed to write vertex ID mapping to file."
            )

            -- Fucking nightmare this one, fuck you max!!!
			clearSelection()
			select (getNodeByName sourceMeshName)
            export_fbx sourceMeshName (selectedPath + "\\sourceMesh.fbx")
			clearSelection()
			select (getNodeByName targetMeshName)
            export_fbx targetMeshName (selectedPath + "\\targetMesh.fbx")
			clearSelection()
			
			-- mapping entire mesh from 3 known points
            try (
                -- Get the directory of the current MaxScript file
                scriptDir = getFilenamePath (getSourceFileName())
                pythonScriptName = "map.py"

                -- Combine the directory with the script name to get the full path
                pythonScriptPath = scriptDir + pythonScriptName

                -- Check if the file exists before executing it
                if doesFileExist pythonScriptPath then (
                    python.ExecuteFile pythonScriptPath
                ) else (
                    format "File does not exist: %\n" pythonScriptPath
                )
            ) catch (
                format "Error occurred: %\n" (getCurrentException())
            )
			--sleep in between is only because I do not trust computers, feel free to remove it.
			sleep 2.5

			try (
                -- Get the directory of the current MaxScript file
                scriptDir = getFilenamePath (getSourceFileName())
                pythonScriptName = "remapfbx.py"

                -- Combine the directory with the script name to get the full path
                pythonScriptPath = scriptDir + pythonScriptName

                -- Check if the file exists before executing it
                if doesFileExist pythonScriptPath then (
                    python.ExecuteFile pythonScriptPath
                ) else (
                    format "File does not exist: %\n" pythonScriptPath
                )
            ) catch (
                format "Error occurred: %\n" (getCurrentException())
            )
			sleep 1
			
			
			try (
                -- Get the directory of the current MaxScript file
                scriptDir = getFilenamePath (getSourceFileName())
                pythonScriptName = "transform.py"

                -- Combine the directory with the script name to get the full path
                pythonScriptPath = scriptDir + pythonScriptName

                -- Check if the file exists before executing it
                if doesFileExist pythonScriptPath then (
                    python.ExecuteFile pythonScriptPath
                ) else (
                    format "File does not exist: %\n" pythonScriptPath
                )
            ) catch (
                format "Error occurred: %\n" (getCurrentException())
            )
			sleep 1
			
			-- deleting old bad mesh
			delete (getNodeByName targetMeshName)
			--importing the modified fbx with the right vertex order
			import_fbx (selectedPath + "\\sourceMesh.fbx")
			clearSelection()
			
			
			/* MY BAD DO NOT NEED TO MORPH RIGHT NOW (needed due to improper export settings)
			--Morph Target and collapse
			-- Get the object by the global variable name
			local originalBox = getNodeByName sourceMeshName
			-- Clone the object as a copy and name it tempMesh2392347
			local clonedObj = copy originalBox
			clonedObj.name = "tempMesh2392347"
			-- Select the cloned object
			select clonedObj
			-- Add the Morpher modifier to the cloned object
			addModifier clonedObj (morpher())
			WM3_MC_BuildFromNode clonedObj.morpher 1 $NameCHvert98566
			WM3_MC_SetValue clonedObj.morpher 1 100.0
			collapseStack clonedObj 
			*/
			
			--cleanup the temp folder contents
			try(
				dosCommand ("del /q \"" + selectedPath + "\\*.*\" & for /d %d in (\"" + selectedPath + "\\*\") do rmdir /s /q \"%d\"")
				)
			catch (
				format "Error occurred: %\n" (getCurrentException())
				)
        )
    )

    group "Info" (
        label lbl_9 "1. Always reset xform and collapse stack BEFORE using the script." align:#left
        label lbl_8 "2. You will likely lose smoothing groups" align:#left style_sunkenedge:false
        label lbl_10 "3. You will likely lose all material attributes, including material IDs." align:#left
        label lbl_11 "4. You will lose your UVs if the TARGET mesh has the correct UV." align:#left
        label lbl_12 "5. Only select neighboring vertices and after each vertex selection, press the respective button" align:#left
        label lbl_13 "6. When clicking on process xxxx mesh button, make sure you have the mesh selected" align:#left
        label lbl_14 "7. May not work with meshes that have floating geometry." align:#left
		label lbl_15 "V: 0.1.a" align:#center
        HyperLink hyp_1 "Made by Rév" offset:[0,30] align:#center visible:true address:@"https://www.revoconner.com" hoverColor:(color 0 182 255) visitedColor:(color 255 255 255)
    )
)

createDialog VertID
