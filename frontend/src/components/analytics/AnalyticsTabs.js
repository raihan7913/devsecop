// Reusable Analytics Tabs Component
import React from 'react';

const AnalyticsTabs = ({ tabs, activeTab, onTabChange }) => {
  return (
    <div className="mb-6">
      <div className="flex border-b border-gray-200">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => onTabChange(tab.id)}
            className={`px-6 py-3 font-medium transition-colors relative ${
              activeTab === tab.id
                ? 'text-blue-600 border-b-2 border-blue-600'
                : 'text-gray-600 hover:text-blue-600'
            }`}
          >
            {tab.label}
            {tab.icon && <span className="ml-2">{tab.icon}</span>}
          </button>
        ))}
      </div>
    </div>
  );
};

export default AnalyticsTabs;
