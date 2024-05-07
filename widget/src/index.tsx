// @ts-nocheck
import React, {useRef, useEffect} from 'react';
import * as d3 from 'd3';

export default (props : any) => {
  const data =[1,2,3]
  const gx = useRef();
  const gy = useRef();
  const x = d3.scaleLinear([0, data.length - 1], [5, 120 - 5]);
  const y = d3.scaleLinear(d3.extent(data), [120 - 5, 5]);
  const line = d3.line((d, i) => x(i), y);
  useEffect(() => void d3.select(gx.current).call(d3.axisBottom(x)), [gx, x]);
  useEffect(() => void d3.select(gy.current).call(d3.axisLeft(y)), [gy, y]);
  return (
    <svg width={120} height={120}>
      <g ref={gx} transform={`translate(0,${120 - 5})`} />
      <g ref={gy} transform={`translate(${5},0)`} />
      <path fill="none" stroke="currentColor" strokeWidth="1.5" d={line(data)} />
      <g fill="white" stroke="currentColor" strokeWidth="1.5">
        {data.map((d, i) => (<circle key={i} cx={x(i)} cy={y(d)} r="2.5" />))}
      </g>
    </svg>
  )

};