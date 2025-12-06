// Custom hook untuk mengelola modal state
import { useState } from 'react';

export const useModal = (initialOpen = false) => {
  const [isOpen, setIsOpen] = useState(initialOpen);
  const [modalData, setModalData] = useState(null);

  const openModal = (data = null) => {
    setModalData(data);
    setIsOpen(true);
  };

  const closeModal = () => {
    setIsOpen(false);
    // Delay clearing data to allow close animation
    setTimeout(() => setModalData(null), 300);
  };

  const toggleModal = () => {
    setIsOpen(prev => !prev);
  };

  return {
    isOpen,
    modalData,
    openModal,
    closeModal,
    toggleModal,
    setModalData
  };
};
