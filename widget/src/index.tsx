import * as React from "react";
import { useEffect } from "react";
import * as d3 from 'd3';
import { graphviz, GraphvizOptions } from 'd3-graphviz';
import renderMathInElement from "katex/contrib/auto-render"
// @ts-ignore
import css from 'https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.css'


//import css from 'katex/dist/katex.min.css'

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
  docstring : string | null;
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
    out += `  ${e.id} [label=\"${e.name}\", id=${e.id}];\n`
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
              if (node.docstring) {
                nodeInfo.append("div").text(`${node.docstring}`).each(function() {
                  const docNoe = d3.select(this);
                  renderMathInElement(this, {
                    delimiters: [
                      { left: '$$', right: '$$', display: true },
                      { left: '$', right: '$', display: false },
                      { left: '\\(', right: '\\)', display: false },
                      { left: '\\[', right: '\\]', display: true }
                    ],
                    throwOnError: false
                  });
                });
              }
            };
          });
        });

        // Click handler for anywhere outside the graph.
        d3.select("#graph").on("click", () => {
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

export default (graph : Graph) => {
  document.adoptedStyleSheets = [css];
  return mkGraph(graph)
};