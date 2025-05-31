import yaml
import graphviz

def visualize_citrus_tree(yaml_file, output_file="citrus_tree.png"):
    """
    Reads a YAML file representing a citrus family tree,
    creates a graph visualization using graphviz, and saves it to a file.
    """

    with open(yaml_file, 'r') as f:
        data = yaml.safe_load(f)

    dot = graphviz.Digraph(comment='Citrus Family Tree')

    # Add nodes
    for fruit in data['citrus_family_tree']:
        dot.node(fruit['name'])

    # Add edges
    for fruit in data['citrus_family_tree']:
        if fruit['parents']:
            for parent in fruit['parents']:
                dot.edge(parent, fruit['name'])

    # Save the graph to a file
    dot.render(output_file[:-4], format=output_file[-3:], view=False, cleanup=True)  # Remove extension for render, specify format

if __name__ == "__main__":
    yaml_file_path = "fruit.yml"
    output_file_path = "citrus_tree.png"  # You can change this to other formats like .pdf, .svg etc.
    visualize_citrus_tree(yaml_file_path, output_file_path)
    print(f"Graph visualization saved to {output_file_path}")