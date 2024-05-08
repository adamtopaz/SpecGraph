import * as React from "react";
import ReactDOM from "react-dom";
import { useEffect } from "react";
import * as d3 from 'd3';
import { graphviz, GraphvizOptions } from 'd3-graphviz';
import katex from "katex";
import renderMathInElement, { RenderMathInElementOptions } from "katex/contrib/auto-render"

const defaultOptions: GraphvizOptions = {
  fit: true,
  height: 500,
  width: 500,
  zoom: false,
};

interface Node {
  id : string;
  name : string;
  type : string;
  docstring : string;
}

interface Edge {
  source : string
  target : string
}

interface Graph {
  nodes : Array<Node>
  edges : Array<Edge>
}

function mkDot({nodes, edges} : Graph) : string {
  var out = "digraph {\n"
  nodes.forEach((e) => 
    out += `  ${e.id} [label=\"${e.name}\", id=\"${e.id}\"];\n`
  );
  edges.forEach((e) => 
    out += `  ${e.source} -> ${e.target};\n`
  );
  return out + "\n}"
}

function KatexComponent({ text }: { text: string }) {
  const containerRef = React.useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (containerRef.current) {
      // Directly set the innerHTML
      containerRef.current.innerHTML = text;
      // Render math within the element
      renderMathInElement(containerRef.current, {
        delimiters: [
          { left: '$$', right: '$$', display: true },
          { left: '$', right: '$', display: false },
          { left: '\\(', right: '\\)', display: false },
          { left: '\\[', right: '\\]', display: true }
        ],
        throwOnError: false
      });
    }
  }, [text]);

  return <div ref={containerRef} />;
}

function mkGraph({nodes, edges} : Graph) {
  const nodeMap = new Map(nodes.map(node => [node.id, node]))

  useEffect(() => {
    graphviz("#graph", { ...defaultOptions, zoom : true })
      .renderDot(mkDot({nodes, edges}))
      .on("end", () => {
        d3.selectAll<SVGAElement, unknown>("#graph g.node").each(function() {
          const gNode = d3.select(this);

          // Set it up so that clicking anywhere in the node works.
          gNode.attr("pointer-events","fill");

          // Add click handler.
          gNode.on("click", function(event) {
            event.stopPropagation();
            const nodeId = d3.select(this).attr("id");
            const node = nodeMap.get(nodeId);
            const nodeInfo = d3.select("#node-info")
            if (node) {
              nodeInfo.html('');
              nodeInfo.append("div").text(`${node.name} : ${node.type}`);
              //const docstringDiv = nodeInfo.append("div").node() as HTMLDivElement;
              //const root = ReactDOM.createRoot(docstringDiv);
              //root.render(<KatexComponent text={node.docstring} />);
            };
          });
        });

        // Click handler for anywhere outside the graph.
        d3.select(document).on("click", () => {
          const nodeInfo = d3.select("#node-info")
          nodeInfo.html('');
          nodeInfo.text("Node information will appear here.");
        });
      });
  }, [nodes, edges]);
  return (
    <div className="App">
      <div id="graph"></div>
      <div id="node-info">Node information will appear here.</div>
    </div>
  );
}

const nodes : Array<Node> = [
  { id : "idA", name : "A", type : "tpA", docstring : "A is $A + B = C$" },
  { id : "idB", name : "B", type : "tpB", docstring : "B" },
  { id : "idC", name : "C", type : "tpC", docstring : "C" },
]

const edges : Array<Edge> = [
  { source : "idA", target : "idB" },
  { source : "idC", target : "idB" },
]

export default (graph : Graph) => {
  return mkGraph(graph)
};