// Reusable Filter Section for Analytics
import React from 'react';

const AnalyticsFilterSection = ({
  filters = [],
  onFilterChange,
  additionalContent = null
}) => {
  return (
    <div className="bg-white p-4 rounded-lg shadow mb-4">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {filters.map((filter, index) => (
          <div key={filter.id || index}>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {filter.label}
            </label>
            <select
              value={filter.value}
              onChange={(e) => onFilterChange(filter.id, e.target.value)}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {filter.options.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
        ))}
        {additionalContent && (
          <div className="md:col-span-3">
            {additionalContent}
          </div>
        )}
      </div>
    </div>
  );
};

export default AnalyticsFilterSection;
