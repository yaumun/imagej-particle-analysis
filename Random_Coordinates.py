# python rand_points.py  makePolygon(2528,552,2172,672,1960,832,1944,1056,1848,1396,1596,1884,1216,2332,1048,2616,712,2952,768,3000,1072,2976,1680,2948,2212,2952,2476,2916,2712,2720,2916,2192,2944,1716,2852,1032);

#######################################
# Parameters:
NUMBER_OF_POINTS = 5 # 5 random coordinates to select
BOX_SIZE = 500 # Number of pixels from centre of square (e.g. 500 = 1000 x 1000)
COORDINATES = input("Enter makePolygon coordinates: ")

#######################################
# read node list 
import sys 

nodes=[]

node_line=COORDINATES.replace("makePolygon","").replace("(","").replace(")","").replace(";","")
cols=node_line.split(',')
for i in range(0,len(cols),2):
    node=(float(cols[i]),float(cols[i+1]))
    nodes.append( node )
nodes.append(nodes[0])

x_list=[]
y_list=[]
for node in nodes:
    x_list.append(node[0])
    y_list.append(node[1])
MAX_WIDTH  = max(x_list)
MAX_HEIGHT = max(y_list)


# add more nodes so the selected points are not too close to the border
import math 
edge_nodes=nodes

while True:
    max_border_length =0
    for i in range(len(edge_nodes)-1):
        border_len =  (edge_nodes[i][0] - edge_nodes[i+1][0])**2 \
                     +(edge_nodes[i][1] - edge_nodes[i+1][1])**2
        border_len = math.sqrt(border_len)
        
        if border_len > max_border_length:
            max_border_length = border_len
    
    if max_border_length < BOX_SIZE * 0.20:
        break
    
    new_edge_nodes=[]
    for i in range(len(edge_nodes)-1):
        new_edge_nodes.append(edge_nodes[i])
        border_len =  (edge_nodes[i][0] - edge_nodes[i+1][0])**2 \
                     +(edge_nodes[i][1] - edge_nodes[i+1][1])**2
        border_len = math.sqrt(border_len)
        
        if border_len < BOX_SIZE * 0.20:
            continue 
        
        middle_node= ( (edge_nodes[i][0]+edge_nodes[i+1][0]) * 0.5, \
                       (edge_nodes[i][1]+edge_nodes[i+1][1]) * 0.5 )
        new_edge_nodes.append(middle_node)
    
    new_edge_nodes.append(edge_nodes[-1])
    
    edge_nodes=new_edge_nodes

# print 'done edge_nodes', len(edge_nodes) , max_border_length

#######################################
# generate the point coordinates
import random
points=[]
while len(points) < NUMBER_OF_POINTS:
    cor_x=random.randrange(0,MAX_WIDTH)
    cor_y=random.randrange(0,MAX_HEIGHT)
    
    # the points should not be too close to each other
    is_overlapping=False
    for point in points:
        if     cor_x > point[0]-BOX_SIZE*2 and cor_x < point[0]+BOX_SIZE*2 \
           and cor_y > point[1]-BOX_SIZE*2 and cor_y < point[1]+BOX_SIZE*2 :
           is_overlapping=True
           break
				# centre of squares must be 2*500 px apart in x and y axis
	
    if is_overlapping:
        continue 
    
    # the points should not be too close to the border
    for node in edge_nodes:
        if     cor_x > node[0]-BOX_SIZE and cor_x < node[0]+BOX_SIZE \
           and cor_y > node[1]-BOX_SIZE and cor_y < node[1]+BOX_SIZE :
           is_overlapping=True
           break;
				# centre of squares must be 500 px apart from border in x and y axis
	
    if is_overlapping:
        continue 
    
    # the points should fall into the area
    is_oddNodes=False
    for i in range(len(nodes)-1):
        if ( nodes[i][1] < cor_y and nodes[i+1][1] >= cor_y ) or \
           ( nodes[i][1] >=cor_y and nodes[i+1][1] <  cor_y) :
           t_ratio = (cor_y - nodes[i][1]) / (nodes[i+1][1]-nodes[i][1])
           
           if nodes[i][0] + (nodes[i+1][0]-nodes[i][0])* t_ratio < cor_x:
                is_oddNodes = not is_oddNodes
    
    if not is_oddNodes:
        continue
    
    points.append( (cor_x,cor_y))

#######################################
# print the coordinates
for point in points:
    print(point[0],point[1])

input("Highlight coordinates and press Enter to add to clipboard. Press Enter again to close window.")