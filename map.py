import pymxs
rt = pymxs.runtime
filePath = rt.execute('selectedPath')

def read_network(file_path):
    network = {}
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.strip().split(':')
            node = int(parts[0].strip())
            neighbors = list(map(int, parts[1].strip().split(',')))
            network[node] = neighbors
    return network

def read_mappings(file_path):
    mappings = []
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.strip().split(':')
            nodeA = int(parts[0].strip())
            nodeB = int(parts[1].strip())
            mappings.append((nodeA, nodeB))
    return mappings

def is_valid_mapping(AtoB, BtoA, networkA, networkB, nodeA, nodeB):
    for neighborA in networkA[nodeA]:
        if neighborA in AtoB:
            correspondingB = AtoB[neighborA]
            if correspondingB not in networkB[nodeB]:
                return False
    return True

def backtrack(AtoB, BtoA, visitedA, visitedB, networkA, networkB, nodesA, nodesB):
    if len(AtoB) == len(nodesA):
        return True

    for nodeA in nodesA:
        if nodeA not in visitedA:
            for nodeB in nodesB:
                if nodeB not in visitedB:
                    if is_valid_mapping(AtoB, BtoA, networkA, networkB, nodeA, nodeB):
                        AtoB[nodeA] = nodeB
                        BtoA[nodeB] = nodeA
                        visitedA.add(nodeA)
                        visitedB.add(nodeB)

                        if backtrack(AtoB, BtoA, visitedA, visitedB, networkA, networkB, nodesA, nodesB):
                            return True

                        del AtoB[nodeA]
                        del BtoA[nodeB]
                        visitedA.remove(nodeA)
                        visitedB.remove(nodeB)
    return False

def map_networks(networkA, networkB, known_nodes):
    AtoB = {nodeA: nodeB for nodeA, nodeB in known_nodes}
    BtoA = {nodeB: nodeA for nodeA, nodeB in known_nodes}
    visitedA = set(AtoB.keys())
    visitedB = set(BtoA.keys())
    nodesA = list(networkA.keys())
    nodesB = list(networkB.keys())

    if backtrack(AtoB, BtoA, visitedA, visitedB, networkA, networkB, nodesA, nodesB):
        return AtoB
    else:
        return None

# Define file names
mapping_path = str(filePath)+'\\mapping.txt'
networkA_path = str(filePath)+ '\\sourceN.txt'
networkB_path = str(filePath)+ '\\targetN.txt'
output_file = str(filePath)+ '\\Cfile.txt'

# Read the networks and mappings
networkA = read_network(networkA_path)
networkB = read_network(networkB_path)
known_nodes = read_mappings(mapping_path)

# Map the networks
result = map_networks(networkA, networkB, known_nodes)

# Print the result
# if result:
#     print("Final mapping:")
#     for nodeA, nodeB in sorted(result.items()):
#         print(f"{nodeA} -> {nodeB}")
# else:
#     print("No valid mapping found")


# Write results to output file
with open(output_file, 'w') as f:
    for nodeA, nodeB in sorted(result.items()):
        f.write("%d:%d\n" % (nodeA, nodeB))