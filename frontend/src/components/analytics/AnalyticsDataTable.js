// Reusable Analytics Data Table
import React from 'react';

const AnalyticsDataTable = ({
  data = [],
  columns = [],
  emptyMessage = 'No data available'
}) => {
  if (!data || data.length === 0) {
    return (
      <div className="flex items-center justify-center p-8 bg-gray-50 rounded-lg">
        <p className="text-gray-500">{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full bg-white border border-gray-200">
        <thead className="bg-gray-100">
          <tr>
            {columns.map((col, index) => (
              <th
                key={col.key || index}
                className="px-4 py-3 text-left text-sm font-semibold text-gray-700 border-b"
              >
                {col.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, rowIndex) => (
            <tr
              key={row.id || rowIndex}
              className="hover:bg-gray-50 transition-colors"
            >
              {columns.map((col, colIndex) => (
                <td
                  key={`${rowIndex}-${col.key || colIndex}`}
                  className="px-4 py-3 text-sm text-gray-700 border-b"
                >
                  {col.render ? col.render(row) : row[col.key] || '-'}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default AnalyticsDataTable;
