import axios from "axios";

const API_BASE_URL = "http://backend:5000"; // Docker Compose service name

export const fetchStatus = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/status`);
    return response.data;
  } catch (error) {
    console.error("Error fetching status:", error);
    throw error;
  }
};

export const updateSettings = async (settings: any) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/settings`, settings);
    return response.data;
  } catch (error) {
    console.error("Error updating settings:", error);
    throw error;
  }
};
