// Custom hook untuk mengelola form state
import { useState } from 'react';

export const useFormState = (initialState = {}) => {
  const [formData, setFormData] = useState(initialState);

  const handleChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const resetForm = () => {
    setFormData(initialState);
  };

  const setForm = (newData) => {
    setFormData(newData);
  };

  return {
    formData,
    setFormData,
    handleChange,
    handleInputChange,
    resetForm,
    setForm,
  };
};
