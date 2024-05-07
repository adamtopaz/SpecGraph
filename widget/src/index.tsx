import * as React from 'react';
import { useEffect, useMemo } from 'react';
import { graphviz, GraphvizOptions } from 'd3-graphviz';

interface IGraphvizProps {
  dot: string;
  options?: GraphvizOptions;
  //className?: string;
}

const defaultOptions: GraphvizOptions = {
  fit: true,
  height: 500,
  width: 500,
  zoom: false,
};

// let counter = 0;

// const getId = () => `graphviz${counter++}`;

const Graphviz = ({ dot, options = {} }: IGraphvizProps) => {
  // const id = useMemo(getId, []);
  const [error, setError] = React.useState<string | null>(null)
  useEffect(() => {
    setError(null)
    graphviz(`#coolgraph`, {
      ...defaultOptions,
      ...options,
    }).renderDot(dot).onerror((e) => {
      setError(e)
    });
  }, [dot, options]);
  if (error) {
    return <div id="coolgraph">{error}</div>
  }
  return <div id="coolgraph" />;
};

export default (props : any) => {
  const { dot } = props
  return Graphviz({ dot : dot })
};