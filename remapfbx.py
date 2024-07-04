import re
import pymxs
rt = pymxs.runtime
sourceMesh = rt.execute('sourceMeshName')
filePath = rt.execute('selectedPath')
targetMesh = rt.execute('targetMeshName')


# Define the file paths
target_mesh_path = str(filePath)+'\\targetMesh.fbx'
source_mesh_path = str(filePath)+'\\sourceMesh.fbx'
cfile_path = str(filePath)+'\\Cfile.txt'

# Read the target mesh file
with open(target_mesh_path, 'r') as file:
    target_mesh_content = file.read()

# Extract vertices data using regex
vertices_pattern = re.compile(r"Vertices: \*\d+ \{\s*a: ([\d\.\-\,]+)\s*\}", re.MULTILINE)
vertices_match = vertices_pattern.search(target_mesh_content)

if vertices_match:
    vertices_data = vertices_match.group(1)
    vertices_list = [float(v) for v in vertices_data.split(',')]
    vertices_triplets = [vertices_list[i:i+3] for i in range(0, len(vertices_list), 3)]

# Read the Cfile and create the new order mapping
with open(cfile_path, 'r') as file:
    cfile_lines = file.readlines()

new_order = {}
for line in cfile_lines:
    new, old = line.strip().split(':')
    new_order[int(new)-1] = int(old)-1

# Rearrange the vertices based on the new order
rearranged_vertices = [vertices_triplets[new_order[i]] for i in range(len(vertices_triplets))]

# Convert rearranged vertices to a single string
rearranged_vertices_flat = [str(value) for triplet in rearranged_vertices for value in triplet]
rearranged_vertices_str = ','.join(rearranged_vertices_flat)

# Read the source mesh file
with open(source_mesh_path, 'r') as file:
    source_mesh_content = file.read()

# Replace the vertices section in the source mesh with the rearranged vertices
source_mesh_content = re.sub(vertices_pattern, r"Vertices: *{} {{\n\ta: {}\n}}".format(len(rearranged_vertices_flat), rearranged_vertices_str), source_mesh_content)

# Replace the specified string with the new string
source_mesh_content = source_mesh_content.replace(sourceMesh, targetMesh)


# Write the modified source mesh content back to the file
with open(source_mesh_path, 'w') as file:
    file.write(source_mesh_content)
