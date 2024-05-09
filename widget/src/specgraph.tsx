import { useEffect, useRef } from "react";
import * as d3 from 'd3';
import { graphviz } from 'd3-graphviz';
import { createRoot } from 'react-dom/client'
import rehypeKatex from 'rehype-katex'
import remarkMath from 'remark-math'
import Markdown from 'react-markdown';
import css from 'katex/dist/katex.min.css';

interface Node {
  id : string;
  name : string;
  type : string;
  docstring : string | null;
}

interface Graph {
  nodes : Array<Node>
  dot : string
}

function mkGraph({nodes, dot} : Graph) {
  const nodeMap = new Map(nodes.map(node => [node.id, node]))
  const graphRef = useRef<HTMLDivElement>(null);
  const infoRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    graphviz(graphRef.current)
      .renderDot(dot)
      .on("end", () => {
        d3.selectAll<SVGAElement, unknown>(".node").each(function () {
          const gNode = d3.select(this);

          gNode.attr("pointer-events", "fill");

          gNode.on("click", function(event) {
            event.stopPropagation();
            const nodeId = d3.select(this).attr("id");
            const node = nodeMap.get(nodeId);
            const nodeInfo = d3.select(infoRef.current);

            if (node) {
              nodeInfo.html('');
              const typeDiv = nodeInfo.append("div").node();
              if (typeDiv) {
                const typeRoot = createRoot(typeDiv);
                typeRoot.render(
                  <Markdown>
                    {`${node.name} : ${node.type}`}
                  </Markdown>
                )
              };
              if (node.docstring) {
                const docDiv = nodeInfo.append('div').node();
                if (docDiv) {
                  const docRoot = createRoot(docDiv);
                  docRoot.render(
                    // @ts-ignore
                    <Markdown remarkPlugins={[remarkMath]} rehypePlugins={[rehypeKatex]}>
                      {node.docstring}
                    </Markdown>
                  );
                }
              }
            };

          });
        });

        d3.select(graphRef.current)
          .on("click", () => {
            const nodeInfo = d3.select(infoRef.current);
            nodeInfo.html('');
            //nodeInfo.text("Node information will appear here.");
          });
      });
  }, [nodes, dot]);

  return (
    <div>
      <div ref={graphRef} />
      <div ref={infoRef} />
    </div>
  );
}

const styleSheet = new CSSStyleSheet()
styleSheet.replace(css);

export default (graph : Graph) => {
  document.adoptedStyleSheets = [styleSheet];
  return mkGraph(graph)
};