import axios from "axios";

// API base URL configuration
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? "http://backend:5000" // Docker Compose service name
  : "http://localhost:5000"; // Development environment

// Configure axios defaults
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

// Health check endpoint
export const checkHealth = async () => {
  try {
    const response = await apiClient.get('/api/health');
    return response.data;
  } catch (error) {
    console.error("Error checking health:", error);
    throw error;
  }
};

// System status endpoint
export const fetchStatus = async () => {
  try {
    const response = await apiClient.get('/api/status');
    return response.data;
  } catch (error) {
    console.error("Error fetching status:", error);
    throw error;
  }
};

// Lighting control endpoints
export const fetchLightingStatus = async () => {
  try {
    const response = await apiClient.get('/api/lighting');
    return response.data;
  } catch (error) {
    console.error("Error fetching lighting status:", error);
    throw error;
  }
};

export const updateLighting = async (lightingData: any) => {
  try {
    const response = await apiClient.post('/api/lighting', lightingData);
    return response.data;
  } catch (error) {
    console.error("Error updating lighting:", error);
    throw error;
  }
};

// Watering control endpoints
export const fetchWateringStatus = async () => {
  try {
    const response = await apiClient.get('/api/watering');
    return response.data;
  } catch (error) {
    console.error("Error fetching watering status:", error);
    throw error;
  }
};

export const triggerWatering = async (wateringData: any) => {
  try {
    const response = await apiClient.post('/api/watering', wateringData);
    return response.data;
  } catch (error) {
    console.error("Error triggering watering:", error);
    throw error;
  }
};

// Sensor data endpoint
export const fetchSensorData = async () => {
  try {
    const response = await apiClient.get('/api/sensors');
    return response.data;
  } catch (error) {
    console.error("Error fetching sensor data:", error);
    throw error;
  }
};

// Legacy support (backward compatibility)
export const updateSettings = async (settings: any) => {
  console.warn("updateSettings is deprecated. Use specific lighting/watering endpoints instead.");
  
  // Attempt to route to appropriate endpoint based on settings content
  if (settings.brightness !== undefined) {
    return updateLighting(settings);
  } else if (settings.wateringInterval !== undefined) {
    return triggerWatering(settings);
  }
  
  throw new Error("Unknown settings type. Use specific endpoints instead.");
};
