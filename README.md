# 3dsMax-Transfer Vertex ID

A transfer vertex ID tool for 3ds Max where the meshes look different and have different UV.

This tool lets user choose three corresponding vertices from Source Mesh to Target Mesh.

<img width="500" alt="image" src="https://github.com/revoconner/3dsMax-TransferVertexID/assets/88772846/bfa41c30-3f7c-45e1-8dcb-aa95e4da681d">


### What this tool can do:

* It transfers vertex ID from one mesh to another with the same vertex numbers.
* It does **not** need the two meshes to share similar form, that means their world space and local space coordinates can be different.
* It does **not** need the two meshes to share same UV info.
* It's the first tool made for 3ds Max that can do this.  (There is only one other that uses world space coordinates or UV to transfer the vertex ID by Changsoo Eun. [https://cganimator.com/mcg-reordervertsbyproximity/](https://cganimator.com/mcg-reordervertsbyproximity/))

### How to use:

1. Install by dragging and dropping the TransferVertexID.mzp file into max viewport. This will create a menu item called RevScript where you can find your tool.
2. You can also run this by downloading all the files and keeping them in the same folder. Then running TransferVertID.ms from the script editor.
3. Once the dialog box is ready, select a temporary folder. This folder is used to store vertex mapping of the two meshes and other things.
4. Reset xform and collapse stack on both the meshes. Make sure they are editable polys.
5. Then select Target mesh and go into vertex sub-object mode. You have to select 3 vertices one at a time, one by one. You must select three neighboring vertices only such that each vertex has at least one immediate neighbor in your selection.
6. Select vertex 1, then press the button 1 -- Select vertex 2, then press the button 2 -- Select vertex 3, then press button 3. [Only select one vertex at a time]
7. You will see the text field getting updated with the vertex ID of your selection.
8. Once done, press the Process Source Mesh. Make sure your source object is selected beforehand, however, it does not matter if it is in object selection mode or sub-object selection mode.
9. Do the same for the Target Mesh. Make sure to select corresponding vertices in order. [Source 1 >> Source 2 >> Source 3 >>Process mesh>> Target 1 >> Target 2 >> Target 3>> Process mesh]
10. Then click the big Transfer Vertex ID button to get the correct mesh.


#### Note

* This is my first maxscript so its a bit clunky.
* This is in alpha state so some faulty results from time to time are expected.
* It uses python to do some operations in the background however as long as max supports pymxs it should, in theory, work.
