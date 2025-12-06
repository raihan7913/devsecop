// Custom hook untuk handle multiple API calls dengan Promise.all
import { useState, useCallback } from 'react';

export const useBatchApiCall = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const executeBatch = useCallback(async (apiCalls) => {
    setLoading(true);
    setError(null);
    try {
      const results = await Promise.all(apiCalls);
      return { success: true, data: results };
    } catch (err) {
      const errorMessage = err.message || 'An error occurred';
      setError(errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      setLoading(false);
    }
  }, []);

  const reset = useCallback(() => {
    setLoading(false);
    setError(null);
  }, []);

  return {
    loading,
    error,
    executeBatch,
    reset,
  };
};
