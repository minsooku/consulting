import React, { useState } from "react";
import { View, Text, TextInput, Button, Alert } from "react-native";
import { login } from "../api/auth";

export default function LoginScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async () => {
    try {
      const res = await login(email, password);
      Alert.alert("Success", `Token: ${res.access_token}`);
      // AsyncStorage 
    } catch (err) {
      Alert.alert("Error", err.response?.data?.detail || err.message);
    }
  };

  return (
    <View style={{ flex: 1, justifyContent: "center", padding: 16 }}>
      <Text>Login</Text>
      <TextInput placeholder="Email" value={email} onChangeText={setEmail} style={{ borderWidth: 1, marginVertical: 8, padding: 8 }}/>
      <TextInput placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry style={{ borderWidth: 1, marginVertical: 8, padding: 8 }}/>
      <Button title="Login" onPress={handleLogin} />
    </View>
  );
}
