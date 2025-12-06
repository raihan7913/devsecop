// Reusable Bar Chart Component for Analytics
import React from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer
} from 'recharts';

const AnalyticsBarChart = ({
  data = [],
  xKey = 'nama_mapel',
  bars = [{ key: 'rata_rata', name: 'Rata-rata', color: '#82ca9d' }],
  height = 400,
  chartRef = null
}) => {
  if (!data || data.length === 0) {
    return (
      <div className="flex items-center justify-center p-8 bg-gray-50 rounded-lg">
        <p className="text-gray-500">No data available to display</p>
      </div>
    );
  }

  return (
    <div ref={chartRef} style={{ width: '100%', height }}>
      <ResponsiveContainer>
        <BarChart
          data={data}
          margin={{ top: 20, right: 30, left: 20, bottom: 70 }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            dataKey={xKey}
            angle={-45}
            textAnchor="end"
            height={100}
            interval={0}
          />
          <YAxis domain={[0, 100]} />
          <Tooltip />
          <Legend wrapperStyle={{ paddingTop: '20px' }} />
          {bars.map((bar, index) => (
            <Bar
              key={bar.key || index}
              dataKey={bar.key}
              fill={bar.color}
              name={bar.name}
              radius={[8, 8, 0, 0]}
            />
          ))}
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

export default AnalyticsBarChart;
