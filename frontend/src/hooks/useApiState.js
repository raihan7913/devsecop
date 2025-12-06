// Custom hook untuk mengelola state API calls yang sering digunakan
import { useState } from 'react';

export const useApiState = (initialLoading = true) => {
  const [loading, setLoading] = useState(initialLoading);
  const [error, setError] = useState(null);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState(''); // 'success' or 'error'

  const setSuccessMessage = (msg) => {
    setMessage(msg);
    setMessageType('success');
    setTimeout(() => {
      setMessage('');
      setMessageType('');
    }, 3000);
  };

  const setErrorMessage = (msg) => {
    setMessage(msg);
    setMessageType('error');
    setTimeout(() => {
      setMessage('');
      setMessageType('');
    }, 5000);
  };

  const clearMessage = () => {
    setMessage('');
    setMessageType('');
  };

  const resetState = () => {
    setLoading(initialLoading);
    setError(null);
    setMessage('');
    setMessageType('');
  };

  return {
    loading,
    setLoading,
    error,
    setError,
    message,
    setMessage,
    messageType,
    setMessageType,
    setSuccessMessage,
    setErrorMessage,
    clearMessage,
    resetState,
  };
};
