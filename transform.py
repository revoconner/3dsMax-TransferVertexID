
import re
import pymxs
rt = pymxs.runtime
filePath = rt.execute('selectedPath')
# Function to find the line number of a match
def find_line_number(content, position):
    return content.count('\n', 0, position) + 1

# Step 1: Read the contents of sourceMesh.fbx and targetMesh.fbx
with open(str(filePath)+'\\sourceMesh.fbx', 'r') as fileA:
    contentA = fileA.read()

with open(str(filePath)+'\\targetMesh.fbx', 'r') as fileB:
    contentB = fileB.read()

# Step 2: Find the "Objects: {" in sourceMesh.fbx
objects_pattern = re.compile(r'\nObjects:\s*{')
objects_match = objects_pattern.search(contentA)
if not objects_match:
    exit()

start_index_objects = objects_match.end()

# Step 3: Find the "Model: " in sourceMesh.fbx after "Objects: {"
model_pattern = re.compile(r'Model:\s')
model_match = model_pattern.search(contentA, start_index_objects)
if not model_match:
    exit()

start_index_model = model_match.end()

# Step 4: Find the "Properties70: {" in sourceMesh.fbx after "Model: "
properties_pattern = re.compile(r'Properties70:\s*{')
properties_match = properties_pattern.search(contentA, start_index_model)
if not properties_match:
    exit()

start_index_properties = properties_match.end()

# Step 5: Extract nested content from targetMesh.fbx
objects_match_B = objects_pattern.search(contentB)
if not objects_match_B:
    exit()

start_index_objects_B = objects_match_B.end()
model_match_B = model_pattern.search(contentB, start_index_objects_B)
if not model_match_B:
    exit()

start_index_model_B = model_match_B.end()
properties_match_B = properties_pattern.search(contentB, start_index_model_B)
if not properties_match_B:
    exit()

start_index_properties_B = properties_match_B.end()
end_index_properties_B = contentB.find('}', start_index_properties_B)
if end_index_properties_B == -1:
    exit()

properties_content_B = contentB[start_index_properties_B:end_index_properties_B + 1]

# Step 6: Replace the content in sourceMesh.fbx from "Properties70: {" till the first "}"
end_index_properties_A = contentA.find('}', start_index_properties)
if end_index_properties_A == -1:
    exit()

new_contentA = contentA[:start_index_properties] + properties_content_B + contentA[end_index_properties_A + 1:]

# Step 7: Write the modified content back to sourceMesh.fbx
with open(str(filePath)+'\\sourceMesh.fbx', 'w') as fileA:
    fileA.write(new_contentA)
