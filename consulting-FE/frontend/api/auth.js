import axios from "axios";
import { Platform } from "react-native";
import { IOS_API_URL, ANDROID_API_URL } from "@env";

const API_URL = Platform.OS === "ios" ? IOS_API_URL : ANDROID_API_URL;

export const register = async (email, full_name, password) => {
  const res = await axios.post(`${API_URL}/auth/register`, { email, full_name, password });
  return res.data;
};

export const login = async (email, password) => {
  const res = await axios.post(`${API_URL}/auth/login`, { email, password });
  return res.data; // { access_token, token_type }
};
