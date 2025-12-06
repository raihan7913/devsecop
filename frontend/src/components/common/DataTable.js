// Reusable Data Table with Actions
import React from 'react';

const DataTable = ({
  data = [],
  columns = [],
  actions = [],
  emptyMessage = 'No data available',
  onRowClick = null
}) => {
  if (!data || data.length === 0) {
    return (
      <div className="flex items-center justify-center p-8 bg-gray-50 rounded-lg border border-gray-200">
        <p className="text-gray-500">{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className="overflow-x-auto shadow-md rounded-lg">
      <table className="min-w-full bg-white">
        <thead className="bg-gradient-to-r from-blue-500 to-blue-600 text-white">
          <tr>
            {columns.map((col, index) => (
              <th
                key={col.key || index}
                className="px-6 py-4 text-left text-sm font-semibold uppercase tracking-wider"
              >
                {col.label}
              </th>
            ))}
            {actions.length > 0 && (
              <th className="px-6 py-4 text-center text-sm font-semibold uppercase tracking-wider">
                Actions
              </th>
            )}
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200">
          {data.map((row, rowIndex) => (
            <tr
              key={row.id || rowIndex}
              onClick={() => onRowClick && onRowClick(row)}
              className={`hover:bg-blue-50 transition-colors ${
                onRowClick ? 'cursor-pointer' : ''
              }`}
            >
              {columns.map((col, colIndex) => (
                <td
                  key={`${rowIndex}-${col.key || colIndex}`}
                  className="px-6 py-4 text-sm text-gray-700"
                >
                  {col.render ? col.render(row) : row[col.key] || '-'}
                </td>
              ))}
              {actions.length > 0 && (
                <td className="px-6 py-4 text-center">
                  <div className="flex items-center justify-center gap-2">
                    {actions.map((action, actionIndex) => (
                      <button
                        key={actionIndex}
                        onClick={(e) => {
                          e.stopPropagation();
                          action.onClick(row);
                        }}
                        className={`px-3 py-1 rounded text-sm font-medium transition-colors ${
                          action.className ||
                          'bg-blue-500 text-white hover:bg-blue-600'
                        }`}
                        title={action.label}
                      >
                        {action.icon || action.label}
                      </button>
                    ))}
                  </div>
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default DataTable;
